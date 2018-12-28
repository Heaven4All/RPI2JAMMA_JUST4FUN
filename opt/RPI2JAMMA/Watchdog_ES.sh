#!/usr/bin/env bash
#RPI2JAMMA (c)aje_fr
Nb_plantage=0
while true; do
  sleep 5
  Plantage=$(dmesg | grep "emulationstatio")
  if [ -n "$Plantage" ]
  then
    let Nb_plantage++
    echo $Nb_plantage > /tmp/ES_NB_plantage.txt
    sudo dmesg -C
    echo "toto" > /tmp/es-restart
    sudo killall emulationstation
    sleep 1
    process_id=$(ps -C emulationstation -o pid=)
    if [ "$process_id" -ge "20" ]
    then
      sudo kill -9 $process_id
      sleep 1
    fi
    clear
  fi
done
