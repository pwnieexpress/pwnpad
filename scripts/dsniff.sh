#!/bin/bash
# Cleartext password sniffing on all available interfaces

f_interface_setup(){
  # echo "Since Dsniff currently has issues, ettercap will work like Dsniff"
  # echo
  clear
  echo "Select which interface you would like to sniff on? (1-6):"
  echo
  echo "1. eth0 (USB ethernet adapter)"
  echo "2. wlan0 (Internal Nexus Wifi)"
  echo "3. wlan1 (USB TPlink Atheros)"
  echo "4. mon0 (monitor mode interface)"
  echo "5. at0 (Use with EvilAP)"
  echo "6. rmnet_usb0 (4G connection)"
  echo

  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=mon0 ;;
    5) interface=at0 ;;
    6) interface=rmnet_usb0 ;;
    *) f_interface_setup ;;
  esac
}

f_logging_setup(){
  clear
  echo
  echo "Would you like to log data?"
  echo
  echo "Captures saved to /opt/pwnix/captures/passwords/"
  echo
  echo "1. Yes"
  echo "2. No "
  echo
  f_get_logchoice
}

f_get_logchoice(){
  read -p "Choice: " logchoice
  case $logchoice in
    [1-2]*) ;;
    *)
      echo 'Please enter 1 for yes or 2 for no.'
      f_get_logchoice
      ;;
  esac
}

f_run(){
  # If user chose to log, log to folder
  # else just run cmd
  if [ $logchoice -eq 1 ]; then
    filename=/opt/pwnix/captures/passwords/dsniff_$(date +%F-%H%M).log
    ettercap -i $interface -u -T -q | tee $filename
  elif [ $logchoice -eq 2 ]; then
    ettercap -i $interface -T -q -u
  fi
}

f_execute(){
  f_interface_setup
  f_logging_setup
  f_run
}

f_execute
