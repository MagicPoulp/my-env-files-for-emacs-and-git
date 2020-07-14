# introduction

what is nice is that it is a portable computer but just with the drive.

This usb drive has 2 partitions:
a windows compatible partition with 1.5 terabytes
a linux partition with debian linux, with 2 softwares for music editing, and a space simulator, and tuxmath game
One music software, Sibelius, can play the violin and the guitar on its own.

type the folloying in a terminal to see teh list and disk use
df -H

In order to start linux you need to find it in the bios boot order.

You must never disconnect the USB without a successful "eject" (arrow and right click at the bottom right of Microsoft Windows).

The SSD disk should be connected to a USB 3 socket. An USB 3 socket is blue.

One you have started, on linux, you can run the 2 commands
lsusb
lsusb -t
And if the speed is 10000M, then it is USB 3.1,
5000M is USB 3.02, 400M USB2.

If the system is not bootable on USB 3 or it is too slow,
you may need to update the bios. This is optional. You find your bios name in "system information" on windows.
You download the bios file from your manufacturer,
and in the bios you can detect it from a usb drive, and install it. Updating the bios is simple as long as you use the right file.

In my case the manufacturer ASUS had too many generations of bios, and the one on the website was not compatible. But In the archive on driver.eu, I found the right bios and I could install it.


# Important

Be careful with the command rm -rf folder, and never use the command rm -rf *. The risk to erase your entire home folder is too high.

Never disconnect the usb socket when the computer is running. Or the disk can get corrupted.
On windows, you can do an usb eject.

a windows compatible folder of 1 terabyte lies in /windows_compatible
You can only modify it using sudo.

never run any .exe on the real windows, if you download a crack in can have a virus. But it is safe inside wine on linux

If you drop the drive on the floor it can break. It can easily be lost.

# Useful commands

CTRL + R  then type text and you can find previous commands
repeat CTRL + R to go to the older commands
This is very handy to start Sibelius or Photoscore


```
Run the following to run updates and security updates (usuallz after each login):
```
sudo apt-get update && sudo apt-get dist-upgrade

sudo is for the superuser and is password protected

to open a file type emacs file.txt, or e file.txt, or less file.txt (exit with q), or sudo nano file.txt when using sudo nano is better

move to a directory:

```
cd ../x
```

cd alone moves back to home which is in /home/gilles

cd documents to go where where all lies

list files:
```
ls
```

make dir/remove dir
```
mkdir mydir
rm -r mydir
```

open a file:
```
e file.txt
```

copy files:
```
cp file.txt /home/gilles/documents/
cp file.txt ~/documents/
```

search packages:
```
sudo apt-cache search gfortran- | less
q
sudo apt-get install emacs gfortran-8
```

show disc usage
df -H

open a new tab
ctrl shift  t

show processor use (exit with q)
top

get manual pages for a command
man top

see all terminal commands typed
less /home/gilles/.bash_eternal_history

# gimp open source image editor

It as advanced as Photoshop.

Open by typing gimp

```
sudo apt-get install gimp
gimp

```

# Tuxmath, a game for kids to teach math

start typing tuxmath
for the spaceship thing type a number and then press space

if you loggout from linux, and login using the matteo user, you can stil read all files on the computer but you cannot modify them.
And you can start tuxmath, or gimp or other.

# Celestia, simulator of space

It is already ready to  run. For curiosity, here is how it was built:

git clone https://github.com/CelestiaProject/Celestia
cd Celestia && mkdir build && cd build
sudo apt-get install libtheora-dev libtheora-bin libgl1-mesa-dev libglew-dev liblua5.3-dev qt5-default libfmt-dev libeigen3-dev cmake build-essential zlib1g-dev libpng-dev libjpeg-dev gettext libluajit-5.1-27 libfreetype6-dev

cmake .. -DENABLE_QT=ON -DCMAKE_INSTALL_PREFIX=~/documents/celestia/install
cd /home/gilles/documents/celestia/Celestia/build
make -j2
make install

to start:
/home/gilles/documents/celestia/install/bin/celestia-qt
you can be faster and not retype all teh line with CTRL + R   and then celestia and then CTRL +R several times
you can also navigate with arrow up

interesting things to do:

- find polaris
from the earth north pole locate the polar star
or press E and write Polaris

- see twin galaxies
zoom out with the scroll and see the transition to the galaxy and locate the twin galaxies

- mars surface maps
I have downloaded and installed surface maps addons for mars

In Celesta, you need to perform a "Go to" mars
Then on the planet, if you right click there is an option alternate surfaces

source:
http://celestiamotherlode.net/

note: the surface normal maps are needed and tehz are on separate pages

doc for customizing the config:
https://www.classe.cornell.edu/~seb/celestia/textures.html#2.4

and I copied the files here:
/home/gilles/documents/celestia/install/share/celestia/extras
16K Surface/Normal Maps JPG
	Jestr
--> config modification done to make it default:
first line
Modify "Mars" "Sol"

The 16K is set a s default because it is more shinz but the 32 K is more precise and available via right click

32K VT Mars Surface Map
	John van Vliet
