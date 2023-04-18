#!/bin/bash

# Файл главного лога
main_log="logs/mainLog.txt"

# Переменные для данных, которые записываем в БД
system=$1
date=$2
target_id=$3
action=$4


# Переменная для имени базы данных
DB_FILE="db/$system.db"

# Сообщение, которое записываем в главный лог
message=$5

echo "$message" >> "$main_log"

echo "=================================="
echo "$system, $date, $target_id, $action"
echo "=================================="

gnome-terminal -e "./checkSystemPerformance.sh"

# Проверяем существует ли уже база данных с таким именем
if [ ! -f "$DB_FILE" ]; then
    # Если база данных не существует, создаем ее
    sqlite3 "$DB_FILE" <<EOF
    CREATE TABLE $system (id INTEGER PRIMARY KEY, date TEXT, target_id INTEGER, action TEXT);
EOF
fi

# Вставляем данные в таблицу
sqlite3 "$DB_FILE" <<EOF
    INSERT INTO $system (date, target_id, action) VALUES ('$date', '$target_id', '$action');
EOF