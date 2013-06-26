# live cd / # nano filename2.sh
# copy and paste the Part II code to that file
# live cd / # chmod +x filename2.sh
# live cd / # and ./filename2.sh
# Part II Start form here

function autoip(){
/lib/rc/bin/ebegin "Auto Detecting ip address"
netcard=$(netstat -rn | grep 0.0.0.0 | grep UG | awk '{print$8}')
ipaddress=$(ifconfig "$netcard" | grep Bcast: | awk '{print$2}' | cut -b6-20)
broadcast=$(ifconfig "$netcard" | grep Bcast: | awk '{print$3}' | cut -b7-21)
netmask=$(ifconfig "$netcard" | grep Bcast: | awk '{print$4}' | cut -b6-20)
gateway=$(netstat -rn | grep 0.0.0.0 | grep UG | awk '{print$2}')
dns1=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' |  head -1)
dns2=$(cat /etc/resolv.conf | awk '/nameserver/{getline; print}'| awk '{print$2}')
if [ -z $ipaddress ] || [ -z $netmask ] || [ -z $gateway ]; then
/lib/rc/bin/eend 1
manualip
else
/lib/rc/bin/eend 0
fi
}

function manualip(){
echo "Type your default network card [eth0 or eth1]"
read netcard
echo "Please enter your ip address: "
read ipaddress
echo "Please enter your subnetmask: "
read netmask
echo "Please enter your broadcast address: "
read broadcast
echo "Please enter your default gateway: "
read gateway
echo "Please enter your Primary DNS: "
read dns1
echo "Please enter your Secondary DNS: "
read dns2
}

function askhdd(){
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo "Please enter you partation table manually"
echo "Type your boot partation number [1 or 2 or 3]"
read hddno1
hdd1="$hdtype$hddno1"
echo "Type your swap partation number [1 or 2 or 3]"
read hddno2
hdd2="$hdtype$hddno2"
echo "Type your root partation number [1 or 2 or 3]"
read hddno3
hdd3="$hdtype$hddno3"
}

function manualhdd(){
echo "Setup cannot detect your partation table automatically"
echo "Your Partation table is"
fdisk -l | grep -w /dev
while true; do
    read -p "Do you want to Create or Modify the Partation table? [y/n]" yn
    case $yn in
        [Yy]* )  hdtype=$(fdisk -l | grep da: | awk '{print$2}' | cut -c6-8);
                    fdisk /dev/$hdtype;
                    autohdd;
                    break;;
        [Nn]* ) hdtype=$(fdisk -l | grep da: | awk '{print$2}' | cut -c6-8);
                    askhdd;
                    break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}
function autohdd(){
/lib/rc/bin/ebegin "Auto Detecting partation table"
thdd1=$(fdisk -l | grep -w /dev | grep -v Disk | awk '{print$1}' | cut -c6-9 | grep a1)
thdd1size=$( fdisk -l | grep -w /dev | grep a1 |grep -v Disk | awk '{print$4}')
thdd1type=$(fdisk -l | grep -w /dev | grep a1 |grep -v Disk | awk '{print$5}')
thdd2=$(fdisk -l | grep -w /dev | grep -v Disk | awk '{print$1}' | cut -c6-9 | grep a2)
thdd2size=$( fdisk -l | grep -w /dev | grep a2 |grep -v Disk | awk '{print$4}')
thdd2type=$(fdisk -l | grep -w /dev | grep a2 |grep -v Disk | awk '{print$5}')
thdd3=$(fdisk -l | grep -w /dev | grep -v Disk | awk '{print$1}' | cut -c6-9 | grep a3)
thdd3size=$( fdisk -l | grep -w /dev | grep a3 |grep -v Disk | awk '{print$4}')
thdd3type=$(fdisk -l | grep -w /dev | grep a3 |grep -v Disk | awk '{print$5}')
if [ -z $thdd1 ] || [ -z $thdd2 ] || [ -z $thdd3 ]; then
/lib/rc/bin/eend 1
manualhdd
elif [ $thdd1type == 82 ]; then
 hdd2=$thdd1
  if [ $thdd2size -gt $thdd3size ]; then
  hdd3=$thdd2
  hdd1=$thdd3
/lib/rc/bin/eend $?
  elif [ $thdd3size -gt $thdd2size ]; then
  hdd3=$thdd3
  hdd1=$thdd2
/lib/rc/bin/eend $?
  else
  manualhdd
  fi

elif [  $thdd2type == 82 ]; then
hdd2=$thdd2
  if [ $thdd1size -gt $thdd3size ]; then
hdd3=$thdd1
hdd1=$thdd3
/lib/rc/bin/eend $?
  elif [ $thdd3size -gt $thdd1size ]; then
hdd3=$thdd3
hdd1=$thdd1
/lib/rc/bin/eend $?
  else
  manualhdd
 fi
elif [ $thdd3type == 82 ]; then
hdd2=$thdd3
  if [ $thdd1size -gt $thdd2size ]; then
hdd3=$thdd1
hdd1=$thdd2
/lib/rc/bin/eend $?

  elif [ $thdd2size -gt $thdd1size ]; then
hdd3=$thdd2
hdd1=$thdd1
/lib/rc/bin/eend $?
  else
  manualhdd
  fi
else
/lib/rc/bin/eend 1
echo "There is no Swap Partation in partation table"
manualhdd
fi
}
/lib/rc/bin/ebegin "Updating profile"
source /etc/profile
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Building Portage Dir"
mkdir /usr/portage
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Emerge Portage"
emerge-webrsync
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Setting up Time Zone"
cp /usr/share/zoneinfo/Asia/Singapore /etc/localtime
/lib/rc/bin/eend $?

