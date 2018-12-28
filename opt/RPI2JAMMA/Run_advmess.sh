#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
Nom_ROM_ZIP=$(basename "$1")
Nom_ROM=$(basename "$1" .zip)
Repertoire_ZIP=$(dirname "$1")
setterm -term linux -back black -fore black -clear all
tput civis
tput reset
advmess $Nom_ROM
clear
tput reset
sync
exit 0
