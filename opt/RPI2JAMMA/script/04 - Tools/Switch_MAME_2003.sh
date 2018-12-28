#!/usr/bin/env bash
######################
## RPI2XXXXX aje_fr ##
######################
sed -i 's/mame2003_plus_libretro/mame2003_libretro/g' /opt/RPI2JAMMA/Run_emulateur.sh
sed -i 's/mame2003_plus_libretro/mame2003_libretro/g' /home/pi/Carte_SD_Finale/home/pi/.emulationstation/es_systems.cfg.yoko
sed -i 's/mame2003_plus_libretro/mame2003_libretro/g' /home/pi/Carte_SD_Finale/home/pi/.emulationstation/es_systems.cfg.tate

