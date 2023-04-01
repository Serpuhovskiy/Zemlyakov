#!/bin/bash

cat "maybeDestroyedTargets.txt" | while read line; do
    # echo "строка: $line"
    isMaybeDestroyedInCurrent=`grep -c "$line" "currentTargets.txt"`
    if [ $isMaybeDestroyedInCurrent -eq 0 ]; then
        # removeString "$line" "$maybeDestroyed"
        echo -e "\033[32m          Цель $line была уничтожена на предыдущем шаге           \033[0m"
    fi
done

# filename="maybeDestroyedTargets.txt"

# while read line; do
#     echo "qwqw $line"
# done < $filename