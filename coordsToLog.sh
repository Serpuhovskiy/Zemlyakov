# Определяем имя файла, в который будем записывать результаты
ids_file="ids.txt"

# Создаем файл или очищаем его, если он уже существует
> "$ids_file"


while :
do
    date=`date +"%T"`
    # Находим все файлы в /tmp/GenTargets/Targets и пробегаемся по каждому в цикле
    find /tmp/GenTargets/Targets -type f -maxdepth 1 | sort -n | tail -5 | while read file; do
        
        # Определяем id цели (6 последних символов имени файла)
        target_id=${file: -6}

        # Извлекаем строку с координатами из файла
        coords=$(head -n 1 "$file")
        echo "Строка: $coords"

        # Очищаем координаты от лишних символов и записываем в переменные
        x=$(echo "$coords" | cut -d ',' -f 1 | cut -c 2-)
        y=$(echo "$coords" | cut -d ',' -f 2 | cut -c 2-)

        # Считаем количество записей цели с target_id в файле лога
        count_of_targets=`grep -c "$target_id" $ids_file`
        echo "Количество целей $target_id в файле: $count_of_targets"

        # Если количество = 0, значит такой цели еще не было обнаружено
        if [[ $count_of_targets -eq 0 ]]
        then    
            echo "Цель $target_id записывается первый раз"
            echo "$date Обнаружена цель ID:$target_id с координатами $x $y, первая засечка" >> "$ids_file"
        # Если количество = 1, значит первая засечка уже была, записываем вторую
        elif [[ $count_of_targets -eq 1 ]]
        then
            echo "Цель $target_id записывается второй раз"
            echo "$date Обнаружена цель ID:$target_id с координатами $x $y, вторая засечка" >> "$ids_file"
        # Если количество > 1, значит две засечки уже было
        else
            echo "Цель $target_id больше не записывается"
        fi 

    done
    echo "Пауза 2,5 секунды..."
    sleep 2.5
done