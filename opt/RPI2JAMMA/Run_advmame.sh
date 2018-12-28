#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
#Changement du freeplay sur rpi2scart
if grep -q "RPI2SCART" /proc/bus/input/devices
then
 #rpi2scart
 sed -i 's/misc_freeplay no/misc_freeplay yes/g' /home/pi/.advance/advmame.rc
else
 #rpi2jamma / rpi2nuc
 sed -i 's/misc_freeplay yes/misc_freeplay no/g' /home/pi/.advance/advmame.rc
fi

Nom_ROM_ZIP=$(basename "$1")
Nom_ROM=$(basename "$1" .zip)
Repertoire_ZIP=$(dirname "$1")
setterm -term linux -back black -fore black -clear all
tput civis
tput reset
advmame $Nom_ROM
clear
tput reset
sync
exit 0
