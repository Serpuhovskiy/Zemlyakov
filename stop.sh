#!/bin/bash

# Массив всех скриптов
scripts=(start GenTargets RLS_1 RLS_2 RLS_3 SPRO ZRDN_1 ZRDN_2 ZRDN_3 KP movementToSPRO destroy)


for script in "${scripts[@]}"
do
  # Получаем список PID всех процессов, связанных с файлами в текущей папке
  pids=$(ps aux | grep "$script.sh" | grep -v grep | awk '{print $2}')

  if [ -n "$pids" ]; then
    # Останавливаем все процессы, соответствующие текущему скрипту
    kill $pids
    echo "pids: $pids"
    echo "Скрипт $script.sh остановлен"
  else
    echo "Скрипт $script.sh не запущен"
  fi
done

echo "ВСЕ ПРОЦЕССЫ ОСТАНОВЛЕНЫ"