
if [[ $(id -u) -eq 0 ]]; then
    echo "Вы не можете запускать этот скрипт с правами администратора!"
    exit 1
fi

if [[ $(uname -s) != "Linux" ]]; then
    echo "Этот скрипт не может быть запущен на ОС, отличающейся от Linux!"
    exit 1
fi

if [[ $(ps -p $$ -ocomm=) != "bash" ]]; then
    echo "Этот скрипт не может быть запущен в командном интерпретаторе отличном от Bash!"
    exit 1
fi


gnome-terminal -e "./GenTargets.sh"
sleep 1
# Определяем имя файла, в который будем записывать результаты
log_file="log.txt"
main_log="logs/mainLog.txt"
> "$log_file"
> "$main_log"


current_targets_file="currentTargets.txt"
maybeDestroyed_SPRO="maybeDestroyedTargets_SPRO.txt"
maybeDestroyed_ZRDN_1="maybeDestroyedTargets_ZRDN_1.txt"
maybeDestroyed_ZRDN_2="maybeDestroyedTargets_ZRDN_2.txt"
maybeDestroyed_ZRDN_3="maybeDestroyedTargets_ZRDN_3.txt"
> "$maybeDestroyed_SPRO"
> "$maybeDestroyed_ZRDN_1"
> "$maybeDestroyed_ZRDN_2"
> "$maybeDestroyed_ZRDN_3"

bk_SPRO="bk_SPRO.txt"
bk_ZRDN_1="bk_ZRDN_1.txt"
bk_ZRDN_2="bk_ZRDN_2.txt"
bk_ZRDN_3="bk_ZRDN_3.txt"
echo "10" >> "$bk_SPRO"
echo "20" >> "$bk_ZRDN_1"
echo "20" >> "$bk_ZRDN_2"
echo "20" >> "$bk_ZRDN_3"

# Удаляем все базы данных
rm db/*.db

# Удаляем все временные файлы
rm temp/*.*

while :
do
    filesNamesForLog=$(find /tmp/GenTargets/Targets/ -type f -printf '%T@ %p\n' | sort -n | cut -d '/' -f5- | tail -n 30)
    > "$current_targets_file"

    # Выводим все текущие файлы
    echo "$filesNamesForLog" >> "$current_targets_file"
    
    # Находим все файлы в /tmp/GenTargets/Targets и пробегаемся по каждому в цикле
    files=$(find /tmp/GenTargets/Targets/ -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2- | tail -n 30)
    for file in $files; do  
        # Определяем id цели (6 последних символов имени файла)
        target_id=${file: -6}

        # Извлекаем строку с координатами из файла
        coords=$(head -n 1 "$file")

        # Очищаем координаты от лишних символов и записываем в переменные
        x=$(echo "$coords" | cut -d ',' -f 1 | cut -c 2-)
        y=$(echo "$coords" | cut -d ',' -f 2 | cut -c 2-)

        # Передаем координаты первой РЛС
        source ./RLS_1.sh $target_id $x $y &
        # Передаем координаты первой РЛС
        source ./RLS_2.sh $target_id $x $y &
        # Передаем координаты первой РЛС
        source ./RLS_3.sh $target_id $x $y &
        # Передаем координаты СПРО
        source ./SPRO.sh $target_id $x $y &
        # Передаем координаты ЗРДН_1
        source ./ZRDN_1.sh $target_id $x $y &
        # Передаем координаты ЗРДН_2
        source ./ZRDN_2.sh $target_id $x $y &
        # Передаем координаты ЗРДН_3
        source ./ZRDN_3.sh $target_id $x $y &

    done
    echo "Пауза 2,5 секунды..."
    sleep 2.5
done