#!/bin/bash

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
cp -r $DIR_EMACS_FILES/.emacs_backup.d ~/
source ~/.myvars


DIR_HOME_SETUP=$DIR1/home_dir_setup
cp $DIR_HOME_SETUP/user-dirs.dirs ~/.config/user-dirs.dirs

mkdir -p ~/tmp

mv ~/Desktop ~/desktop 2> /dev/null
mv ~/Downloads ~/downloads 2> /dev/null
mv ~/Documents ~/documents 2> /dev/null

mkdir -p ~/other
mv ~/Music ~/other/ 2> /dev/null
mv ~/Pictures ~/other/ 2> /dev/null
mv ~/Music ~/other/ 2> /dev/null
mv ~/Pictures ~/other/ 2> /dev/null
mv ~/Public ~/other/ 2> /dev/null
mv ~/Templates ~/other/ 2> /dev/null
mv ~/Videos ~/other/ 2> /dev/null


echo "--> all files have been copied"
echo "a killall emacs may be needed"
echo ""
echo "--> TO DO ONCE PER INSTALLATION"
echo ""
echo 'sudo echo "source /home/thierry/.myvars" >> /root/.bashrc'
echo 'echo "source /home/thierry/.myvars" >> ~/.bashrc'
echo "sudo install emacs24 emacs-goodies-el"
echo ""
echo "--> FOR EVERY CHANGE TO ~/.emacs"
echo ""
echo "sudo cp -r ~/.emacs_backup.d/.emacs_working_for_root /root/.emacs"
