#!/bin/bash

echo ""
echo "--> the script will copy files for emacs and for the shell environment"

killall emacs 2> /dev/null

git config --global push.default current
git config --global remote.origin.push HEAD
git config --global core.editor emacs
git config --global user.name "Thierry Vilmart"
git config --global user.email "3144141+MagicPoulp@users.noreply.github.com"
git config --global color.ui auto

DIR1=`dirname "$(readlink -f "$0")"`
DIR_EMACS_FILES=$DIR1/emacs_and_git
mkdir -p ~/bin

cp $DIR_EMACS_FILES/.emacs_henriette ~/.emacs
cp $DIR_EMACS_FILES/.myvars ~/
cp -r $DIR_EMACS_FILES/.emacs.d ~/
source ~/.myvars


#DIR_HOME_SETUP=$DIR1/home_dir_setup
#cp $DIR_HOME_SETUP/user-dirs.dirs ~/.config/user-dirs.dirs

mkdir -p ~/tmp
mkdir -p ~/.emacs_backups

exit
mv ~/Desktop ~/desktop 2> /dev/null
mv ~/Downloads ~/downloads 2> /dev/null
mv ~/Documents ~/documents 2> /dev/null

mkdir -p ~/other 2> /dev/null
mv ~/Music ~/other/ 2> /dev/null
mv ~/Pictures ~/other/ 2> /dev/null
mv ~/Public ~/other/ 2> /dev/null
mv ~/Templates ~/other/ 2> /dev/null
mv ~/Videos ~/other/ 2> /dev/null

mv ~/Skrivbord ~/desktop 2> /dev/null
mv ~/Dokument ~/documents 2> /dev/null
mv ~/Hämtningar ~/downloads 2> /dev/null
mv ~/Video ~/other/Videos 2> /dev/null
mv ~/Publikt ~/other/Public 2> /dev/null
mv ~/Musik ~/other/Musik 2> /dev/null
mv ~/Mallar ~/other/Templates 2> /dev/null
mv ~/Bilder ~/other/Pictures 2> /dev/null

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
echo "su -         adduser henriette sudo"
echo "su -         apt-get install sudo"
echo "log off for the sudo to be usable"
echo "su -         apt-get update              apt-get install sudo"
echo "logout to see the effect and have sudo available"
#echo ""
#echo "increase font in shell, set it to 18"
#echo "note: tab opening is done with: ALT+SHIT+t, workspace chage is done with CTRL+ALT+right arrow"
#echo "change the system font in xfce settings editor, xsettings, set it to 16"
#echo ""
#echo "- remove pcspeaker beep in emacs (see debian_setup in doc)"
#echo "nano /etc/modprobe.d/nobeep.conf"
#echo "and add the line:"
#echo "blacklist pcspkr"
#echo "sudo nano /etc/inputrc"
#echo "uncomment the line with bell-style none"

#echo ""
#echo "set up pinning from debian testing and debian unstable:"
#echo "sudo apt-get clean && sudo apt-get autoclean"
#echo "sudo nano /etc/apt/apt.conf.d/70debconf      add add the following line:"
#echo "APT::Cache-Limit \"100000000\";"
#echo "sudo cp pinning_files/preferences /etc/apt/preferences.d/"
#echo "sudo cp pinning_files/append.list /etc/apt/sources.list.d/"
#echo "IMPORTANT: review the files and update the distribution name"
#echo ""
echo "run to update: sudo apt-get update && sudo apt-get dist-upgrade"
#echo "copy userChrome.css for the firefox console font-size (create the chrome folder)"
#echo "~/.mozilla/firefox/h1q36msf.dev-edition-default/chrome/userChrome.css"
echo ""
echo "--> TO DO ONCE PER INSTALLATION"
echo ""
echo 'echo "source ~/.myvars" >> ~/.bashrc'
echo "sudo apt-get install emacs elpa-markdown-mode"
echo "the last was updated since the packages are now present in the stable branch"
echo "uncomment the melpa repository in the .emacs"
echo "install js2-mode and scss-mode and json-mode using ALT-X list-packages"
echo ""
echo "mkdir ~/downloads"
echo "wget http://download.savannah.nongnu.org/releases/color-theme/color-theme-6.6.0.zip"
echo "unzip color-theme-6.6.0.zip"
echo "mv color-theme-6.6.0.zip ~/.emacs.d/"
echo ""
echo "wget https://raw.github.com/fxbois/web-mode/master/web-mode.el"
echo "mv web-mode.el ~/.emacs.d/"
#echo "And if affecting root is fine:"
#echo "sudo sh -c 'cp $HOME/.myvars /root/; echo \"source /root/.myvars\" >> /root/.bashrc'"
#echo "sudo cp $HOME/.emacs /root/"

