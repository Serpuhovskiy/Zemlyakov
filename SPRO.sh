#!/bin/bash

pi=3.14159265359
log_file="log.txt"
main_log="mainLog.txt"
date=`date +"%T"`
maybeDestroyed="maybeDestroyedTargets_SPRO.txt"


# =================== Координаты СПРО ===========================
spro_x=2600000
spro_y=2800000
R=1700000
target_id=$1
x=$2
y=$3
# ================================================================

# Функция удаления строки с определенной подстрокой из файла
function removeString {
    local substring="$1"
    local file="$2"

    grep -v "$substring" "$file" > "temp/tmp1.txt"
    mv "temp/tmp1.txt" "$file"
}

# Проверяем, была ли уничтожена цель
cat "$maybeDestroyed" | while read line; do
    isMaybeDestroyedInCurrent=`grep -c "$line" "currentTargets.txt"`
    if [ $isMaybeDestroyedInCurrent -eq 0 ]; then
        removeString "$line" "$maybeDestroyed"
        echo -e "\033[32m          Цель $line была уничтожена на предыдущем шаге           \033[0m"
        echo "$date SPRO: Цель ID:$target_id УНИЧТОЖЕНА"
        echo "$date SPRO: Цель ID:$line УНИЧТОЖЕНА" >> "$main_log"
    fi
done

# Вычисляем расстояние от СПРО до точки
distance=$(echo "sqrt(($spro_x-$x)^2+($spro_y-$y)^2)" | bc)

# Проверяем, лежит ли точка в зоне обзора СПРО
if (( $(echo "$distance <= $R" | bc -l) )); then
    echo -e "\e[32mSPRO:   Точка $target_id ($x, $y) лежит в зоне обзора СПРО   \e[0m"

    # Считаем количество засечек в логе
    count_of_serifs=`grep -c "^.*SPRO.*$target_id.*засечка$" $log_file`

    # Если количество = 0, значит такой цели еще не было обнаружено (ПЕРВАЯ ЗАСЕЧКА)
    if [[ $count_of_serifs -eq 0 ]]
    then    
        echo "$date SPRO: Обнаружена цель ID:$target_id с координатами $x $y первая засечка" >> "$log_file"

    # Если количество = 1, значит первая засечка уже была, записываем вторую (ВТОРАЯ ЗАСЕЧКА)
    elif [[ $count_of_serifs -eq 1 ]]
    then
        # Ищем координаты первой засечки
        first_serif=`grep -E "^.*SPRO.*$target_id.*первая засечка$" $log_file`
        x_1=$(echo "$first_serif" | cut -d ' ' -f 8)
        y_1=$(echo "$first_serif" | cut -d ' ' -f 9)

        if [ $x_1 != $x ] && [ $y_1 != $y ]; then
            speed=$(echo "sqrt(($x-$x_1)^2+($y-$y_1)^2)" | bc)
            if [ $speed -ge 8000 ]; then
                echo "$date SPRO: Обнаружена цель ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
                echo "$date SPRO: Обнаружена цель (ББ БР) ID:$target_id с координатами $x $y" >> "$main_log"
                echo "$date SPRO: Производится стрельба по цели ID:$target_id" >> "$main_log"
                source ./destroy.sh $target_id "SPRO" &
            else
                removeString "$first_serif" "$log_file"
            fi
        fi

    # Если количество > 1, значит две засечки уже было
    else
        echo -e "\e[32mSPRO:     Цель с ID:$target_id не была уничтожена предыдущими попытками   \e[0m"
        echo "$date SPRO: Стрельба по цели с ID:$target_id ПРОМАХ!" >> "$log_file"
        echo "$date SPRO: Стрельба по цели ID:$target_id ПРОМАХ!" >> "$main_log"
        echo -e "\e[32mSPRO:     Пробуем уничтожить цель с ID:$target_id еще раз      \e[0m"
        
        echo "$date SPRO: Повторная стрельба по цели ID:$target_id" >> "$main_log"
        source ./destroy.sh $target_id "SPRO" &
    fi 
fi
