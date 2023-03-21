# Определяем имя файла, в который будем записывать результаты
ids_file="ids.txt"

# Создаем файл или очищаем его, если он уже существует
> "$ids_file"

# date=`date +"%T"`
while :
do
    find /tmp/GenTargets/Targets -type f -maxdepth 1 | sort -n | tail -5 | while read file; do
        # Выводим id целей в отдельный файл
        target_id=${file: -6}

        if grep -q "$target_id" $ids_file; then
            echo "Цель с id $target_id уже записана"
            echo "$date $target_id вторая и более засечка"  >> "$ids_file"
            # echo "$target_id"  >> "$ids_file"
        else
            echo "Цель с id $target_id записывается первый раз"
            echo "$date $target_id первая засечка"  >> "$ids_file"
            # echo "$target_id"  >> "$ids_file"
        fi
        # echo "$target_id"  >> "$ids_file"
        # Здесь можно добавить код для обработки файла
    done
    echo "Цикл"
    sleep 2.5
done