--> config modification done to make it non default:
first line
AltSurface "32K VT Mars Surface Map" "Sol/Mars"

64K Jestr Earth Mark I JPG
Levels 0-5 JPG
Levels 6-10 (With U.K.) JPG

I also installed the moon 164K with surface and normal maps  64K Moon Normal Map VT John van Vliet.
It takes like 20 GB.
http://lroc.sese.asu.edu/

here is how to uncompress many zip files:
ls | grep zip
x=`ls | grep zip`
echo $x
for y in $x; do; echo $y; done
for y in $x; do 7z x $y; done


It is less realistic to add surface maps for a gaseous planet, or a planet wit ha dense athmosphere like Venus.

# Possiblity to isntall windows in a VM

I did not detail here too much but if zou want zou can have window on this SSD drive. I master the technical details for it.

At work I have a Linux host with a "paid licensed" windows in a VM. And I can share the copy paste, I can share the files, I can mount the windows VM drive on linux to use it from linux. And it is very fast because it is graphics accelerated. It is the best VM technology that exists. It is linux kernel stuff. THe onlz limitation is for a VM inside a VM that is not possible.

# Photoscore

229 dollar
https://shop.avid.com/ccrz__ProductDetails?viewState=DetailView&cartID=&sku=AR-AV-SBNM-00&cclcl=sv

and sibelius is 139 dollar for a perpetual license
https://shop.avid.com/ccrz__ProductDetails?viewState=DetailView&cartID=&sku=SBDYNA10009&cclcl=sv

NOTE: to visualise a partition, go in the folder contaiing the file, and write firefox filename

A scanner of pdf, and a small editor of tracks
Usually one scans in photoscore, saves a certain photoscore format, that can be imported in Sibelius
if the instruments tracks are not in order on every page, you will have to edit manually the partition
I did it for one partition. It is quite fast to do.


TO START:
~/documents/wine_custom/wine/build/wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Neuratron/PhotoScore\ +\ NotateMe\ Ultimate\ 2018\ Demo/Neuratron\ PhotoScore.exe

you can be faster and not retype all teh line with CTRL + R   and then Photoscore and then CTRL +R several times
you can also navigate with arrow up

the other software Sibelius can export to pdf. In photoscore, you cannot but you can print to file in pdf. Then if you try top open it it say the file has something wrong. The file is bugged. but if you open it in another pdf viewer and then print to file again, it is not corrupted any more.

here is a website with many free partitions
imslp has both free and non free
https://www.free-scores.com/index_uk.php
https://imslp.org/wiki/Nocturnes,_Op.9_(Chopin,_Fr%C3%A9d%C3%A9ric)
https://imslp.org/wiki/Polish_Songs,_Op.74_(Chopin,_Fr%C3%A9d%C3%A9ric)
https://imslp.org/wiki/Symphony_No.6,_Op.68_(Beethoven,_Ludwig_van)


https://en.wikipedia.org/wiki/Nocturnes,_Op._9_(Chopin)

# Sibelius

a more advanced editor of partitions, that can generate guitar tablatures
awesome note: I fixed the sound config (see long appendix) so that it can play the music audio like a music simulator
and it plays different sounds depending on the instrument. It is based on the MIDI technology that is still very modern.

For me it is important to not alter the original composition of the music author.
But if you just copy the Fa key piano part to a SOL key for guitar with tablature, then you change very little.

TO START
faketime "2020-05-25" ~/documents/wine_custom/wine/build/wine ~/.wine/drive_c/Program\ Files/Avid/Sibelius/Sibelius.exe

If it gets stuck and does not start, press CTRL + C wait 5s and try again.

you can be faster and not retype all the line with CTRL + R   and then Sibelius and then CTRL +R several times
you can also navigate with arrow up

see the other file next to the current files for instructions of how to use Sibelius

on USB3 it can take 1 or 2 min to start, or 1min for me. On usb2 it can take a few more minutes.

it takes a few minutes to start, and if takes long it is probably because your usb 3 is not working correctly, mazbe update the bios, check the socket is blue.

when you quit, wine still remains in memory it is good to kill it (copy the process ids that are in the leftmost column)
ps aux | grep wine
kill -KILL 7451 7467

Note:
The sound works inside wine, but...
The trial version of Sibelius was stripped down to not include all their backplay sounds. But it still works with MIDI sound.
https://www.sibeliusforum.com/viewtopic.php?t=71265

# Summary

I went on imslp.org
I downloaded a chopin music
I scanned it in Photoscore, then saved it as a .opt
I opened Sibelius anbd picked import other files, and picked the .opt file.


# if you want to reinstall Photoscore:

rm -rf ~/.wine
remember to be careful with the rm command you can erase the wrong things
cd ~/documents/copy_of_installers
~/documents/wine_custom/wine/build/wine ~/documents/copy_of_installers/photoscore/Photoscore\ 8.8.7\ 2019\ -\ DO\ NOT\ RUN\ ON\ WINDOWS/PhotoScoreUltimateDemo887.exe
cp ~/documents/copy_of_installers/photoscore/cracked_exe/Neuratron\ PhotoScore.exe ~/.wine/drive_c/Program\ Files\ \(x86\)/Neuratron/PhotoScore\ +\ NotateMe\ Ultimate\ 2018\ Demo/

