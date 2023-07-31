#!/bin/bash

#SOME COMMANDS YOU WANT TO EXECUTE

function rm_home_pi {
  if grep -r '/home/pi' $1
  then
	  grep -rl '/home/pi' $1 | xargs sed -i 's@/home/pi@'$(getent passwd 1000 | cut --delimiter=: --fields=6)'@g'
  fi
}

function rm_user_pi {
  if grep -r 'User=pi' $1
  then
	  grep -rl 'User=pi' $1 | xargs sed -i 's@User=pi@'User=$(getent passwd 1000 | cut --delimiter=: --fields=1)'@g'
  fi
}

# Ersetzt den Pfad /home/pi für aktuellen Benutzer
rm_home_pi /etc/systemd/system
rm_home_pi $(getent passwd 1000 | cut --delimiter=: --fields=6)

# ToDo Ersetze User=pi mit richtigen user
rm_user_pi /etc/systemd/system

# Löscht alle pythoncache Dateien, da hier auch noch /home/pi angegeben.
find $(getent passwd 1000 | cut --delimiter=: --fields=6)/ -name '*.pyc' -delete

#Via ansible wird der Packetcache erneuert.
ansible --extra-vars ansible_python_interpreter=/usr/bin/python3 \
  --inventory localhost, --connection local \
  --module-name apt \
  --args "update_cache=yes cache_valid_time=3600" localhost

if [ -f /etc/systemd/system/cockpit_installer.service ]
then
  systemctl restart cockpit_installer
fi

localectl set-locale LANG=de_DE.UTF-8

# Löschen von firstboot
systemctl disable firstboot.service

rm -rf /etc/systemd/system/firstboot.service
rm -f /firstboot.sh
