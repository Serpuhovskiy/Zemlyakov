#!/bin/bash

# Определяем имя файла, в который будем записывать результаты
log_file="log.txt"

date=`date +"%T"`

# Переданные засечки
x1=${2}
y1=${3}
x2=${4}
y2=${5}

# ========== Центр СПРО и радиус его обзора =====
xc=2500000
yc=3000000
R=1700000
# ===============================================

# Найдем уравнение прямой, проходящей через точки (x1, y1) и (x2, y2)
a=$((y2 - y1))
b=$((x1 - x2))
c=$((x2 * y1 - x1 * y2))

# Вычисляем расстояние от центра СПРО до каждой точки
distance2=$(echo "sqrt(($x2-$xc)^2+($y2-$yc)^2)" | bc)
distance1=$(echo "sqrt(($x1-$xc)^2+($y1-$yc)^2)" | bc)
speed=$(echo "sqrt(($x2-$x1)^2+($y2-$y1)^2)" | bc)

# Найдем расстояние от центра окружности до прямой
expr=$(echo "sqrt(($a * $xc + $b * $yc + $c)^2)" | bc)
expr1=$(echo "sqrt($a^2 + $b^2)" | bc)
d=$(echo "scale=6; $expr / $expr1" | bc -l)

# Проверим, пересекает ли прямая окружность
if [ $(echo "$d <= $R" | bc -l) -eq 1 ]; then
    if [ $distance2 -lt $distance1 ] && [ $speed -ge 8000 ]; then
        echo "$date $6: Цель ID:$target_id движется в направлении СПРО" >> "$log_file"
        echo -e "\e[31m Объект движется в направлении СПРО \e[0m"
    else
        echo "Объект движется от СПРО"
    fi
else
  echo "Объект не попадет в область обзора СПРО"
fi