you must not start Photoscore before copying the crack

# if you want to reinstall Sibelius:

rm -rf ~/.wine
remember to be careful with the rm command you can erase the wrong things
the star below works as it is
cd ~/documents/copy_of_installers/sibelius/*
~/documents/wine_custom/wine/build/wine start
and in MS DOS run Install_Sibelius.exe and you must not click launch sibelius after

it is important to select install fonts just for me if it asks
note: there is another folder with sibelius_trial_old, it is a trial version not downloaded via a crack. But it will expire and need resintalling all the time.

then copy the crack:
cp /home/gilles/documents/copy_of_installers/sibelius/Avid\ Sibelius\ Ultimate\ 2019.5\ Build\ 1469\ x64\ Multilingual\ +\ Crack\ \[FileCR\]/Crack/netapi32.dll /home/gilles/.wine/drive_c/Program\ Files/Avid/Sibelius/

# Appendix - how wine was built from source

Because of a dll missing error reported at the link below, we need to build wine from source with a patch

https://forum.winehq.org/viewtopic.php?f=8&t=31334
after addin return 0; at the top of wintrust_main.c:WinVerifyTrust()

sudo apt-get install gcc make pkg-config gcc-multilib flex bison winbind

sudo dpkg --add-architecture i386
sudo apt-get install libx11-dev:i386 libfreetype6-dev:i386
sudo apt-get install libx11-dev libfreetype6-dev
sudo apt-get build-dep wine
sudo apt-get install libasound2-dev:i386 libasound2-dev libldap2-dev:i386
sudo apt-get install winetricks ttf-mscorefonts-installer cups printer-driver-cups-pdf timidity

note: winetricks makes sure Sibelius can download all the fonts it needs
--> build libfaudio-def from source
add unstable reposiry rules the the apt sources.list
and add this to preferences.d/preferences
Package: *
Pin: release a=unstable
Pin-Priority: -10

sudo apt-src source libfaudio-dev
sudo chown -R gilles:gilles FOLDER
sudo apt-get build-dep libfaudio-dev
sudo apt-get install devscripts
cd in the subfolder of the subfolder
debuild -b -uc -us
one folder up (cd ..)
sudo dpkg -i libfaudio-dev_19.12-1_amd64.deb libfaudio0_19.12-1_amd64.deb

one must also install the non i386 packages
YOU need to build the 64 bit version and then build the 32 bit in another folder using a flag refering to the 64 version

git clone git://source.winehq.org/git/wine.git
3 builds:
one must first build 64
then build 32 (missing step in the doc)
then build 32 + 64

https://wiki.winehq.org/Building_Wine

NOTE below the path to wine64-build i nthe last command must be an absolute path
su
time rm -rf build && rm -rf wine64-build && mkdir build && mkdir wine64-build && cd wine64-build && ../configure --enable-win64 && make -j2 && cd ../build && PKG_CONFIG_PATH=/usr/lib32 ../configure && make -j2 && PKG_CONFIG_PATH=/usr/lib32 ../configure --with-wine64=/home/gilles/documents/wine_custom/wine/wine64-build && make -j2

its called wow64, see wine doc
---------------
when installing the program, one must first go in the folder /home/gilles/documents/copy_of_installers
then run wine start and then run the exe from the dos window
cd ~/documents/copy_of_installers
~/documents/wine_custom/wine/build/wine start
And run Install_Sibelius.exe
it is important to select install fonts just for me if it asks

---

then you do not need a crack you can use the trial version. after 30 days you just reinstall, and maybe delete the .wine folder


-------------
to setup MIDI sound in wine:
https://wiki.winehq.org/MIDI
https://wiki.debian.org/MIDI
https://wiki.debian.org/AlsaMidi

sudo apt-get install timidity
note the debian soundfront is already in place ance configured for timidity

sudo nano /etc/systemd/system/timidity.service

[Unit]
Description=TiMidity++ Daemon
After=sound.target

[Service]
ExecStart=/usr/bin/timidity -iA -Os

[Install]
WantedBy=default.target



----------
sudo systemctl enable timidity.service
sudo systemctl restart timidity.service
aconnect -l
aplaymidi -p128:0 /home/gilles/downloads/super.mid
this will play in a debian shell

in wine, you can test in the shell (copied from teh wine midi link above, and the wintest.exe and the .mid file must be downloaded):

The MCI shell
One such application is the interactive MCI shell attached to bug #20232, comment #10. It allows you to send MCI string commands to any device. A sample session goes like this:

$ wine wintest.exe mcishell
mci.c:891: Type your commands to the MCI, end with Ctrl-Z/^D
open z:\home\downloads\super.mid alias m
play m from 0
status m position
close m
<- Ctrl-D to end the session in UNIX, Ctrl-Z in DOS

then in Sibelius, in the menu plaz, tab Setup, there is a small arrow to open plazbacks,
and you have to add timidity port 0
tehre is no need to wrap wine with a command
and the sound was tested to work in wine
