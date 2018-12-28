#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
Chemin_complet=$(echo "$1")
Extension=$(echo "$Chemin_complet" | rev | cut -d'.' -f1 | rev)

/opt/RPI2JAMMA/RPI2JAMMA_Change_hdmi_timings.sh Amiberry

if [ "$Extension" == "lha" ] || [ "$Extension" == "LHA" ]
then
 Cde_whdload="-autowhdload="
fi

#lancement amiberry
echo 10 >/dev/rpi2x-intf
cd /opt/RPI2JAMMA/emulateurs/amiberry
Machine_model=$(dmesg | grep "Machine model:" | cut -d':' -f4)

if grep -q "Pi 3" <<< "$Machine_model" ; then
./amiberry-rpi3-sdl2 "$Cde_whdload$1"
else
./amiberry-rpi2-sdl2 "$Cde_whdload$1"
fi
echo 0 >/dev/rpi2x-intf
sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game none -modeline_list /opt/RPI2JAMMA/configs/modeline.txt

clear
tput reset

sync

exit 0
