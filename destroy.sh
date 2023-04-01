log_file="log.txt"
date=`date +"%T"`
system=$2
maybeDestroyed="maybeDestroyedTargets_$system.txt"
> "$maybeDestroyed"

dirname="/tmp/GenTargets/Destroy"
echo "$system Стрельба по цели с ID:$1"
echo "$date $system: Стрельба по цели с ID:$1" >> "$log_file"
echo -e "$1" >> "$maybeDestroyed"
touch "$dirname/$1"