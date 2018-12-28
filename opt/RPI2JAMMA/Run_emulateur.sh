#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
clear
Chemin_complet=$(echo "$1")
Nom_ROM_ZIP=$(basename "$1")
Nom_ROM=$(echo "$1" | rev | cut -d'.' -f2 | cut -d'/' -f1 | rev)
Nom_extension=$(echo "$1" | rev | cut -d'.' -f1 | rev)
Repertoire_ZIP=$(dirname "$1")
Nom_core="$2"
Fichier_roms_mame2010="$Repertoire_ZIP/_mame2010_roms.txt"
Fichier_roms_fba2012="$Repertoire_ZIP/_fba2012_roms.txt"
Sous_repertoire_rom=$(basename "$Repertoire_ZIP" "/media/usb/roms/")
Repertoire_lancement="."

#Le fichier de la modeline est a la racine du dossier rom
#le sous répertoire image est aussi a la racine du dossier rom
Repertoire_modeline=$(dirname "$1")
Nb_slash=$(echo "$Repertoire_modeline" | grep -o "/" | wc -l)
while [ "$Nb_slash" -ne "4" ]; do
Repertoire_modeline=$(dirname "$Repertoire_modeline")
Nb_slash=$(echo "$Repertoire_modeline" | grep -o "/" | wc -l)
done
Repertoire_image=$Repertoire_modeline
Fichier_modeline="$Repertoire_modeline/modeline.txt"
Fichier_gamelist="$Repertoire_modeline/gamelist.xml"

#On verifie si le core existe
if [ ! -f "/opt/RPI2JAMMA/retroarch/cores/$Nom_core/$Nom_core.so" ]
then
 clear
 exit 0
fi

#On efface l'ecran
setterm -term linux -back black -fore black -clear all
tput civis
tput reset
clear

reso="-run15khz"
if grep -q "RPI2NUC" /proc/bus/input/devices
then
 if [ ! -f "/media/usb/Config_RPI2XXXXX/rpi2nuc_video.txt" ]
 then
   reso=""
 else
  force_15k=$(cat "/media/usb/Config_RPI2XXXXX/RPI2NUC_video.txt" | grep "^run_in_15khz" | cut -d'=' -f2)
  if [ "$force_15k" == "true" ]
   then
    reso="-run15khz"
   else
    reso=""
   fi
 fi
fi

#On verifie si on doit lancer mame2010 a la place de 2003
if [ $Nom_core == "mame2003_libretro" ]
then
 Fichier_tate_inverse="$Repertoire_modeline/reversed_games_list_mame2003.txt"
fi
if [ $Nom_core == "mame2003_libretro" ] && [ -f "$Fichier_roms_mame2010" ]
then
 if grep -q "^$Nom_ROM_ZIP" $Fichier_roms_mame2010
 then
   Nom_core="mame2010_libretro"
   Fichier_tate_inverse="$Repertoire_modeline/reversed_games_list_mame2010.txt"
 fi
fi
if [ $Nom_core == "mame2003_libretro" ]
then
 Fichier_modeline="$Repertoire_modeline/modeline_mame2003.txt"
fi
if [ $Nom_core == "mame2010_libretro" ]
then
 Fichier_modeline="$Repertoire_modeline/modeline_mame2010.txt"
fi

#On verifie si on doit lancer fba2012
if [ $Nom_core == "fbalpha_libretro" ]
then
 Fichier_tate_inverse="$Repertoire_modeline/reversed_games_list_fba.txt"
fi
if [ $Nom_core == "fbalpha_libretro" ] && [ -f "$Fichier_roms_fba2012" ]
then
 if grep -q "^$Nom_ROM_ZIP" $Fichier_roms_fba2012
 then
   Nom_core="fbalpha2012_libretro"
   Fichier_modeline="$Repertoire_modeline/modeline_fba2012.txt"
   Fichier_tate_inverse="$Repertoire_modeline/reversed_games_list_fba2012.txt"
 fi
fi

#Pour la liste tate inversée
option_tate_inverse=""
if [ -f "$Fichier_tate_inverse" ] && [ -n "$Fichier_tate_inverse" ]
then
 option_tate_inverse="-tate_reversed_list $Fichier_tate_inverse"
 echo "fichier trouvé"
fi

#On verifie si on lance un jeu mastersystem ou autre SEGA
if [ $Nom_core == "picodrive_libretro" ]
then
  sudo rm -f /opt/RPI2JAMMA/retroarch/config/PicoDrive/PicoDrive.cfg
  if [ $Repertoire_ZIP == "/media/usb/roms/sms" ]
  then
   sudo ln -s /opt/RPI2JAMMA/retroarch/config/PicoDrive/PicoDrive.cfg_2btn /opt/RPI2JAMMA/retroarch/config/PicoDrive/PicoDrive.cfg
  else
   sudo ln -s /opt/RPI2JAMMA/retroarch/config/PicoDrive/PicoDrive.cfg_6btn /opt/RPI2JAMMA/retroarch/config/PicoDrive/PicoDrive.cfg
  fi
