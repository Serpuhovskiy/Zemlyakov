#!/bin/bash

system="SPRO"

# Переменная для имени базы данных
DB_FILE="db/$system.db"

# # Файл главного лога
# main_log="logs/mainLog.txt"

# system=$1
# message=$2

# echo "$message" >> "$main_log"

# Проверяем существует ли уже база данных с таким именем
if [ ! -f "$DB_FILE" ]; then
    # Если база данных не существует, создаем ее
    sqlite3 "$DB_FILE" <<EOF
    CREATE TABLE $system (id INTEGER PRIMARY KEY, time TEXT, target_id INTEGER, target_type TEXT, action TEXT);
EOF
fi

# Переменные для данных, которые мы хотим записать в таблицу
time="12.07.2001"
target_id="a1b2c3"
target_type="ББ БР"
action="УНИЧТОЖЕНА"

# Вставляем данные в таблицу
sqlite3 "$DB_FILE" <<EOF
    INSERT INTO $system (time, target_id, target_type, action) VALUES ('$time', '$target_id', '$target_type', '$action');
EOF