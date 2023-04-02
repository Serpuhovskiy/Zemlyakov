log_file="log.txt"
date=`date +"%T"`
system=$2
maybeDestroyed="maybeDestroyedTargets_$system.txt"
main_log="mainLog.txt"
> "$maybeDestroyed"

dirname="/tmp/GenTargets/Destroy"

num=$(head -n 1 "bk_$system.txt")

if [ "$num" -gt 0 ]; then
    echo "$system Стрельба по цели с ID:$1"
    echo "$date $system: Стрельба по цели с ID:$1" >> "$log_file"
    echo -e "$1" >> "$maybeDestroyed"
    touch "$dirname/$1"
    new_num=$((num-1))
    echo "$new_num" > "bk_$system.txt"
else
    echo "ПЕРЕЗАРЯДКА $system"
    echo "$date $system: ПЕРЕЗАРЯДКА"
    if [ "$system" == "ZRDN_1" ] || [ "$system" == "ZRDN_2" ] || [ "$system" == "ZRDN_3" ]; then
        echo "20" > "bk_$system.txt"
    else
        echo "10" > "bt_$system.txt"
    fi
fi
