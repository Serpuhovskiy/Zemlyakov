# #!/bin/bash

# pi=3.14159265359
# # Получаем координаты РЛС и точки для проверки
# read -p "Введите координаты РЛС (в формате x,y):" rls_coords
# read -p "Введите координаты точки (в формате x,y):" point_coords
# read -p "Введите радиус сектора обзора (R):" R
# read -p "Введите угол обзора (α):" alpha
# read -p "Введите угол азимута (θ):" theta

# # Разделяем координаты РЛС и точки на отдельные переменные
# rls_x=$(echo $rls_coords | cut -d',' -f1)
# rls_y=$(echo $rls_coords | cut -d',' -f2)
# point_x=$(echo $point_coords | cut -d',' -f1)
# point_y=$(echo $point_coords | cut -d',' -f2)

# # Вычисляем расстояние от РЛС до точки
# distance=$(echo "sqrt(($point_x-$rls_x)^2+($point_y-$rls_y)^2)" | bc)
# echo "$distance"

# # Вычисляем азимут между точкой и РЛС
# # azimuth=$(echo "scale=6; a( ($point_y-$rls_y) / ($point_x-$rls_x) )" | bc -l)
# # azimuth=$(echo "scale=6; a( $(echo $point_y-$rls_y | bc -l) / $(echo $point_x-$rls_x | bc -l) ) + (${point_x}-${rls_x} < 0)*${pi}" | bc -l)
# azimuth=$(echo "scale=6; s(($point_y-$rls_y)/$distance)/c(($point_x-$rls_x)/$distance) + (${point_x}-${rls_x} < 0)*${pi}/2" | bc -l)
# echo "азимут в радианах $azimuth"
# if [ $(echo "$azimuth<0"|bc -l) -eq 1 ]
# then
# # echo "Inside"
# azimuth=$(echo "scale=6; $azimuth+2*$pi" | bc -l)
# fi
# azimuth=$(echo "$(echo "$azimuth*180/$pi" | bc -l)")
# echo "азимут в градусах $azimuth"

# # if [[ $distance -le $R && $azimuth -ge $(echo "$theta-$alpha/2" | bc) ]]
# # if [ $(echo "$distance<=$R"|bc -l) -eq 1 ] && [ $(echo "$azimuth>=($theta-$alpha/2)"|bc -l) -eq 1 ] && [ $(echo "$azimuth<=($theta+$alpha/2)"|bc -l) -eq 1 ]
# # if [[ $distance -le $R && $(echo "$theta-$alpha/2" | bc -l) -le $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(s($theta)/c($theta))" | bc -l) && $(echo "$theta+$alpha/2" | bc -l) -ge $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(s($theta)/c($theta))" | bc -l) ]]
# # if [[ $distance -le $R && $(printf "%.20f" $(echo "$theta-$alpha/2" | bc -l)) -le $(printf "%.20f" $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(s($theta)/c($theta))" | bc -l)) && $(printf "%.20f" $(echo "$theta+$alpha/2" | bc -l)) -ge $(printf "%.20f" $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(s($theta)/c($theta))" | bc -l)) ]]
# if [[ $distance -le $R && $(printf "%.8f" $(echo "$theta-$alpha/2" | bc -l)) -le $(printf "%.8f" $(echo "a(s(($point_y-$rls_y)/$distance)/c(($point_x-$rls_x)/$distance))*180/$pi-$theta" | bc -l)) && $(printf "%.8f" $(echo "$theta+$alpha/2" | bc -l)) -ge $(printf "%8f" $(echo "a(s(($point_y-$rls_y)/$distance)/c(($point_x-$rls_x)/$distance))*180/$pi-$theta" | bc -l)) ]]
# then
# echo "Лежит"
# else
# echo "Не лежит"
# fi

# # Проверяем, находится ли точка внутри сектора обзора
# # if [[ $distance -le $R && $(echo "$theta-$alpha/2" | bc) -le $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(tan($theta))" | bc -l) && $(echo "$theta+$alpha/2" | bc) -ge $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(tan($theta))" | bc -l) ]]
# # then
# # echo "Точка находится внутри сектора обзора РЛС"
# # else
# # echo "Точка не находится внутри сектора обзора РЛС"
# # fi


# # if [[ $distance -le $R && $(echo "$azimuth" | bc) -le $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(tan($theta))" | bc -l) && $(echo "$theta+$alpha/2" | bc) -ge $(echo "a($point_y-$rls_y)/($point_x-$rls_x)-a(tan($theta))" | bc -l) ]]
# # then
# # echo "Точка находится внутри сектора обзора РЛС"
# # else
# # echo "Точка не находится внутри сектора обзора РЛС"
# # fi


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

# Примеры использования функции atan2
echo "$(atan2 1 1)" # 0.7853981634
echo "$(atan2 -1 -1)" # -2.3561944902
echo "$(atan2 1 0)" # 1.5707963268