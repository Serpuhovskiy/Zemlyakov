log_file="log.txt"
maybeDestroyed="maybeDestroyedTargets.txt"
# > "$maybeDestroyed"
date=`date +"%T"`

dirname="/tmp/GenTargets/Destroy"
echo "Стрельба по цели с ID:$1"
echo "$date SPRO: Стрельба по цели с ID:$1" >> "$log_file"
echo "Потенциально сбитая цель $1" >> "$maybeDestroyed"
touch "$dirname/$1"