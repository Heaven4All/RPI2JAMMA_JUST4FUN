#!/usr/bin/env bash
Repertoire_def="/opt/RPI2JAMMA/Repertoire_usb/"

##########################################################################
########################VERIFICATION CLE##################################
##########################################################################
for dev in $(ls -r /dev/sda*); do
 type_fs=$(sudo blkid -o value -s TYPE $dev)
 #echo "Type fs = $type_fs"
 if [ "$type_fs" == "exfat" ] || [ "$type_fs" == "ntfs" ] || [ "$type_fs" == "vfat" ]; then
  case "$type_fs" in
  "exfat")
    option="noexec,nodev,noatime,nodiratime,uid=1000,gid=1000,sync"
    ;;
  "ntfs")
    option="rw,noexec,nodev,noatime,nodiratime,umask=0,uid=1000,gid=1000"
    ;;
  "vfat")
    option="rw,noexec,nodev,noatime,nodiratime,umask=0,uid=1000,gid=1000"
    ;;
  *)
    option="ro"
    ;;
  esac
  #echo "Montage de $dev avec les options $option"
  sudo mount -o $option $dev /media/usb </dev/tty &>>/dev/null
  if [ $? -eq 0 ]; then
   break
  fi
 fi
done
Etat_cle=$(mount | grep "/media/usb")
if [ -z "$Etat_cle" ]
then
 sudo killall fbi > /dev/null 2>&1
 sudo fbi -t 5s -noverbose --once /opt/RPI2JAMMA/no-usb.png
