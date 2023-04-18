#!/bin/bash

touch "temp/RLS_1_active.txt"

# Определяем имя файла, в который будем записывать результаты
log_file="log.txt"
main_log="mainLog.txt"
date=`date +"%T"`

pi=3.14159265359

# Функция арктангенса от двух параметров
function atan2 {
    local y="$1"
    local x="$2"

    if (( x > 0 )); then
        echo "scale=10; a($y/$x)" | bc -l
    elif (( x < 0 )) && (( y >= 0 )); then
        echo "scale=10; a($y/$x)+3.1415926535" | bc -l
    elif (( x < 0 )) && (( y < 0 )); then
        echo "scale=10; a($y/$x)-3.1415926535" | bc -l
    elif (( x == 0 )) && (( y > 0 )); then
        echo "scale=10; 1.5707963268" | bc -l
    elif (( x == 0 )) && (( y < 0 )); then
        echo "scale=10; -1.5707963268" | bc -l
    else
        echo "scale=10; 0" | bc -l
    fi
}

rls_x=3100000
rls_y=3800000
R=4000000
alpha=200
theta=135

target_id=$1
point_x=$2
point_y=$3


function writeToLog {
    # Считаем количество записей цели с target_id в файле лога
    count_of_targets=`grep -c "^.*RLS_1.*$target_id" $log_file`

    # Если количество = 0, значит такой цели еще не было обнаружено (ПЕРВАЯ ЗАСЕЧКА)
    if [[ $count_of_targets -eq 0 ]]
    then    
        echo "$date RLS_1: Обнаружена цель ID:$target_id с координатами $x $y первая засечка" >> "$log_file"

    # Если количество = 1, значит первая засечка уже была, записываем вторую (ВТОРАЯ ЗАСЕЧКА)
    elif [[ $count_of_targets -eq 1 ]]
    then
        first_serif=`grep -E "^.*RLS_1.*$target_id.*первая засечка$" $log_file`
        x_1=$(echo "$first_serif" | cut -d ' ' -f 8)
        y_1=$(echo "$first_serif" | cut -d ' ' -f 9)

        if [ $x_1 != $x ] && [ $y_1 != $y ]; then
            echo "$date RLS_1: Обнаружена цель ID:$target_id с координатами $x $y вторая засечка" >> "$log_file"
            speed=$(echo "sqrt(($x-$x_1)^2+($y-$y_1)^2)" | bc)
            
            # Проверяем на скорость
            if [ $speed -ge 8000 ]; then
                
                # Отправляем инфу на КП
                source ./KP.sh "RLS_1" "$date" "$target_id" "Обнаружена" "$date RLS_1: Обнаружена цель ID:$target_id с координатами $x $y" 

                source ./movementToSPRO.sh $target_id $x_1 $y_1 $x $y "RLS_1" &
            fi
        fi
    fi 
}


# Вычисляем расстояние от РЛС до точки
distance=$(echo "sqrt(($point_x-$rls_x)^2+($point_y-$rls_y)^2)" | bc)

# Вычисляем азимут между точкой и РЛС
azimuth=$(echo $(atan2 $(( point_y-rls_y )) $(( point_x-rls_x ))))

# Переводим в градусы
azimuth=$(echo "$(echo "$azimuth*180/$pi" | bc -l)")

# Переходим к азимуту от севера
azimuth=$(echo "90 - $azimuth" | bc)
azimuth_rounded=$(echo "scale=8; $azimuth" | bc)

if [[ $(echo "$azimuth_rounded < 0" | bc) -eq 1 ]]; then
    azimuth=$(echo "$azimuth_rounded + 360" | bc)
fi

# Проверяем, лежит ли точка в секторе обзора
if (( $(echo "$distance <= $R" | bc -l) )) && (( $(echo "$azimuth >= $theta-$alpha/2" | bc -l) )) && (( $(echo "$azimuth <= $theta+$alpha/2" | bc -l) )); then
    writeToLog
fi


