#!/bin/bash

pi=3.14159265359
log_file="log.txt"
date=`date +"%T"`
maybeDestroyed="maybeDestroyedTargets_ZRDN_3.txt"


# =================== Координаты ЗРДН_3 ===========================
spro_x=9000000
spro_y=5500000
R=550000
target_id=$1
x=$2
y=$3
# ================================================================

# Функция удаления строки с определенной подстрокой из файла
function removeString {
local substring="$1"
local file="$2"

grep -v "$substring" "$file" > "temp/tmp4.txt"
mv "temp/tmp4.txt" "$file"
}

# Проверяем, была ли уничтожена цель
cat "$maybeDestroyed" | while read line; do
    isMaybeDestroyedInCurrent=`grep -c "$line" "currentTargets.txt"`
    if [ $isMaybeDestroyedInCurrent -eq 0 ]; then
        removeString "$line" "$maybeDestroyed"
        echo -e "\033[32m          Цель $line была уничтожена на предыдущем шаге           \033[0m"
        echo "$date ZRDN_3: Цель ID:$line была уничтожена" >> "$log_file"
        echo "$date ZRDN_3: Цель ID:$line УНИЧТОЖЕНА" >> "$main_log"
    fi
done

# Вычисляем расстояние от ЗРДН_3 до точки
distance=$(echo "sqrt(($spro_x-$x)^2+($spro_y-$y)^2)" | bc)

# Проверяем, лежит ли точка в зоне обзора ЗРДН_3
if (( $(echo "$distance <= $R" | bc -l) )); then
    echo -e "\e[32mZRDN_3:   Точка $target_id ($x, $y) лежит в зоне обзора ЗРДН_3   \e[0m"

    # Считаем количество засечек в логе
    count_of_serifs=`grep -c "^.*ZRDN_3.*$target_id.*засечка$" $log_file`

    # Если количество = 0, значит такой цели еще не было обнаружено (ПЕРВАЯ ЗАСЕЧКА)
    if [[ $count_of_serifs -eq 0 ]]
    then    
        echo "$date ZRDN_3: Обнаружена цель ID:$target_id с координатами $x $y первая засечка" >> "$log_file"

    # Если количество = 1, значит первая засечка уже была, записываем вторую (ВТОРАЯ ЗАСЕЧКА)
    elif [[ $count_of_serifs -eq 1 ]]
    then
        # Ищем координаты первой засечки
        first_serif=`grep -E "^.*ZRDN_3.*$target_id.*первая засечка$" $log_file`
        x_1=$(echo "$first_serif" | cut -d ' ' -f 8)
        y_1=$(echo "$first_serif" | cut -d ' ' -f 9)

        if [ $x_1 != $x ] && [ $y_1 != $y ]; then
            speed=$(echo "sqrt(($x-$x_1)^2+($y-$y_1)^2)" | bc)

            # Если Крылатая ракета
            if [ $speed -ge 250 ] && [ $speed -le 1000 ]; then
                echo "$date ZRDN_3: Обнаружена цель:КрылатаяРакета ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
                echo "$date ZRDN_3: Обнаружена цель (Крылатая ракета) ID:$target_id с координатами $x $y" >> "$main_log"
                
                echo "$date ZRDN_3: Производится стрельба по цели ID:$target_id" >> "$main_log"
                source ./destroy.sh $target_id "ZRDN_3" &
            #  Если самолет
            elif [ $speed -ge 50 ] && [ $speed -le 249 ]; then
                echo "$date ZRDN_3: Обнаружена цель:Самолет ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
                echo "$date ZRDN_3: Обнаружена цель (Самолет) ID:$target_id с координатами $x $y" >> "$main_log"
                
                echo "$date ZRDN_3: Производится стрельба по цели ID:$target_id" >> "$main_log"
                source ./destroy.sh $target_id "ZRDN_3" &
            else
                removeString "$first_serif" "$log_file"
            fi
        fi

    # Если количество > 1, значит две засечки уже было
    else
        echo -e "\e[32mZRDN_3:     Цель с ID:$target_id не была уничтожена предыдущими попытками   \e[0m"
        echo "$date ZRDN_3: Стрельба по цели с ID:$target_id ПРОМАХ!" >> "$log_file"
        echo "$date ZRDN_3: Стрельба по цели ID:$target_id ПРОМАХ!" >> "$main_log"

        echo -e "\e[32mZRDN_3:     Пробуем уничтожить цель с ID:$target_id еще раз      \e[0m"
        echo "$date ZRDN_3: Повторная стрельба по цели ID:$target_id" >> "$main_log"
        source ./destroy.sh $target_id "ZRDN_3" &
    fi 
fi
