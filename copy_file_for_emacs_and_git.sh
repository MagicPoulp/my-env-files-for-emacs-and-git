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
source ~/.myvars

echo "--> all files have been copied"
echo ""
echo "--> still to do ONLY ONCE, as sudo for some commands:"
echo "cd ./emacs_and_git/all_files_needed_for_emacs_and_git"
echo "update ~/.emacs.d with .emacs.d"
echo "update ~/.emacs_backup.d with .emacs_backup.d"
echo ""
echo "sudo cp .emacs_backup.d/.emacs_working_for_root root/.emacs"
echo ""
echo "install emacs24 emacs-goodies-el"
echo 'sudo echo "source /home/thierry/.myvars" >> /root/.bashrc'
echo 'echo "source /home/thierry/.myvars" >> ~/.bashrc'
echo ""
echo "--> other manual setup to do:"
cat $DIR_EMACS/list_to_do/additional_emacs_setup

