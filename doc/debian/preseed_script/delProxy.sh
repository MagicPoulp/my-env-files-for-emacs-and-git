#!/bin/bash
if [[ "$EUID" -ne 0 ]];
then
    echo "Please run as root"
    exit
fi
rm -f /etc/apt/apt.conf
rm -f /etc/profile.d/proxy.sh
rm -f /etc/apt/apt.conf.d/99schneider_proxy
#Most of the time this file ins't added, so this produce an error. This isn't an issue.
rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
#CHANGE THIS PATH ACCORDING TO YOUR USER, $HOME DON'T WORK BECAUSE OF SUDO
rm -f /home/user/.docker/config.json