else
 #On copie les fichiers si ils n'existent pas
 #Ca evite les plantages de emulationstation si aucun répertoire n'existe
 #echo "Lancement de rsync"
 rsync -ru --no-owner --no-group $Repertoire_def/* /media/usb/
fi


##############################################################################
########################VERIFICATION SYSTEME##################################
##############################################################################
Doit_reboot=0
Mode_video_actuel=$(cat /boot/config.txt | grep "^hdmi_timings")
framebuffer_x_actuel=$(cat /boot/config.txt | grep "^framebuffer_width")
framebuffer_y_actuel=$(cat /boot/config.txt | grep "^framebuffer_height")
val_framebuffer_x_actuel=$(cat /boot/config.txt | grep "^framebuffer_width" | cut -d'=' -f2)
val_framebuffer_y_actuel=$(cat /boot/config.txt | grep "^framebuffer_height" | cut -d'=' -f2)
rotation_config=$(cat /boot/config.txt | grep "display_rotate" | cut -d'=' -f2)
Largeur_actuelle=$(echo $Mode_video_actuel | cut -d'=' -f2 | cut -d' ' -f1)
Hauteur_actuelle=$(echo $Mode_video_actuel | cut -d'=' -f2 | cut -d' ' -f6)
Fichier_autoboot="/media/usb/Config_RPI2XXXXX/autoboot.txt"

if [ ! -f "/media/usb/Config_RPI2XXXXX/Video_output_cga.txt" ]
then
 Mode_video_cga=$(cat /opt/RPI2JAMMA/Repertoire_usb/Config_RPI2XXXXX/Video_output_cga.txt | grep "^default" | cut -d';' -f2)
else
 Mode_video_cga=$(cat /media/usb/Config_RPI2XXXXX/Video_output_cga.txt | grep "^default" | cut -d';' -f2)
fi
Largeur_cga=$(echo $Mode_video_cga | cut -d'=' -f2 | cut -d' ' -f1)
Hauteur_cga=$(echo $Mode_video_cga | cut -d'=' -f2 | cut -d' ' -f6)

if [ ! -f "/media/usb/Config_RPI2XXXXX/Video_output_vga.txt" ]
then
 Mode_video_vga=$(cat /opt/RPI2JAMMA/Repertoire_usb/Config_RPI2XXXXX/Video_output_vga.txt | grep "^default" | cut -d';' -f2)
else
 Mode_video_vga=$(cat /media/usb/Config_RPI2XXXXX/Video_output_vga.txt | grep "^default" | cut -d';' -f2)
fi
Largeur_vga=$(echo $Mode_video_vga | cut -d'=' -f2 | cut -d' ' -f1)
Hauteur_vga=$(echo $Mode_video_vga | cut -d'=' -f2 | cut -d' ' -f6)

Version_HW_hex=$(cat /proc/bus/input/devices | grep "Bus=0019" | grep "Product=0001" | cut -d"=" -f5)
Version_HW="$(echo "ibase=16; ${Version_HW_hex^^}" | bc)"

dpi_output_format_actuel=$(cat /boot/config.txt | grep "^dpi_output_format" | cut -d'=' -f2)
dpi_output_format_v1="24853"
# dpi_output_format_v2="24854"
dpi_output_format_v2="24342"
dpi_output_format_rpi2nuc="4118"

#Verification overlay
if [ "$Version_HW" -ge "20" ]
then
 if grep -q "rpi2jamma_aje_fr-overlay_v1" /boot/config.txt
 then
  sudo sed -i 's/rpi2jamma_aje_fr-overlay_v1/rpi2jamma_aje_fr-overlay_v2/g' /boot/config.txt
  Doit_reboot=1
 fi
else
 if grep -q "rpi2jamma_aje_fr-overlay_v2" /boot/config.txt
 then
  sudo sed -i 's/rpi2jamma_aje_fr-overlay_v2/rpi2jamma_aje_fr-overlay_v1/g' /boot/config.txt
  Doit_reboot=1
 fi
fi

#Verification output_format
if grep -q "RPI2NUC" /proc/bus/input/devices
then
 if [ "$dpi_output_format_actuel" != "$dpi_output_format_rpi2nuc" ]
 then
  sudo sed -i "s/dpi_output_format=$dpi_output_format_actuel/dpi_output_format=$dpi_output_format_rpi2nuc/g" /boot/config.txt
  Doit_reboot=1
 fi
else
 #rpi2jamma rpi2scart
 if [ "$Version_HW" -ge "20" ]
 then
  if [ "$dpi_output_format_actuel" != "$dpi_output_format_v2" ]
  then
   sudo sed -i "s/dpi_output_format=$dpi_output_format_actuel/dpi_output_format=$dpi_output_format_v2/g" /boot/config.txt
   Doit_reboot=1
  fi
 else
  if [ "$dpi_output_format_actuel" != "$dpi_output_format_v1" ]
  then
   sudo sed -i "s/dpi_output_format=$dpi_output_format_actuel/dpi_output_format=$dpi_output_format_v1/g" /boot/config.txt
   Doit_reboot=1
  fi
 fi
fi


#Verification taille affichage
reso="cga"
if grep -q "RPI2NUC" /proc/bus/input/devices
then
 if [ ! -f "/media/usb/Config_RPI2XXXXX/rpi2nuc_video.txt" ]
 then
   reso="vga"
 else
  force_15k=$(cat "/media/usb/Config_RPI2XXXXX/rpi2nuc_video.txt" | grep "^run_in_15khz" | cut -d'=' -f2)
  if [ "$force_15k" == "true" ]
   then
    reso="cga"
   else
    reso="vga"
   fi
 fi
fi

if [ "$reso" == "vga" ]
then
 #rpi2nuc
 if ! grep -q "$Mode_video_vga" /boot/config.txt; then
  sudo sed -i 's/video_shader_enable = "false"/video_shader_enable = "true"/g' /opt/RPI2JAMMA/retroarch/retroarch.cfg.ok
  sudo sed -i 's/'"$Mode_video_actuel"'/'"$Mode_video_vga"'/g' /boot/config.txt
  sudo mv -f /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-OFF.sh_ /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-OFF.sh
  sudo mv -f /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-ON.sh_ /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-ON.sh
  sudo sed -i 's/'"$framebuffer_x_actuel"'/framebuffer_width='"$Largeur_vga"'/g' /boot/config.txt
  sudo sed -i 's/'"$framebuffer_y_actuel"'/framebuffer_height='"$Hauteur_vga"'/g' /boot/config.txt
  Doit_reboot=1
 fi
else
 #rpi2jamma / rpi2scart
 if ! grep -q "$Mode_video_cga" /boot/config.txt; then
  sudo sed -i 's/video_shader_enable = "true"/video_shader_enable = "false"/g' /opt/RPI2JAMMA/retroarch/retroarch.cfg.ok
  sudo sed -i 's/'"$Mode_video_actuel"'/'"$Mode_video_cga"'/g' /boot/config.txt
  sudo mv -f /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-OFF.sh /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-OFF.sh_
  sudo mv -f /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-ON.sh /opt/RPI2JAMMA/script/03\ -\ Screen/Scanline-ON.sh_
  sudo sed -i 's/'"$framebuffer_x_actuel"'/framebuffer_width='"$Largeur_cga"'/g' /boot/config.txt
  sudo sed -i 's/'"$framebuffer_y_actuel"'/framebuffer_height='"$Hauteur_cga"'/g' /boot/config.txt
 Doit_reboot=1
 fi
fi

#Changement du nom réseau au cas où
if grep -q "RPI2SCART" /proc/bus/input/devices
then
 #rpi2scart
 if ! grep -q "RPI2SCART" /etc/hostname
 then
  sudo sh -c 'echo "RPI2SCART" > /etc/hostname'
  sudo hostname -b RPI2SCART
  Doit_reboot=1
 fi
fi

if grep -q "RPI2JAMMA" /proc/bus/input/devices
then
 #rpi2jamma
 if ! grep -q "RPI2JAMMA" /etc/hostname
 then
  sudo sh -c 'echo "RPI2JAMMA" > /etc/hostname'
  sudo hostname -b RPI2JAMMA
  amixer  sset PCM,1 100%
  Doit_reboot=1
 fi
fi

if grep -q "RPI2NUC" /proc/bus/input/devices
then
 #rpi2nuc
 if ! grep -q "RPI2NUC" /etc/hostname
 then
  sudo sh -c 'echo "RPI2NUC" > /etc/hostname'
  sudo hostname -b RPI2NUC
  Doit_reboot=1
 fi
fi

if [ "$Doit_reboot" -eq "1" ]; then
 amixer set PCM -- 100%
 if grep -q "RPI2NUC" /proc/bus/input/devices
 then
  sudo rm -rf /opt/RPI2JAMMA/modeline-off.png
  sudo rm -rf /opt/RPI2JAMMA/modeline-on.png
  sudo rm -rf /opt/RPI2JAMMA/no-usb.png
  sudo ln -s /opt/RPI2JAMMA/img/modeline-off.png.rpi2nuc /opt/RPI2JAMMA/modeline-off.png
  sudo ln -s /opt/RPI2JAMMA/img/modeline-on.png.rpi2nuc /opt/RPI2JAMMA/modeline-on.png
  sudo ln -s /opt/RPI2JAMMA/img/no-usb.png.rpi2nuc /opt/RPI2JAMMA/no-usb.png
  sed -i 's/_RPI2JAMMA/_RPI2NUC/g' /home/pi/.config/reicast/emu.cfg
  sed -i 's/_RPI2SCART/_RPI2NUC/g' /home/pi/.config/reicast/emu.cfg
  /opt/RPI2JAMMA/script/05\ -\ NeoGeo/Switch\ to\ MVS\ mode.sh
  if [ "$rotation_config" -eq "1" ]; then
   sudo plymouth-set-default-theme RPI2NUC_tate > /dev/null 2>&1
  elif [ "$rotation_config" -eq "3" ]; then
   sudo plymouth-set-default-theme RPI2NUC_tate_r > /dev/null 2>&1
  else
   sudo plymouth-set-default-theme RPI2NUC > /dev/null 2>&1
  fi
 else
  if grep -q "RPI2JAMMA" /proc/bus/input/devices
  then
   sudo rm -rf /opt/RPI2JAMMA/modeline-off.png
   sudo rm -rf /opt/RPI2JAMMA/modeline-on.png
   sudo rm -rf /opt/RPI2JAMMA/no-usb.png
   sudo ln -s /opt/RPI2JAMMA/img/modeline-off.png.rpi2jamma /opt/RPI2JAMMA/modeline-off.png
   sudo ln -s /opt/RPI2JAMMA/img/modeline-on.png.rpi2jamma /opt/RPI2JAMMA/modeline-on.png
   sudo ln -s /opt/RPI2JAMMA/img/no-usb.png.rpi2jamma /opt/RPI2JAMMA/no-usb.png
   sed -i 's/_RPI2NUC/_RPI2JAMMA/g' /home/pi/.config/reicast/emu.cfg
   sed -i 's/_RPI2SCART/_RPI2JAMMA/g' /home/pi/.config/reicast/emu.cfg
   /opt/RPI2JAMMA/script/05\ -\ NeoGeo/Switch\ to\ MVS\ mode.sh
   if [ "$rotation_config" -eq "1" ]; then
    sudo plymouth-set-default-theme RPI2JAMMA_tate > /dev/null 2>&1
   elif [ "$rotation_config" -eq "3" ]; then
    sudo plymouth-set-default-theme RPI2JAMMA_tate_r > /dev/null 2>&1
   else
    sudo plymouth-set-default-theme RPI2JAMMA > /dev/null 2>&1
   fi
  else
   sudo rm -rf /opt/RPI2JAMMA/modeline-off.png
   sudo rm -rf /opt/RPI2JAMMA/modeline-on.png
   sudo rm -rf /opt/RPI2JAMMA/no-usb.png
   sudo ln -s /opt/RPI2JAMMA/img/modeline-off.png.rpi2scart /opt/RPI2JAMMA/modeline-off.png
   sudo ln -s /opt/RPI2JAMMA/img/modeline-on.png.rpi2scart /opt/RPI2JAMMA/modeline-on.png
   sudo ln -s /opt/RPI2JAMMA/img/no-usb.png.rpi2scart /opt/RPI2JAMMA/no-usb.png
   sed -i 's/_RPI2JAMMA/_RPI2SCART/g' /home/pi/.config/reicast/emu.cfg
   sed -i 's/_RPI2NUC/_RPI2SCART/g' /home/pi/.config/reicast/emu.cfg
   /opt/RPI2JAMMA/script/05\ -\ NeoGeo/Switch\ to\ AES\ mode.sh
   if [ "$rotation_config" -eq "1" ]; then
    sudo plymouth-set-default-theme RPI2SCART_tate > /dev/null 2>&1
   elif [ "$rotation_config" -eq "3" ]; then
    sudo plymouth-set-default-theme RPI2SCART_tate_r > /dev/null 2>&1
   else
    sudo plymouth-set-default-theme RPI2SCART > /dev/null 2>&1
   fi
  fi
 fi
 echo "Doit reboot"
 sudo reboot
fi

######################################################################
########################OPTIMISATION##################################
######################################################################
Machine_model=$(dmesg | grep "Machine model:" | cut -d':' -f4)
if grep -q "Pi 3" <<< "$Machine_model" ; then
platform="rpi3"
else
platform="rpi2"
fi
while read nom_fichier; do
 lien=$(readlink $nom_fichier)
 if [ -e "$nom_fichier" ]
 then
  if [ -L "$nom_fichier" ]
  then
   platform_lien=$(echo "$lien" | rev | cut -d'.' -f1 | rev)
   if [ $platform_lien != $platform ]
   then
    if [ -f "$nom_fichier.$platform" ]
    then
     #echo "$nom_fichier.$platform existe"
     sudo rm -f $nom_fichier
     sudo ln -s "$nom_fichier.$platform" "$nom_fichier"
    fi
   fi
  else
   if [ -f "$nom_fichier.$platform" ]
    then
     sudo rm -f $nom_fichier
     sudo ln -s "$nom_fichier.$platform" "$nom_fichier"
    fi
  fi
 else
  if [ -f "$nom_fichier.$platform" ]
    then
     sudo ln -s "$nom_fichier.$platform" "$nom_fichier"
  fi
 fi
done < /opt/RPI2JAMMA/configs/Optimization.list

###########################################################################
########################VERIFICATION WIFI##################################
###########################################################################
wpa_local_country=$(sudo cat /etc/wpa_supplicant/wpa_supplicant.conf | grep "country")
wpa_cle_country=$(sudo cat /media/usb/Config_RPI2XXXXX/wifi_config.txt | grep "country")
wpa_cle_ssid=$(sudo cat /media/usb/Config_RPI2XXXXX/wifi_config.txt | grep "ssid")
wpa_cle_psk=$(sudo cat /media/usb/Config_RPI2XXXXX/wifi_config.txt | grep "psk")

if [ -z "$wpa_cle_ssid" ] || [ -z "$wpa_cle_psk" ]
then
 # Il n'y a pas de clé réseau sur la clé usb
 if [ -z "$wpa_local_country" ]
 then
  sudo echo "country=FR" >> /etc/wpa_supplicant/wpa_supplicant.conf
  sudo reboot
 fi
else
 # Clé et mdp présent sur la clé usb
 if [ -z "$wpa_cle_country" ]
 then
  wpa_cle_country=$(echo "$wpa_local_country")
 fi
 sudo rm -f /tmp/wifi_tmp
 echo "$wpa_cle_country
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    $wpa_cle_ssid
    $wpa_cle_psk
}">>/tmp/wifi_tmp
 #On compare avec ce qui est présent
 Difference=$(sudo diff -q /tmp/wifi_tmp /etc/wpa_supplicant/wpa_supplicant.conf)
 if [ -n "$Difference" ]
 then
  sudo cp /tmp/wifi_tmp /etc/wpa_supplicant/wpa_supplicant.conf
  sudo reboot
 fi
fi
sudo rm -f /tmp/wifi_tmp

###################################################################
##################VERIFICATION AUTOBOOT############################
########################LANCEMENT##################################
###################################################################
sudo cp /opt/RPI2JAMMA/retroarch/retroarch.cfg.ok  /opt/RPI2JAMMA/retroarch/retroarch.cfg
function Lance_emulationstation
{
  /opt/RPI2JAMMA/Watchdog_ES.sh&
  while true; do
    rm -f /tmp/es-restart /tmp/es-sysrestart /tmp/es-shutdown /tmp/RPI2X_script
    #Interactive header
    sudo killall fbi  > /dev/null 2>&1
    if [ -c /dev/fb1 ]; then
      sudo fbi -T 5 --once -a -d /dev/fb1 -noverbose -t 2s "/opt/RPI2JAMMA/img/RPI2JAMMA_please_select.jpg"&
    fi
    echo 0 >/dev/rpi2x-intf
    if [ "$rotation_config" -eq "0" ] || [ "$rotation_config" -eq "1" ] || [ "$rotation_config" -eq "3" ]; then
     emulationstation --no-splash --no-exit --screenrotate $rotation_config > /dev/null 2>&1
    else
     emulationstation --no-splash --no-exit > /dev/null 2>&1
	fi
    [ -f /tmp/es-restart ] && continue
    if [ -f /tmp/es-sysrestart ]; then
        rm -f /tmp/es-sysrestart
		sudo umount /media/usb
        sudo reboot
        break
    fi
    if [ -f /tmp/es-shutdown ]; then
        rm -f /tmp/es-shutdown
		sudo umount /media/usb
        sudo poweroff
        break
    fi
    if [ -f /tmp/RPI2X_script ]; then
        fichier_executer=$(cat /tmp/RPI2X_script)
        bash -c "$fichier_executer"
		sudo rm -f /tmp/RPI2X_script
		continue
	# else
		# sudo umount /media/usb
		# sudo halt
    fi
  done
  sudo umount /media/usb
  sudo halt
}

if [ -f "$Fichier_autoboot" ] && [ -n "`grep \"^system\" "$Fichier_autoboot" `" ] && [ -n "`grep \"^game\" "$Fichier_autoboot" `" ] ; then
 Nom_Emulateur=$(cat $Fichier_autoboot |grep "^system" |cut -d'=' -f2)
 Jeu_a_lancer=$(cat $Fichier_autoboot | grep "^game" | cut -d'=' -f2)
 Rep_rom=$(awk '/\/roms\/'$Nom_Emulateur'/,/<\/command>/' /home/pi/.emulationstation/es_systems.cfg | grep "path" | cut -d'>' -f2 | cut -d'<' -f1)
 Commande_rom=$(awk '/\/roms\/'$Nom_Emulateur'/,/<\/command>/' /home/pi/.emulationstation/es_systems.cfg | grep "command" | cut -d'>' -f2 | cut -d'<' -f1)
 Chemin_complet=$(echo "$Rep_rom/$Jeu_a_lancer")
 Commande_finale=$(echo "$Commande_rom" | sed -e "s+%ROM%+$Chemin_complet+g")

 if [ -f "$Chemin_complet" ]
 then
  bash -c "$Commande_finale"
 fi
 Lance_emulationstation
else
 Lance_emulationstation
fi

sync
sudo halt
