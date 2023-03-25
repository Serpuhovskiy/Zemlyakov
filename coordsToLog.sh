# Определяем имя файла, в который будем записывать результаты
log_file="log.txt"

# Создаем файл или очищаем его, если он уже существует
> "$log_file"


while :
do
    # Находим все файлы в /tmp/GenTargets/Targets и пробегаемся по каждому в цикле
    find /tmp/GenTargets/Targets -type f -maxdepth 1 | sort -n | tail -30 | while read file; do
        
        # Определяем id цели (6 последних символов имени файла)
        target_id=${file: -6}

        # Извлекаем строку с координатами из файла
        coords=$(head -n 1 "$file")
        # echo "Строка: $coords"

        # Очищаем координаты от лишних символов и записываем в переменные
        x=$(echo "$coords" | cut -d ',' -f 1 | cut -c 2-)
        y=$(echo "$coords" | cut -d ',' -f 2 | cut -c 2-)

        # Передаем координаты первой РЛС
        source ./RLS_1.sh $target_id $x $y

    done
    echo "Пауза 2,5 секунды..."
    sleep 2.5
done