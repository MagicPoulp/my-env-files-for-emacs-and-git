#!/bin/bash

killall emacs

git config --global push.default current
git config --global remote.origin.push HEAD
git config --global core.editor emacs_client
git config --global user.name "Thierry Vilmart"
git config --global user.email "thierry@fake.email.skynet.org"
git config --global color.ui auto

DIR1=`dirname "$(readlink -f "$0")"`
DIR_EMACS_FILES=$DIR1/emacs_and_git
mkdir -p ~/bin

cp $DIR_EMACS_FILES/emacs_client ~/bin
cp $DIR_EMACS_FILES/.emacs ~/
cp $DIR_EMACS_FILES/.myvars ~/
cp -r $DIR_EMACS_FILES/.emacs.d ~/
source ~/.myvars


DIR_HOME_SETUP=$DIR1/home_dir_setup
cp $DIR_HOME_SETUP/user-dirs.dirs ~/.config/user-dirs.dirs

mkdir -p ~/tmp

mv ~/Desktop ~/desktop 2> /dev/null
mv ~/Downloads ~/downloads 2> /dev/null
mv ~/Documents ~/documents 2> /dev/null

mkdir -p ~/other 2> /dev/null
mv ~/Music ~/other/ 2> /dev/null
mv ~/Pictures ~/other/ 2> /dev/null
mv ~/Public ~/other/ 2> /dev/null
mv ~/Templates ~/other/ 2> /dev/null
mv ~/Videos ~/other/ 2> /dev/null

mkdir ~/desktop 2> /dev/null
mkdir ~/downloads 2> /dev/null
mkdir ~/documents 2> /dev/null

mkdir -p ~/other 2> /dev/null
mkdir ~/other/Music 2> /dev/null
mkdir ~/other/Pictures 2> /dev/null
mkdir ~/other/Public 2> /dev/null
mkdir ~/other/Templates 2> /dev/null
mkdir ~/other/Videos 2> /dev/null


echo ""
echo "--> REMINDER OF OTHER THINGS TO DO FIRST ON DEBIAN AFTER INSTALLATION: "
echo "su -         adduser thierry sudo        log out"
echo "increase font in shell"
echo "set wallpaper"
echo "remove beep in emacs (see debian_setup in doc)"
echo "set up pinning"
echo "run sudo apt-get update && sudo apt-get dist-upgrade"
echo ""
echo "--> the script will copy files for emacs and the shell environment"
echo ""
echo "--> TO DO ONCE PER INSTALLATION"
echo ""
echo 'echo "source /home/thierry/.myvars" >> ~/.bashrc'
echo ""
echo "sudo sh -c 'cp ~/.myvars /root/; echo \"source /root/.myvars\" >> /root/.bashrc'"
echo "sudo apt-get install emacs25 emacs-goodies-el"
echo "sudo cp ~/.emacs /root/"