echo "Select your profile"
eselect profile list
read profile

/lib/rc/bin/ebegin "setting System Profile"
eselect profile set $profile
/lib/rc/bin/eend $?

/lib/rc/bin/ebegin "Change folder"
cd /etc
/lib/rc/bin/eend $?
while true; do
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo
echo "enter your host hostname"
read hostname1
echo "enter your domain name"
read domain
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo 
autohdd
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo
while true; do
    read -p "Do you want to use your current ip address? [y/n]" yn
    case $yn in
        [Yy]* ) autoip;
  	    break;;
		[Nn]* ) manualip;
		    break;;
        * ) echo "Please answer yes or no.";;
    esac
done
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo
while true; do
    echo "Are u installing gentoo in esx or vmware ? Than we have a ready made .config file (don't need kernel combine)"
    read -p "Do you want to download .config file [y/n]" yn
    case $yn in
        [Yy]* ) conf=$"y";
                break;;
        [Nn]* ) conf=$"n";
		    break;;
        * ) echo "Please answer yes or no";;
    esac
done
echo
echo "Your $netcard configuration is -"
echo "- IPaddress--------------$ipaddress"
echo "- Subnetmask-------------$netmask"
echo "- Broadcast address------$broadcast"
echo "- Default Gateway -------$gateway"
echo "- Primary DNS -----------$dns1"
echo "- Secondary DNS----------$dns2" 
echo
echo "Your are using -"
echo "- $hdd1 as boot device"
echo "- $hdd2 as swap device"
echo "- $hdd3 as root device"
echo 
echo "Your Hostname will be $hostname1.gentoo.$domain"
echo
    read -p "Is the above configurations are correct?[y/n]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) ;;
        * ) echo "Please answer y/n";;
    esac
done
/lib/rc/bin/ebegin "Change folder"
cd /etc
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Setting up Host Name"
echo "127.0.0.1 $hostname1.gentoo.$domain $hostname1 localhost" > hosts && sed -i -e 's/HOSTNAME.*/HOSTNAME="'$hostname1'"/' conf.d/hostname && sed -i -e 's/hostname.*/hostname="'$hostname1'"/' conf.d/hostname
/lib/rc/bin/eend $?
hostname $hostname1
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo "Your Host name is "
hostname -f
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Setting up DNS Servers"
rm /etc/resolv.conf
echo 'nameserver '$dns1'' >> resolv.conf && echo 'nameserver '$dns2'' >> resolv.conf
/lib/rc/bin/eend $?
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
/lib/rc/bin/ebegin "Emerging gentoo-sources"
emerge gentoo-sources
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Change folder"
cd /usr/src/linux
/lib/rc/bin/eend $?
if [ "$conf" = "y" ]; then
/lib/rc/bin/ebegin "Removing old config file"
rm /usr/src/linux/.config
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Downloading new config file"
wget http://172.16.10.251/mirror/.config
/lib/rc/bin/eend $?
elif [ "$conf" = "n" ]; then
/lib/rc/bin/ebegin "Making menuconfig"
make menuconfig
/lib/rc/bin/eend $?;
fi
/lib/rc/bin/ebegin "make -j2"
make -j2 
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "make modules_install"
make modules_install
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Copying bzImage"
cp arch/i386/boot/bzImage /boot/kernel
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Removing fstab"
rm /etc/fstab
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Configuring fstab"
touch /etc/fstab && echo '/dev/'$hdd1'   /boot      ext2    noauto,noatime     1 2' >> /etc/fstab && echo '/dev/'$hdd3'   /          ext3    noatime            0 1' >> /etc/fstab && echo '/dev/'$hdd2'   none       swap    sw                 0 0' >> /etc/fstab && echo '/dev/cdrom  /mnt/cdrom    auto    noauto,ro          0 0' >> /etc/fstab
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Change folder"
cd /etc/init.d
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Configuring Network Card"
ln -s net.lo net.$netcard
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Change folder"
cd ../conf.d
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Configure IP address"
echo 'config_'$netcard'="'$ipaddress' netmask '$netmask' brd '$broadcast'"' >> net
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Configure Default Gateway"
echo 'routes_'$netcard'="default via '$gateway'"' >> net
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Add Network card to start automatically"
rc-update add net.$netcard default
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Add SSH to start automatically"
rc-update add sshd default
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "emerging grub"
emerge grub
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Configuring grub"
rm /boot/grub/grub.conf && touch /boot/grub/grub.conf && echo 'default 0' >> /boot/grub/grub.conf && echo 'timeout 5' >> /boot/grub/grub.conf && echo 'title '$hostname1' Gentoo' >> /boot/grub/grub.conf && echo 'root (hd0,0)' >> /boot/grub/grub.conf && echo 'kernel /boot/kernel root=/dev/'$hdd3'' >> /boot/grub/grub.conf 
/lib/rc/bin/eend $?
/lib/rc/bin/ebegin "Setup grub"
echo -e "root (hd0,0) \n setup (hd0)" | grub
/lib/rc/bin/eend $?
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo "Enter Your root Password:"
passwd root
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
echo "Gentoo Installation is finish"
printf -v f "%"$(tput cols)"s" ; printf "%s\n" "${f// /*}"
while true; do
    read -p "Do you want to Reboot your box now? [y/n]" yn
    case $yn in
        [Yy]* ) echo "Thank you for using my script";   
                echo "Hopefully it will boot up successfully";
                reboot;
                break;;
        [Nn]* ) echo "Thank you for using my script";
                echo "The installation process will exit now";
                exit;;
        * ) echo "Please answer yes or no";;
    esac
done
