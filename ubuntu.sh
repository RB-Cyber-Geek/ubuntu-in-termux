#!/data/data/com.termux/files/usr/bin/bash
clear
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Downloading the lolcat, please wait...\n"
gem install lolcat #install lolcat
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Download complete!\n"
printf '''
     _   _     _   _   _   _   _     _   _   _   _
    / \ / \   / \ / \ / \ / \ / \   / \ / \ / \ / \
   ( R | B ) ( C | y | b | e | r ) ( G | e | e | k )
    \_/ \_/   \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/

                               ubun2 installer 4.5

''' | lolcat
#Script 1
time1="$( date +"%r" )"

install1 () {
directory=ubuntu-fs
UBUNTU_VERSION=jammy
if [ -d "$directory" ];then
first=1
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;227m[WARNING]:\e[0m \x1b[38;5;87m Skipping the download and the extraction\n"
elif [ -z "$(command -v proot)" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install proot.\n"
printf "\e[0m"
exit 1
elif [ -z "$(command -v wget)" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install wget.\n"
printf "\e[0m"
exit 1
fi
if [ "$first" != 1 ];then
if [ -f "ubuntu.tar.gz" ];then
rm -rf ubuntu.tar.gz
fi
if [ ! -f "ubuntu.tar.gz" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Downloading the Ubuntu Rootfu, file size 26 MB, please wait ...\n"
ARCHITECTURE=$(dpkg --print-architecture)
case "$ARCHITECTURE" in
aarch64) ARCHITECTURE=arm64;;
arm) ARCHITECTURE=armhf;;
amd64|x86_64) ARCHITECTURE=amd64;;
*)
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Unknown architecture :- $ARCHITECTURE"
exit 1
;;

esac

wget https://partner-images.canonical.com/core/${UBUNTU_VERSION}/current/ubuntu-${UBUNTU_VERSION}-core-cloudimg-${ARCHITECTURE}-root.tar.gz -q -O ubuntu.tar.gz 
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Download complete!\n"

fi

cur=`pwd`
mkdir -p $directory
cd $directory
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Decompressing the ubuntu rootfs, please wait...\n"
proot --link2symlink tar -zxf $cur/ubuntu.tar.gz --exclude='dev'||:
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m The ubuntu rootfs have been successfully decompressed!\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Fixing the resolv.conf, so that you have access to the internet\n"
printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > etc/resolv.conf
stubs=()
stubs+=('usr/bin/groups')
for f in ${stubs[@]};do
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Writing stubs, please wait...\n"
echo -e "#!/bin/sh\nexit" > "$f"
done
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Successfully wrote stubs!\n"
cd $cur

fi

mkdir -p ubuntu-binds
bin=startubuntu
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Creating the start script, please wait...\n"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
## uncomment following line if you are having FATAL: kernel too old message.
#command+=" -k 4.14.81"
command+=" --link2symlink"
command+=" -0"
command+=" -r $directory"
if [ -n "\$(ls -A ubuntu-binds)" ]; then
    for f in ubuntu-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -b ubuntu-fs/tmp:/dev/shm"
command+=" -b /data/data/com.termux"
command+=" -b /:/host-rootfs"
command+=" -b /sdcard"
command+=" -b /storage"
command+=" -b /mnt"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m The start script has been successfully created!\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Fixing shebang of startubuntu, please wait...\n"
termux-fix-shebang $bin
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Successfully fixed shebang of startubuntu! \n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Making startubuntu executable please wait...\n"
chmod +x $bin
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Successfully made startubuntu executable\n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Cleaning up please wait...\n"
rm ubuntu.tar.gz -rf
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Successfully cleaned up!\n"
printf "\e[0m"

}
if [ "$1" = "-y" ];then
install1
elif [ "$1" = "" ];then
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;127m[QUESTION]:\e[0m \x1b[38;5;87m Do you want to install ubuntu-in-termux? [Y/n] "

read cmd1
if [ "$cmd1" = "y" ];then
install1
elif [ "$cmd1" = "Y" ];then
install1
else
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
exit
fi
else
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
fi
#Script 2
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m Start script is being set up, please wait...\n"
scubn2=/data/data/com.termux/files/usr/bin/ubuntu
cat > $scubn2 <<- EOM
#!/bin/bash
clear
printf '''     _   _     _   _   _   _   _     _   _   _   _
    / \ / \   / \ / \ / \ / \ / \   / \ / \ / \ / \\
   ( R | B ) ( C | y | b | e | r ) ( G | e | e | k )
    \_/ \_/   \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/

                                    Injoy Ubun2 ^_^

''' | lolcat
/data/data/com.termux/files/home/ubuntu-in-termux/./startubuntu
EOM
chmod +x $scubn2
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m The start script has been successfully set up! \n"
printf "\x1b[38;5;214m[${time1}]\e[0m \x1b[38;5;83m[Installer]:~>\e[0m \x1b[38;5;87m The installation complete!  You can now launch Ubuntu from anywhere with [ubuntu] \n"
