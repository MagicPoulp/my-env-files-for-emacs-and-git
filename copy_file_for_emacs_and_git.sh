#!/bin/bash

git config --global push.default current
git config --global remote.origin.push HEAD
git config --global core.editor emacs_client
git config --global user.name "Thierry Vilmart"
git config --global user.email "thierry@fake.email.skynet.org"
git config --global color.ui auto

DIR1=`dirname "$(readlink -f "$0")"`
DIR_EMACS=$DIR1/emacs_and_git
EXTRA_FOLDER=all_files_needed_for_emacs_and_git
mkdir -p ~/bin

cp $DIR_EMACS/$EXTRA_FOLDER/emacs_client ~/bin
cp $DIR_EMACS/$EXTRA_FOLDER/.emacs ~/
cp $DIR_EMACS/$EXTRA_FOLDER/.myvars ~/
cp -r $DIR_EMACS/$EXTRA_FOLDER/.emacs.d ~/
cp -r $DIR_EMACS/$EXTRA_FOLDER/.emacs_backup.d ~/
source ~/.myvars


cp home_setup/user-dirs.dirs ~/.config/user-dirs.dirs

mkdir ~/tmp

mv ~/Desktop ~/desktop
mv ~/Downloads ~/downloads
mv ~/Documents ~/documents

mkdir ~/other
mv ~/Music ~/other/
mv ~/Pictures ~/other/
mv ~/Music ~/other/
mv ~/Pictures ~/other/
mv ~/Public ~/other/
mv ~/Templates ~/other/
mv ~/Videos ~/other/


echo "--> all files have been copied"
echo "a killall emacs may be needed"
echo ""
echo "--> still to do ONLY ONCE, as sudo:"
echo ""
echo "sudo cp -r ~/.emacs_backup.d/.emacs_working_for_root /root/.emacs"
echo ""
echo 'sudo echo "source /home/thierry/.myvars" >> /root/.bashrc'
echo 'echo "source /home/thierry/.myvars" >> ~/.bashrc'
echo "sudo install emacs24 emacs-goodies-el"

