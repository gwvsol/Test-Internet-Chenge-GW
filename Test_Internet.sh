#!/bin/bash
# ===========================================================
host=google.com
gw1="DD-WRT" # имена и IP адреса необходимо прописать в /etc/hosts
gw2="ASUS"
log="/var/log/Test_Internet.log"

# =============== Сообщения для LOG файла ===================
Gateway1="Интернет $gw1"
Gateway2="Интернет $gw2"
SwitchGW1="Переключаем интернет на $gw1"
CHeckInetGW1="Проверяем доступность интернета на $gw1"
OnLine="Интернет доступен"
NoGw1SwGW2="Интернет не дотупен, переключаем на $gw2"
CHeckInetGW2="Проверяем доступность интернета на $gw2"
NoGW2="Интернет на $gw2 не доступен"
# ============================================================

# =========== Основная функция скрипта =======================
# Проверяем на каком шлюзе включен интернет
ifgw()
{
dgw=($(route | grep default | awk '{print $2}'))

# Если GW1 проверяем интернет, если доступен выход из проверки
# Если не доступен, перелючаем на GW2
if [ $dgw == $gw1 ] ; then
    echo $(date +'%d-%m-%Y %T') "$Gateway1" >> $log
    echo "$Gateway1"
    testInternet
    chengGW2
fi
# Если включен GW2, возращаем на GW1 и проверяем доступность интернета
# Если на GW1 интернет вновь доступен, выход из проверки
# Если на GW1 интернет не досупен, возращаем на GW2
if [ $dgw == $gw2 ] ; then
    echo $(date +'%d-%m-%Y %T') "$Gateway2" >> $log
    #echo "$Gateway2"
    echo $(date +'%d-%m-%Y %T') "$SwitchGW1" >> $log
    #echo "$SwitchGW1"
    # Удаляем GW2 
    route del default gw $gw2
    # Добавляем GW1
    route add default gw $gw1
    echo $(date +'%d-%m-%Y %T') "$CHeckInetGW1" >> $log
    #echo "$CHeckInetGW1"
    testInternet
    chengGW2
fi
}
# ============================================================

# ============= Проверка доступности интернета ===============
# Проверяем 10 раз и ограничиваем время проверки 30 секндами
testInternet()
{
    ping $host -c 10 -w 30 &>/dev/null
    rezTest=$?
}
# ============================================================

# === Переключение на GW2 и проверка доступности интернета ===
# Используется если интернет по GW1 не доступен
# Переключем на GW2
chengGW2()
{
if [[ $rezTest -eq 0 ]]; then
    # Если интернет на GW1 доступен, выходим из скрипта
    echo $(date +'%d-%m-%Y %T') "$OnLine" >> $log
    #echo "$OnLine"
    exit 0
else
    # Если не доступен...
    echo $(date +'%d-%m-%Y %T') "$NoGw1SwGW2" >> $log
    #echo "$NoGw1SwGW2"
    # Удаляем GW1
    route del default gw $gw1
    # Добавляем GW2 и проверяем наличие интернета на GW2
    route add default gw $gw2
    echo $(date +'%d-%m-%Y %T') "$CHeckInetGW2" >> $log
    #echo "$CHeckInetGW2"
    testInternet
if [[ $rezTest -eq 0 ]]; then
    echo $(date +'%d-%m-%Y %T') "$OnLine" >> $log
    #echo "$OnLine"
    exit 0
else
    echo $(date +'%d-%m-%Y %T') "$NoGW2" >> $log
    #echo "$NoGW2"
    exit 1
fi
fi
}
# ===========================================================

# ============== Запуск работы скрипта ======================
ifgw
# ===========================================================

