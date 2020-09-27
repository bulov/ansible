#!/bin/bash
fhelp(){
 echo "
##############################################################
###########                                       ############
########### myFuncSys.sh  upVer  # New Version OS ############
###########                                       ############  
##############################################################
"
exit 
}
##############################################################
function fupVer () {
   $DEB dnf upgrade        -y --refresh
   $DEB dnf install        -y dnf-plugin-system-upgrade
   $DEB dnf clean packages -y
   $DEB dnf autoremove     -y
   v=$(($(rpm -E %fedora) + 1))
   $DEB dnf system-upgrade -y download --releasever=${v}
   $DEB dnf system-upgrade -y download --releasever=${v} --setopt=module_platform_id=platform:f${v}
   $DEB dnf system-upgrade -y reboot
} ###############################################################
fparted(){
Hd=${1:-z}
for disk in $Hd  ; do
${DEB} parted -s /dev/sd${disk} rm 1 rm 2 rm 3 rm 4
${DEB} parted -s /dev/sd${disk} mklabel gpt
${DEB} parted -a opt -s /dev/sd${disk} mkpart ${HOST}-UEFI 2048s 100M
${DEB} parted -s /dev/sd${disk} set 1 bios_grub on  set 1 boot on
${DEB} parted -a opt -s /dev/sd${disk} mkpart ${HOST}-LVMs 100M 100GB
${DEB} parted -a opt -s /dev/sd${disk} set 2 lvm on
${DEB} parted -a opt -s /dev/sd${disk} mkpart ${HOST}-KVM_VMs 100GB 322GB
${DEB} parted -a opt -s /dev/sd${disk} set 2 lvm on
${DEB} parted  /dev/sd${disk} print free
done
exit

#${DEB} parted -a opt -s /dev/sd${disk} mkpart ${HOST}-UEFI 2048s 4095s
#${DEB} parted -a opt -s /dev/sd${disk} mkpart ${HOST}-LVMs 4096s 60GB
#sgdisk --replicate=/dev/target /dev/source
#sgdisk --replicate=/dev/sdb /dev/sda       # переписать таблицу разделов
partprobe /dev/sd${Hd}                         # активизировать их без перезагрузки ядра
grub2-install --no-floppy /dev/sd${Hd}
#parted -a min -s /dev/sda mkpart PV 250GB 500GB
} ###############################################################
finit(){
myFuncSys.sh 131kvm10 parted b
myFuncSys.sh 131kvm10 root   b
myFuncSys.sh 131kvm10 efi    b
myFuncSys.sh 131kvm10 tun    b
} ###############################################################
froot(){
${DEB} export Hd=${1:-z}
${DEB} export PV=/dev/sd${Hd}2
${DEB} pvcreate ${PV}
${DEB} vgcreate ${HOST} ${PV}
${DEB} lvcreate -L 80G      -n root ${HOST}
${DEB} lvcreate -l 100%free -n swap ${HOST}
${DEB} lvdisplay ${HOST} | grep 'LV Name'
${DEB} mkfs.ext4 /dev/${HOST}/root
${DEB} mkdir -p /mnt/${HOST}
${DEB} mount /dev/${HOST}/root /mnt/${HOST}
${DEB} # xfsdump -p 5 -l 0  -  /  | xfsrestore  -  .
${DEB} dump -u0 -z -f -  /  | (cd /mnt/${HOST} ; restore -rf - )
} ###############################################################
fboot(){
mkfs.ext4 /dev/sd${Hd}1
mount /dev/sd${Hd}1 /mnt/${HOST}/boot
#(cd /boot/efi ; tar --acls  -czf - .)  | tar -xzvf -
(cd /boot ; tar --acls  -czf - .)  | ( cd /mnt/${HOST}/boot ; tar -xzvf - )
## for i in dev dev/pts dev/shm proc sys  run; do mount -o bind /$i /mnt/${HOST}/$i; done
#chroot /mnt/${HOST} /usr/bin/bash --login
} ###############################################################
fbootMV(){
umount /boot/efi
mkdir /bootNew
(cd / ; tar --acls  -czf - .)  | ( cd /bootNew ; tar -xzvf - )
umount /boot
rmdir boot
mv /bootNew /boot
mount /boot/efi
vi /etc/fstab      # comment /boot
exit
grub2-install --no-floppy /dev/sd${Hd}
(cd /boot/efi ; tar --acls  -czf - .)  | tar -xzvf -
(cd /boot/U ; tar --acls  -czf - .)  | (cd /boot/efi ; tar -xzvf - )
mkfs.vfat /dev/${disk}${EFI}

dnf install grub2-efi-modules
mkfs.ext4 /dev/sd${Hd}1
mount /dev/sd${Hd}1 /mnt/${HOST}/boot
#(cd /boot/efi ; tar --acls  -czf - .)  | tar -xzvf -
(cd /boot ; tar --acls  -czf - .)  | ( cd /mnt/${HOST}/boot ; tar -xzvf - )
## for i in dev dev/pts dev/shm proc sys  run; do mount -o bind /$i /mnt/${HOST}/$i; done
#chroot /mnt/${HOST} /usr/bin/bash --login
###/boot/loader/entries
###6686446e57564d5bb03ec0adb4299d4b-5.5.5-200.fc31.x86_64.conf
###linux /boot/vmlinuz-5.5.5-200.fc31.x86_64
###initrd /boot/initramfs-5.5.5-200.fc31.x86_64.img
} ###############################################################
fefi(){
${DEB} export Hd=${1:-z}
${DEB} mkfs.vfat /dev/sd${Hd}1
${DEB} mount  /dev/sd${Hd}1  /mnt/${HOST}/boot/efi
( cd /boot/efi ; tar --acls  -czf - . ) | ( cd /mnt/${HOST}/boot/efi ; tar -xzvf - )
exit
mkfs.vfat /dev/${disk}${EFI}
vi /etc/fstab      # comment /boot
exit
grub2-install --no-floppy /dev/sd${Hd}
(cd /boot/efi ; tar --acls  -czf - .)  | tar -xzvf -
(cd /boot/U ; tar --acls  -czf - .)  | (cd /boot/efi ; tar -xzvf - )
mkfs.vfat /dev/${disk}${EFI}
dnf install grub2-efi-modules
mkfs.ext4 /dev/sd${Hd}1
mount /dev/sd${Hd}1 /mnt/${HOST}/boot
#(cd /boot/efi ; tar --acls  -czf - .)  | tar -xzvf -
(cd /boot ; tar --acls  -czf - .)  | ( cd /mnt/${HOST}/boot ; tar -xzvf - )
for i in dev dev/pts dev/shm proc sys  run; do mount -o bind /$i /mnt/${HOST}/$i; done
chroot /mnt/${HOST} /usr/bin/bash --login
###/boot/loader/entries
###6686446e57564d5bb03ec0adb4299d4b-5.5.5-200.fc31.x86_64.conf
###linux /boot/vmlinuz-5.5.5-200.fc31.x86_64
###initrd /boot/initramfs-5.5.5-200.fc31.x86_64.img
} ###############################################################
fbind(){
for i in dev dev/pts dev/shm proc sys  run; do mount -o bind /$i /mnt/${HOST}/$i; done
chroot /mnt/${HOST} /usr/bin/bash --login
} ###############################################################
fgrub(){
${DEB} export Hd=${1:-z}
hostnamectl set-hostname ${HOST}
export HOST=$(hostname -s)
UUID=$(blkid /dev/sd${Hd}1 | cut -d'"' -f4)
cat >/etc/fstab  <<EoL
UUID=${UUID}      /boot/efi               vfat    umask=0077,shortname=winnt 0 2
/dev/${HOST}/root /                       ext4    defaults        0 0
/dev/${HOST}/swap swap                    swap    defaults        0 0
EoL

cat >/etc/sysconfig/grub  <<EoL
RUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="resume=/dev/${HOST}/swap rd.lvm.lv=${HOST}/root rd.lvm.lv=${HOST}/swap rhgb"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EoL
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
grub2-install --no-floppy --boot-directory=/boot /dev/sd${Hd}
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
efibootmgr -c -d /dev/sd${Hd} -p 1 -l /EFI/fedora/shimx64-fedora.efi -L "${HOST}"
efibootmgr -v
ver=$( uname --kernel-release )
dracut -f /boot/initramfs-${ver}.img ${ver}
} ###############################################################
fsystemd(){
NM=$1
DEV=$2
UUID=$(IFS== ; set $(xfs_admin -u ${DEV}); echo "${2#"${2%%[![:space:]]*}"}" )
UUID=$(IFS=: ; set $(tune2fs -l ${DEV} | grep UUID); echo "${2#"${2%%[![:space:]]*}"}" )

cat <<END >/etc/systemd/system/mnt-${NM}.mount
[Unit]
Description = unit file to mount file system
#Requires = vdo.service
Conflicts = umount.target

[Mount]
What = /dev/disk/by-uuid/${UUID}
Where = /mnt/${NM}
Options = discard

[Install]
WantedBy = multi-user.target
END
${DEB} systemctl daemon-reload
${DEB} systemctl enable --now mnt-${NM}.mount
}
############################################################################
#set -x
export HOST=$(hostname -s)
export DEB=""
[ _debug = _${!#} -o _deb = _${!#} ] && export DEB="echo "
[ 1 -gt $# ] && fhelp
FN=$1      #function
shift
f${FN} $*



f(){
export HOST=$(hostname -s)

mount /dev/${HOST}/root /mnt/${HOST}
mount /dev/${HOST}/efi  /mnt/${HOST}/boot/efi
for i in dev dev/pts dev/shm proc sys  run; do mount -o bind /$i /mnt/${HOST}/$i; done
chroot /mnt/${HOST} /usr/bin/bash --login
mount -t efivarfs efivarfs /sys/firmware/efi/efivars

efibootmgr -c -d /dev/131kvm10/efi  -w -L "131kvm10" -l '\EFI\fedora\shimx64-fedora.efi'
efibootmgr -c -d /dev/sdb -p 0 -w -L "131kvm10" -l '\EFI\fedora\shimx64-fedora.efi'

ver=$( uname --kernel-release )
dracut -f /boot/initramfs-${ver}.img ${ver}



}
