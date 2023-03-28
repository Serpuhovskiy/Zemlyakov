#!/bin/bash

echo "+++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++"

pi=3.14159265359
log_file="log.txt"
date=`date +"%T"`

# Координаты СПРО
spro_x=2600000
spro_y=2800000
R=1700000
target_id=$1
x=$2
y=$3


# Вычисляем расстояние от СПРО до точки
distance=$(echo "sqrt(($spro_x-$x)^2+($spro_y-$y)^2)" | bc)

# Проверяем, лежит ли точка в зоне обзора СПРО
if (( $(echo "$distance <= $R" | bc -l) )); then
echo -e "\e[32m   Точка ($x, $y) лежит в зоне обзора СПРО   \e[0m"

    count_of_targets=`grep -c "^.*SPRO.*$target_id.*засечка$" $log_file`
    echo "КОЛИЧЕСТВО ЗАПИСЕЙ $target_id: $count_of_targets"
    # Если количество = 0, значит такой цели еще не было обнаружено (ПЕРВАЯ ЗАСЕЧКА)
    if [[ $count_of_targets -eq 0 ]]
    then    
        echo "$date SPRO: Обнаружена цель ID:$target_id с координатами $x $y первая засечка" >> "$log_file"

    # Если количество = 1, значит первая засечка уже была, записываем вторую (ВТОРАЯ ЗАСЕЧКА)
    elif [[ $count_of_targets -eq 1 ]]
    then
        first_serif=`grep -E "^.*SPRO.*$target_id.*первая засечка$" $log_file`
        x_1=$(echo "$first_serif" | cut -d ' ' -f 8)
        y_1=$(echo "$first_serif" | cut -d ' ' -f 9)

        if [ $x_1 != $x ] && [ $y_1 != $y ]; then
            echo "$date SPRO: Обнаружена цель ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
            speed=$(echo "sqrt(($x-$x_1)^2+($y-$y_1)^2)" | bc)
            if [ $speed -ge 8000 ]; then
                echo "СКОРОСТЬ СБИВАЕМОГО ОБЪЕКТА $target_id: $speed"
                echo "ЭТО ББ БР"
                source ./destroy.sh $target_id &
            fi
        fi
    # Если количество > 1, значит две засечки уже было
    else
        echo "Цель с ID:$target_id не была уничтожена предыдущими попытками"
        echo "$date SPRO: Стрельба по цели с ID:$target_id ПРОМАХ!" >> "$log_file"
        echo "Пробуем уничтожить цель с ID:$target_id еще раз"
        source ./destroy.sh $target_id &
    fi 
else
echo "Не лежит"
fi
