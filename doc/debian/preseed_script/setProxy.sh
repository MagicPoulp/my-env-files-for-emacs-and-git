#!/bin/bash
if [[ "$EUID" -ne 0 ]];
then
    echo "Please run as root"
    exit
fi
#General proxy
cat <<EOF >/etc/profile.d/proxy.sh
export ftp_proxy=http://gateway.schneider.zscaler.net:80
export http_proxy=http://gateway.schneider.zscaler.net:80
export https_proxy=http://gateway.schneider.zscaler.net:80
export no_proxy="localhost, 127.0.0.0/8, ::1, schneider-electric.com, 10.0.0.0/8, 192.168.0.0/16"
export HTTP_PROXY=http://gateway.schneider.zscaler.net:80
export HTTPS_PROXY=http://gateway.schneider.zscaler.net:80
export NO_PROXY="localhost, 127.0.0.0/8, ::1, schneider-electric.com, 10.0.0.0/8, 192.168.0.0/16"
EOF
#Apt proxy
cat <<EOF >/etc/apt/apt.conf.d/99schneider_proxy
Acquire::http::Proxy "http://gateway.schneider.zscaler.net:80/";
Acquire::https::Proxy "http://gateway.schneider.zscaler.net:80/";
EOF
#Docker proxy (inside container, use only for specific usage)
#CHANGE THIS PATH ACCORDING TO YOUR USER, $HOME DON'T WORK BECAUSE OF SUDO
#cat <<EOF >/home/user/.docker/config.json
#{
# "proxies":
# {
#   "default":
#   {
#     "httpProxy": "http://gateway.schneider.zscaler.net:80",
#     "httpsProxy": "http://gateway.schneider.zscaler.net:80",
#     "noProxy": "localhost, 127.0.0.0/8, ::1, schneider-electric.com, 10.0.0.0/8, 192.168.0.0/16"
#   }
# }
#}
#EOF
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://gateway.schneider.zscaler.net:80"
Environment="HTTPS_PROXY=http://gateway.schneider.zscaler.net:80"
Environment="NO_PROXY=localhost, 127.0.0.0/8, ::1, schneider-electric.com, 10.0.0.0/8, 192.168.0.0/16"
EOF
#systemctl daemon-reload <- Useless if you reboot (and you need to)
#systemctl restart docker
echo "Reboot your system to update the env vars"