fi

#On verifie si on lance un jeu sg1000 ou autre SEGA megadrive ou segacd
if [ $Nom_core == "genesis_plus_gx_libretro" ]
then
  sudo rm -f /opt/RPI2JAMMA/retroarch/config/Genesis\ Plus\ GX/Genesis\ Plus\ GX.cfg
  if [ $Repertoire_ZIP == "/media/usb/roms/sg1000" ]
  then
   sudo ln -s /opt/RPI2JAMMA/retroarch/config/Genesis\ Plus\ GX/Genesis\ Plus\ GX.cfg_2btn /opt/RPI2JAMMA/retroarch/config/Genesis\ Plus\ GX/Genesis\ Plus\ GX.cfg
  else
   sudo ln -s /opt/RPI2JAMMA/retroarch/config/Genesis\ Plus\ GX/Genesis\ Plus\ GX.cfg_6btn /opt/RPI2JAMMA/retroarch/config/Genesis\ Plus\ GX/Genesis\ Plus\ GX.cfg
  fi
fi

#On verifie si on lance un jeu colecovision ou msx
if [ $Nom_core == "bluemsx_libretro" ]
then
  System_directory_actuel=$(cat /opt/RPI2JAMMA/retroarch/config/blueMSX/blueMSX.cfg | grep "system_directory")
  if ! grep -q "$Repertoire_ZIP" /opt/RPI2JAMMA/retroarch/config/blueMSX/blueMSX.cfg
  then
   sed -i "s+$System_directory_actuel+system_directory=\"$Repertoire_ZIP\"+g" /opt/RPI2JAMMA/retroarch/config/blueMSX/blueMSX.cfg
  fi
  machine_type_actuel=$(cat /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg | grep "bluemsx_msxtype")
  if [ $Repertoire_ZIP == "/media/usb/roms/msx" ]
  then
	if [[ "$machine_type_actuel" == *"ColecoVision"* ]]
	then
		sed -i "s+$machine_type_actuel+bluemsx_msxtype=\"Auto\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	fi
  else
	if [[ "$machine_type_actuel" != *"ColecoVision"* ]]
	then
		sed -i "s+$machine_type_actuel+bluemsx_msxtype=\"ColecoVision\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	fi
  fi
fi

#Pour la PSX, verification si les manettes sont analogiques ou non
if [ $Nom_core == "pcsx_rearmed_libretro" ]
then
	Mode_pad0=$(cat /dev/rpi2x-intf | grep "Mode_pad0" | cut -d'=' -f2)
	Mode_pad1=$(cat /dev/rpi2x-intf | grep "Mode_pad1" | cut -d'=' -f2)
	if [ $Mode_pad0 == "2" ] || [ $Mode_pad0 == "3" ]
	then
		sed -i "s+pcsx_rearmed_pad1type = \"default\"+pcsx_rearmed_pad1type = \"analog\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	else
		sed -i "s+pcsx_rearmed_pad1type = \"analog\"+pcsx_rearmed_pad1type = \"default\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	fi
	if [ $Mode_pad1 == "2" ] || [ $Mode_pad1 == "3" ]
	then
		sed -i "s+pcsx_rearmed_pad2type = \"default\"+pcsx_rearmed_pad2type = \"analog\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	else
		sed -i "s+pcsx_rearmed_pad2type = \"analog\"+pcsx_rearmed_pad2type = \"default\"+g" /opt/RPI2JAMMA/retroarch/retroarch-core-options.cfg
	fi
fi

#On verifie si on doit changer le repertoire courant
if [ $Nom_core == "px68k_libretro" ] || [ $Nom_core == "hatari_libretro" ] || [ $Nom_core == "bluemsx_libretro" ]
then
   Repertoire_lancement=$Repertoire_ZIP
fi

#Changement des controles si nécessaires
echo 0 >/dev/rpi2x-intf
if [ $Nom_core == "cap32_libretro" ]
then
	echo 3 >/dev/rpi2x-intf
fi
if [ $Nom_core == "hatari_libretro" ]
then
	echo 2 >/dev/rpi2x-intf
fi
if [ $Nom_core == "px68k_libretro" ]
then
   echo 9 >/dev/rpi2x-intf
fi

#On lance snes9x2005_libretro à la place de snes9x2010_libretro sur RPI2NUC vga
if [ $Nom_core == "snes9x2010_libretro" ] && [ -z "$reso" ]
then
 if grep -q "RPI2NUC" /proc/bus/input/devices
 then
 Nom_core="snes9x2005_libretro"
 fi
fi

