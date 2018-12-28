#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
Nom_ROM_ZIP=$(basename "$1")
Nom_ROM=$(basename "$1" .daphne)
Repertoire_ZIP=$(dirname "$1")
Sous_repertoire=$(basename "$Repertoire_ZIP")
Fichier_command="$1/$Nom_ROM.commands"
if [ -f $Fichier_command ]
then
Command=$(cat "$Fichier_command")
fi

/opt/RPI2JAMMA/RPI2JAMMA_Change_hdmi_timings.sh Daphne

cd /opt/RPI2JAMMA/emulateurs/daphne
export DAPHNE_DIR=/opt/RPI2JAMMA/emulateurs/daphne
./daphne "$Nom_ROM" vldp -framefile "$1/$Nom_ROM.txt" -homedir "/opt/RPI2JAMMA/emulateurs/hypseus" -nohwaccel -fastboot -fullscreen $Command </dev/tty &>>/dev/null
sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game none -modeline_list /opt/RPI2JAMMA/configs/modeline.txt

sleep 1

clear
tput reset

sync

exit 0
