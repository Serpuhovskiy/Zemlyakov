#!/bin/bash

pi=3.14159265359
log_file="log.txt"
date=`date +"%T"`
maybeDestroyed="maybeDestroyedTargets_ZRDN_2.txt"


# =================== Координаты ЗРДН_2 ===========================
spro_x=8000000
spro_y=6000000
R=600000
target_id=$1
x=$2
y=$3
# ================================================================


# Убираем дубли в файле с потенциально уничтоженными целями, оставляя порядок строк
# awk '!a[$0]++' "$maybeDestroyed" > "tmp.txt"
# if [ -f "./tmp.txt" ]; then
#     mv "tmp.txt" "$maybeDestroyed"
# fi
# awk '!a[$0]++' "$maybeDestroyed" > "tmp.txt"
# if [ -f "tmp.txt" ]; then
#     if [ -s "$maybeDestroyed" ]; then
#         mv "tmp.txt" "$maybeDestroyed"
#     else
#         cat /dev/null > "$maybeDestroyed"
#     fi
# fi

# Функция удаления строки с определенной подстрокой из файла
function removeString {
local substring="$1"
local file="$2"

grep -v "$substring" "$file" > "tmp1.txt"
mv "tmp1.txt" "$file"
}

# Проверяем, была ли уничтожена цель
cat "$maybeDestroyed" | while read line; do
    isMaybeDestroyedInCurrent=`grep -c "$line" "currentTargets.txt"`
    if [ $isMaybeDestroyedInCurrent -eq 0 ]; then
        removeString "$line" "$maybeDestroyed"
        echo -e "\033[32m          Цель $line была уничтожена на предыдущем шаге           \033[0m"
    fi
done

# Вычисляем расстояние от ЗРДН_2 до точки
distance=$(echo "sqrt(($spro_x-$x)^2+($spro_y-$y)^2)" | bc)

# Проверяем, лежит ли точка в зоне обзора ЗРДН_2
if (( $(echo "$distance <= $R" | bc -l) )); then
    echo -e "\e[32mZRDN_2:   Точка $target_id ($x, $y) лежит в зоне обзора ЗРДН_2   \e[0m"

    # Считаем количество засечек в логе
    count_of_serifs=`grep -c "^.*ZRDN_2.*$target_id.*засечка$" $log_file`

    # Если количество = 0, значит такой цели еще не было обнаружено (ПЕРВАЯ ЗАСЕЧКА)
    if [[ $count_of_serifs -eq 0 ]]
    then    
        echo "$date ZRDN_2: Обнаружена цель ID:$target_id с координатами $x $y первая засечка" >> "$log_file"

    # Если количество = 1, значит первая засечка уже была, записываем вторую (ВТОРАЯ ЗАСЕЧКА)
    elif [[ $count_of_serifs -eq 1 ]]
    then
        # Ищем координаты первой засечки
        first_serif=`grep -E "^.*ZRDN_2.*$target_id.*первая засечка$" $log_file`
        x_1=$(echo "$first_serif" | cut -d ' ' -f 8)
        y_1=$(echo "$first_serif" | cut -d ' ' -f 9)

        if [ $x_1 != $x ] && [ $y_1 != $y ]; then
            speed=$(echo "sqrt(($x-$x_1)^2+($y-$y_1)^2)" | bc)

            # Если Крылатая ракета
            if [ $speed -ge 250 ] && [ $speed -le 1000 ]; then
                echo "$date ZRDN_2: Обнаружена цель:КрылатаяРакета ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
                source ./destroy.sh $target_id "ZRDN_2" &
            elif [ $speed -ge 50 ] && [ $speed -le 249 ]; then
                echo "$date ZRDN_2: Обнаружена цель:Самолет ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
                source ./destroy.sh $target_id "ZRDN_2" &
            else
                removeString "$first_serif" "$log_file"
            fi
        fi

    # Если количество > 1, значит две засечки уже было
    else
        echo -e "\e[32mZRDN_2:     Цель с ID:$target_id не была уничтожена предыдущими попытками   \e[0m"
        echo "$date ZRDN_2: Стрельба по цели с ID:$target_id ПРОМАХ!" >> "$log_file"
        echo -e "\e[32mZRDN_2:     Пробуем уничтожить цель с ID:$target_id еще раз      \e[0m"
        source ./destroy.sh $target_id "ZRDN_2" &
    fi 
fi
