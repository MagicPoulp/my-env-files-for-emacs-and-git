#!/usr/bin/bash

#CTRL+ALT+F1  or +F7 to change console
#setupcon must be run in the F1

#In Debian live, user/pass=user/live

#to activate the Swedish keyboard: (to wait the - is next to the 0)
apt-get update
apt-get install console-setup
dpkg-reconfigure keyboard-configuration
#(pick Logitech Generic, and Swedish)
setupcon
