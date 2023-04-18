#!/bin/bash

# Массив всех систем
systems=(RLS_1 RLS_2 RLS_3 SPRO ZRDN_1 ZRDN_2 ZRDN_3)

function check_state_system {
    # pid=`pgrep $1`
    # if [[ ($pid > 0) ]]
    # then
        file=`find "temp/$1_active.txt" 2>/dev/null` 
        if [ -f $file ]
        then
            echo "Устройство $1 в сети"
        else
            echo "Устройство $1 не отвечает"
            # echo "KP: Устройство $1 не отвечает!"

            rm "temp/$1_active.txt" 2>/dev/null
        fi
    # else
    #     data="Устройство не отвечает"
    # # fi

    # clock=`date +"%T"`
    # $sql_location $FILE_DB "INSERT INTO $table_state_name VALUES 
    #          (\"$clock\", \"$1\", \"$data\")"
}


while :
do
    for system in ${systems[@]}
    do
        check_state_system $system
    done
    



    sleep 2.5
done
