gnome-terminal -e "./GenTargets.sh"
sleep 1
# Определяем имя файла, в который будем записывать результаты
log_file="log.txt"
current_targets_file="currentTargets.txt"
maybeDestroyed="maybeDestroyedTargets.txt"
> "$maybeDestroyed"

# Создаем файл или очищаем его, если он уже существует
> "$log_file"



while :
do
    filesNamesForLog=$(find /tmp/GenTargets/Targets/ -type f -printf '%T@ %p\n' | sort -n | cut -d '/' -f5- | tail -n 30)
    > "$current_targets_file"
    echo "$filesNamesForLog" >> "$current_targets_file"
    
    # Находим все файлы в /tmp/GenTargets/Targets и пробегаемся по каждому в цикле
    files=$(find /tmp/GenTargets/Targets/ -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2- | tail -n 30)
    for file in $files; do  
        # Определяем id цели (6 последних символов имени файла)
        target_id=${file: -6}

        # isTargetFired=`grep -c "^Стрельба по цели $target_id$" $ids_log_file`
        # echo "$target_id" >> "$ids_log_file"
        # echo "FILENAME: $file"

        # Извлекаем строку с координатами из файла
        coords=$(head -n 1 "$file")
        # echo "Строка: $coords"

        # Очищаем координаты от лишних символов и записываем в переменные
        x=$(echo "$coords" | cut -d ',' -f 1 | cut -c 2-)
        y=$(echo "$coords" | cut -d ',' -f 2 | cut -c 2-)

        # Передаем координаты первой РЛС
        source ./RLS_1.sh $target_id $x $y &
        # Передаем координаты первой РЛС
        source ./RLS_2.sh $target_id $x $y &
        # Передаем координаты СПРО
        # source ./SPRO.sh $target_id $x $y &
        # Передаем координаты ЗРДН_1
        source ./ZRDN_1.sh $target_id $x $y &
        source ./ZRDN_2.sh $target_id $x $y &
        source ./ZRDN_3.sh $target_id $x $y &

    done
    echo "Пауза 2,5 секунды..."
    sleep 2.5
done