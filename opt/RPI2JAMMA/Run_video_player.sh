#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
#On efface l'ecran
Chemin_complet=$(echo "$1")
/opt/RPI2JAMMA/RPI2JAMMA_Change_hdmi_timings.sh Video_player
clear
echo 7 >/dev/rpi2x-intf
omxplayer -b "$Chemin_complet"  </dev/tty &>>/dev/null
echo 0 >/dev/rpi2x-intf
exit 0
