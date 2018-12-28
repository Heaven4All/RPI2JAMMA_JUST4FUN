#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
Nom_ROM_ZIP=$(basename "$1")
Nom_ROM=$(basename "$1" .zip)
Repertoire_ZIP=$(dirname "$1")
Nom_jeu=$(cat "$1")

/opt/RPI2JAMMA/RPI2JAMMA_Change_hdmi_timings.sh Scummvm

#scummvm --themepath=/usr/share/scummvm -f --joystick=0 -p "$Repertoire_ZIP" "$Nom_jeu"
scummvm -f --joystick=0 -p "$Repertoire_ZIP" "$Nom_jeu"
sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game none -modeline_list /opt/RPI2JAMMA/configs/modeline.txt

clear
tput reset

sync

exit 0
