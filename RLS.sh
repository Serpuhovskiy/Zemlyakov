#!/bin/bash

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


# Получаем координаты РЛС и точки для проверки
# read -p "Введите координаты РЛС (в формате x,y):" rls_coords
# read -p "Введите координаты точки (в формате x,y):" point_coords
# read -p "Введите радиус сектора обзора (R):" R
# read -p "Введите угол обзора (α):" alpha
# read -p "Введите угол азимута (θ):" theta

rls_coords="8000000,7000000"
point_coords="9000000,5000000"
R=4000000
alpha=200
theta=45

# Разделяем координаты РЛС и точки на отдельные переменные
rls_x=$(echo $rls_coords | cut -d',' -f1)
rls_y=$(echo $rls_coords | cut -d',' -f2)
point_x=$(echo $point_coords | cut -d',' -f1)
point_y=$(echo $point_coords | cut -d',' -f2)

# Вычисляем расстояние от РЛС до точки
distance=$(echo "sqrt(($point_x-$rls_x)^2+($point_y-$rls_y)^2)" | bc)
echo "$distance"

# Вычисляем азимут между точкой и РЛС
azimuth=$(echo $(atan2 $(( point_y-rls_y )) $(( point_x-rls_x ))))
echo "азимут в радианах $azimuth"
# Переводим в градусы
azimuth=$(echo "$(echo "$azimuth*180/$pi" | bc -l)")
echo "азимут в градусах $azimuth"

# Переходим к азимуту от севера
azimuth=$(echo "90 - $azimuth" | bc)
azimuth_rounded=$(echo "scale=8; $azimuth" | bc)
echo "azimuth_rounded $azimuth_rounded"

if [[ $(echo "$azimuth_rounded < 0" | bc) -eq 1 ]]; then
echo "AZIMUTH < 0"
azimuth=$(echo "$azimuth_rounded + 360" | bc)
echo "new azimuth $azimuth"
else
echo "AZIMUTH >= 0"
fi

# Проверяем, лежит ли точка в секторе обзора
if (( $(echo "$distance <= $R" | bc -l) )) && (( $(echo "$azimuth >= $theta-$alpha/2" | bc -l) )) && (( $(echo "$azimuth <= $theta+$alpha/2" | bc -l) )); then
echo "Лежит"
else
echo "Не лежит"
fi