#Verification GC2
Type_pad=$(cat /dev/rpi2x-intf | grep "Type_pad" | cut -d'=' -f2)
if [ $Type_pad == "221" ]
then
echo 5 >/dev/rpi2x-intf
sudo fbi -t 10s -a -noverbose "/opt/RPI2JAMMA/img/Calib_gun.png" </dev/tty &>>/dev/null
echo 0 >/dev/rpi2x-intf
fi
if [ $Type_pad == "204" ] || [ $Type_pad == "221" ]
then
sed -i 's+input_libretro_device_p2 = "1"+input_libretro_device_p2 = "2"+g' /opt/RPI2JAMMA/retroarch/config/FCEUmm/FCEUmm.cfg
sed -i 
else
sed -i 's+input_libretro_device_p2 = "2"+input_libretro_device_p2 = "1"+g' /opt/RPI2JAMMA/retroarch/config/FCEUmm/FCEUmm.cfg
fi

#Interactive header
sudo killall fbi </dev/tty &>>/dev/null
if [ -c /dev/fb1 ]; then
 if [ -f "$Fichier_gamelist" ]
 then
  Nom_image_gamelist=$(awk '/\/'$Nom_ROM_ZIP'</path>/,/<\/image>/' $Fichier_gamelist | grep "image" | cut -d'<' -f2 | cut -d'>' -f2)
  if [ -f "$Repertoire_image/$Nom_image_gamelist" ]
  then
    sudo fbi -T 5 -a -d /dev/fb1 -noverbose -t 3s "/opt/RPI2JAMMA/img/RPI2JAMMA_now_playing.jpg" "$Repertoire_image/$Nom_image_gamelist" </dev/tty &>>/dev/null
  fi
 else
  if [ -f "/home/pi/.emulationstation/downloaded_images/$Sous_repertoire_rom/$Nom_ROM-image.png" ]
  then
    sudo fbi -T 5 -a -d /dev/fb1 -noverbose -t 3s "/opt/RPI2JAMMA/img/RPI2JAMMA_now_playing.jpg" "/home/pi/.emulationstation/downloaded_images/$Sous_repertoire_rom/$Nom_ROM-image.png" </dev/tty &>>/dev/null
  elif [ -f "/home/pi/.emulationstation/downloaded_images/$Sous_repertoire_rom/$Nom_ROM-image.jpg" ]
  then
    sudo fbi -T 5 -a -d /dev/fb1 -noverbose -t 3s "/opt/RPI2JAMMA/img/RPI2JAMMA_now_playing.jpg" "/home/pi/.emulationstation/downloaded_images/$Sous_repertoire_rom/$Nom_ROM-image.jpg" </dev/tty &>>/dev/null
  fi #png/jpg
 fi #gamelist
fi #fb1

#On verifie l'existence du fichier de modeline
if [ ! -f "$Fichier_modeline" ]
then
 # echo "Pas de fichier modeline"
 if [ $Nom_core != "gambatte_libretro" ]
 then
   fbi -noverbose -t 1s --once /opt/RPI2JAMMA/modeline-off.png
 fi
 cd "$Repertoire_lancement"
 sudo retroarch --config /opt/RPI2JAMMA/retroarch/retroarch.cfg --libretro /opt/RPI2JAMMA/retroarch/cores/$Nom_core/$Nom_core.so "$Chemin_complet" </dev/tty &>>/dev/null
 clear
 tput reset
 sync
 exit 0
fi
#Changement res
if grep -q "^$Nom_ROM_ZIP;" $Fichier_modeline
then
 # echo "Jeu trouve"
 sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game $Chemin_complet -modeline_list $Fichier_modeline $reso $option_tate_inverse
elif grep -q "^_ALL_;" $Fichier_modeline
then
 # echo "all trouve"
 sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game "_ALL_" -modeline_list $Fichier_modeline $reso $option_tate_inverse
else
 # echo "all non trouve"
 fbi -noverbose -t 1s --once /opt/RPI2JAMMA/modeline-off.png
 sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game $Chemin_complet -modeline_list $Fichier_modeline $reso $option_tate_inverse
fi

#echo "On lance retroarch"
cd "$Repertoire_lancement"

sudo retroarch --config /opt/RPI2JAMMA/retroarch/retroarch.cfg --libretro /opt/RPI2JAMMA/retroarch/cores/$Nom_core/$Nom_core.so "$Chemin_complet" </dev/tty &>>/dev/null

clear
tput reset
sync
cd /opt/RPI2JAMMA/
sudo /opt/RPI2JAMMA/RPI2JAMMA_Change_res -game none -modeline_list /opt/RPI2JAMMA/configs/modeline.txt

#Au cas ou retroarch ai plante
if [ -n 'ps -all | grep "retroarch"' ]
then
  sudo killall -s SIGKILL retroarch  </dev/tty &>>/dev/null
fi

clear
tput reset

sync

#Interactive header
sudo killall fbi </dev/tty &>>/dev/null
if [ -c /dev/fb1 ]; then
  sudo fbi -T 5 -a -d /dev/fb1 -noverbose -t 2s "/opt/RPI2JAMMA/img/RPI2JAMMA_please_select.jpg"
fi

echo 0 >/dev/rpi2x-intf

exit 0
