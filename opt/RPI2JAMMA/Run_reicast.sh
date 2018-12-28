#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
Chemin_complet=$(echo "$1")
/opt/RPI2JAMMA/RPI2JAMMA_Change_hdmi_timings.sh Reicast
#lancement reicast
echo 11 >/dev/rpi2x-intf
cd /opt/RPI2JAMMA/emulateurs/reicast
./reicast.elf "$Chemin_complet" </dev/tty &>>/dev/null
echo 0 >/dev/rpi2x-intf
sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game none -modeline_list /opt/RPI2JAMMA/configs/modeline.txt
sudo killall reicast
clear
tput reset
sync
exit 0
