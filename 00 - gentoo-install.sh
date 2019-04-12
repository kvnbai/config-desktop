
#!/bin/bash
# NOTE this script is only tested in my machines

echo "Checking if UEFI mode is enabled..."

if [ -d /sys/firmware/efi/efivars ]; then
  echo "UEFI mode is enabled..."
else
  echo "UEFI mode is not enabled..."
fi

while true; do
  read -p "Do you want to proceed [Yn]?   " p
  case $p in
    [Nn]* )
      if [ -d /sys/firmware/efi/efivars ]; then
        echo "UEFI mode is enabled..."
      else
        echo "UEFI mode is not enabled..."
      fi
      ;;
    * ) break;;
  esac
done

## Start partition management
echo '


Partitions:
'

parted -l


while true; do
  read -p "

HD PARTITION

Choose partition action:
    [s]how all
    [l]abel
    show [f]ree
    [d]elete
    [c]reate
    [n]ame
    [m]ake flag
    f[o]rmat
    [p]roceed

Enter action:   " slfdcmop
  case $slfdcmop in
    [Ss]* ) echo '
      
      
      '
      parted -l
      echo '
      
      
      ';;
    [Ll]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Partition label (e.g. gpt, msdos) or [e]xit   " pl
              case $pl in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Relabeling a partition will delete ALL of its contents. Do you want to continue [yN]?   " yn
                    case $yn in
                      [Yy]* ) parted -s $tp mklabel $pl
                        echo '
                        
                        
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                      * ) break 3;;
                    esac
                  done
              esac
            done;;
        esac
      done;;
    [Ff]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX)   " tp
        case $tp in
          * ) echo '
          
          
          '
          parted -s $tp print free
          echo '
          
          
          '
          break;;
        esac
      done;;
    [Dd]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * ) echo $tp
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Are you sure you want to delete $tp Num $pn [yN]?   " yn
                    case $yn in
                      [Yy]* ) echo Deleting Partition $tp Num $pn
                        parted -s $tp rm $pn
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                      * ) echo No
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Cc]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Filesysten type (e.g. fat32, ext4, linux-swap, HFS) or [e]xit   " fs
              case $fs in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "


Starting point -- Examples:
1. 0% - If this is your 1st partition
2. 512MiB - If your last partition ends on 512MB

Units available are: s (sectors), B (bytes), kBm kiB, MB, MiB, GB, GiB, TB, TiB, %

or [e]xit

Enter starting point:   " sp
                    case $sp in
                      [Ee] ) break 3;;
                      * )
                        while true; do
                          read -p "


Ending point -- Examples:
1. 512MiB - If this is your first partition and you want to make it 512MB
2. 1024MiB - If your starting point is 512MB (first partition size is 512MiB) then create this partition as another 512MiB.
3. 100% - use all remaining free space.

Units available are: s (sectors), B (bytes), kBm kiB, MB, MiB, GB, GiB, TB, TiB, %

or [e]xit

Enter ending point:   " ep
                          case $ep in
                            [Ee] ) break 4;;
                            * ) parted -s $tp mkpart primary $fs $sp $ep;
                            echo '
                            
                            '
                            parted -l
                            echo '
                            
                            '
                            break 4;;
                          esac
                        done;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Nn]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * ) echo $tp
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Partition name   " nm
                    case $nm in
                      * )
                        parted $tp name $pn $nm
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Mm]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Flag (e.g. esp, boot, root, swap) or [e]xit   " pf
                    case $pf in
                      [Ee] ) break 3;;
                      * )
                        while true; do
                          read -p "State (e.g. on, off) or [e]xit   " ps
                          case $ps in
                            [Ee] ) break 4;;
                            * ) parted -s $tp set $pn $pf $ps;
                            echo '
                            
                            
                            '
                            parted -l
                            echo '
                            
                            
                            '
                            break 4;;
                          esac
                        done;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Oo]* )
      while true; do
        fdisk -l
        read -p "Choose device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Filesystem type by mkfs (e.g. vfat, ext4) or [e]xit   " fs
              case $fs in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Options[not required] (e.g. -F32) or [e]xit   " o
                    case $o in
                      [Ee] ) break 3;;
                      * ) mkfs.$fs $o $td;
                        echo '
                        
                        
                        '
                        fdisk -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Pp]* )
      while true; do
        read -p "Are you sure you want to proceed with the installation [yN]?   " yn
        case $yn in
          [Yy]* ) echo '
            
            
            Partitions:
            '
            parted -l
            echo '
            
            
            '
            break 2;;
          * ) break;;
        esac
      done;;
    * ) echo 'Invalid input'
  esac
done
## End partition management

## Start swap initialization
while true; do
  read -p "Initialize swap partition [yN]   " yn
  case $yn in
    [Yy]* )
      while true; do
        fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * ) mkswap $td; swapon $td; break;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "

MOUNTING

NOTE: Mount your root partition before anything else. Mount your boot
partition here

Do you want to mount partitions [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        echo "Mount your root partition before mounting the boot partition"
        fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Mount point (e.g. /) or [e]xit   " mp
              case $mp in
                [Ee] ) break 2;;
                * ) mkdir -p /mnt/gentoo$mp; mount $td /mnt/gentoo$mp; break 2;;
              esac
            done;;
        esac
      done;;
  esac
done
## End swap initialization

## Date
while true; do
  date
  read -p "If the date is wrong, run ntpd. Run ntpd [yN]?   " rntpd
  case $rntpd in
    [Yy]* ) ntpd -q -g; break;;
    * ) break;;
  esac
done

cd /mnt/gentoo

while true; do
  read -p "
Download the Stage 3 tarball. Follow the steps bellow:

1. Open tty2 terminal (Ctrl + Alt + F2)
2. Execute 'cd /mnt/gentoo && links https://www.gentoo.org/downloads/mirrors/'
3. Go to a mirror link (Preferably you country)
4. Navigate to: releases > amd64 > autobuilds > current-stage3-amd64
5. Save stage3-amd64-<build-id>.tar.xz
6. Go back to tty1 (Ctrl + Alt + F1) and proceed

Proceed [yN]   " tbd
  case $tbd in
    [Yy]* )
      tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner;
      rm stage3-*;
      break;;
    * ) ;;
  esac
done

while true; do
  grep -m1 -A3 "vendor_id" /proc/cpuinfo
  read -p "
https://wiki.gentoo.org/wiki/Safe_CFLAGS
Update CPU Flags [yN]?   " ucpuf
  case $ucpuf in
    [Yy]* )
      chost=
      cflags=
      mkopts=

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "CHOST"; then
          cchost=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^CHOST' | head -1)
          echo "Current: $cchost"
        fi
        read -p "Enter CHOST or [e]xit:   " chst
        case $chst in
          [Ee] ) break;;
          * ) chost="$chst"; break;;
        esac
      done

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "COMMON_FLAGS"; then
          ccflags=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^COMMON_FLAGS' | head -1)
          echo "Current: $ccflags"
        fi
        read -p "Enter COMMON_FLAGS or [e]xit:   " cflgs
        case $cflgs in
          [Ee] ) break;;
          * ) cflags="$cflgs"; break;;
        esac
      done

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "MAKEOPTS"; then
          cmkopts=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^MAKEOPTS' | head -1)
          echo "Current: $cmkopts"
        fi
        read -p "How many threads would like to use or [e]xit   " numt
        case $numt in
          [Ee]* ) break;;
          * )
            if [[ $numt =~ ^[0-9]+$ ]]; then
              mkopts="-j$numt";
              break;
            else
              echo Invalid number;
              break;
            fi
            echo '';;
        esac
      done

      while true; do
        read -p "
Changes:

CHOST=\"$chost\"
COMMON_FLAGS=\"$cflags\"
MAKEOPTS=\"$mkopts\"

Commit [yN]?   " cmtchng
        case $cmtchng in
          [Yy]* )
            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "CHOST"; then
              sed -i "s/CHOST=.*/CHOST=\"$chost\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "CHOST=\"$chost\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "COMMON_FLAGS"; then
              sed -i "s/COMMON_FLAGS=.*/COMMON_FLAGS=\"$cflags\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "COMMON_FLAGS=\"$cflags\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "MAKEOPTS"; then
              sed -i "s/MAKEOPTS=.*/MAKEOPTS=\"$mkopts\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "MAKEOPTS=\"$mkopts\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Select action: [r]econfigure | [e]xit   " ftch
        case $ftch in
          [Rr]* ) break;;
          [Ee]* ) break 2;;
          * ) echo "Invalid input"
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "Select mirrors [Yn]?   " smrrs
  case $smrrs in
    [Nn]* ) break;;
    * ) mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf; clear; break;;
  esac
done

mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev 


echo "

#!/bin/bash

execute_additional_commands() {
  while true; do
    read -p \"
You might want to execute commands like:

eselect news read
emerge --oneshot portage

You can execute it here or just enter \"e\" to exit. Only execute commands
you need.

Action: \" cmd
    case \$cmd in
      [Ee] ) break;;
      * ) \$cmd;;
    esac
  done
}

source /etc/profile

emerge-webrsync
execute_additional_commands

emerge --sync
execute_additional_commands

while true; do
  read -p \"Update profile [Yn]?   \" updtp
  case \$updtp in
    [Nn]* ) break;;
    * )
      while true; do
        eselect profile list
        read -p \"Profile to set:   \" pts
        case \$pts in
          * )
            if [[ \$pts =~ ^[0-9]+$ ]]; then
              eselect profile set \$pts
              echo \"Profile \$pts selected\"
              break;
            else
              echo \"Invalid number\";
            fi;;
        esac
      done;;
  esac
done

emerge --ask --verbose --update --deep --newuse @world
execute_additional_commands

while true; do
  read -p \"Set timezone (e.g. America/Chicago)   \" tz
  case \$tz in
    * )
      if [[ \$tz =~ ^[a-zA-Z]+/[a-zA-Z]+$ ]]; then
        if ls /usr/share/zoneinfo/\$tz 2> /dev/null; then
          echo \$tz > /etc/timezone
          emerge --config sys-libs/timezone-data
          break;
        else
          echo Timezone doesnt exist
        fi
      else
        echo Invalid input
      fi
  esac
done

while true; do
  read -p \"Actions: [a]ctivate locales | [d]eactivate locales | [g]enerate locales | [e]xit   \" a
  case \$a in
    [Aa] )
      while true; do
        read -p \"Activate locale (e.g. 'en_US.UTF-8 UTF-8') or [e]xit   \" al
        case \$al in
          [Ee] ) break;;
          * ) sed -i \"s/^#\$al/\$al/g\" /etc/locale.gen
            echo Activated \$al;
            break;;
        esac
      done;;
    [Dd] )
      while true; do
        read -p \"Deactivate locale (e.g. 'en_US.UTF-8 UTF-8') or [e]xit   \" dl
        case \$dl in
          [Ee] ) break;;
          * ) sed -i \"s/^\$dl/#\$dl/g\" /etc/locale.gen
            echo Dectivated \$dl;
            break;;
        esac
      done;;
    [Gg] ) locale-gen;;
    [Ee] ) break;;
    * ) echo Invalid input
  esac
done

while true; do
  read -p \"Set LANG (e.g. 'en_US.UTF-8') or [e]xit   \" l
  case \$l in
    [Ee] ) break;;
    * )
      echo \"LANG=\$l\" | tee /etc/locale.conf
      echo \"LANG=\$l\" | tee /etc/env.d/02locale
      ;;
  esac
done

###### VERIF
hwclock --systohc
while true; do
  read -p \"Set KEYMAP (e.g. us, de-latin1) or [e]xit   \" k
  case \$k in
    [Ee] ) break;;
    * ) echo \"KEYMAP=\$k\" | tee /etc/vconsole.conf;;
  esac
done

while true; do
  read -p \"Enter hostname or [e]xit   \" hn
  case \$hn in
    [Ee] ) break;;
    * )
      if test -z \"\$hn\"; then
        echo Invalid input
      else
        echo \$hn | tee /etc/hostname && echo \"

127.0.0.1    localhost
::1          localhost
127.0.1.1    \$hn.localdomain \$hn

\" | tee /etc/hosts;
      fi
  esac
done
##### VERIFEND

env-update
source /etc/profile

emerge --ask sys-kernel/gentoo-sources
emerge --ask sys-apps/pciutils


while true; do
  read -p \"Auto generate your kernel [Yn]?   \" agk
  case \$agk in
    [Nn]* )
      cd /usr/src/linux
      make menuconfig

      make
      make modules_install
      make install
      etc-update

      emerge --ask sys-kernel/genkernel
      genkernel --install initramfs
      break;;
    * )
      emerge --ask sys-kernel/genkernel
      // TODO: update fstab
      genkernel all
  esac
done

echo '

###################################
###################################
###                             ###
###    INSTALLATION COMPLETE    ###
###    YOU CAN REBOOT NOW...    ###
###                             ###
###################################
###################################

'




































" | tee /mnt/gentoo/gentoo-install;


echo '

#####################################
#####################################
###                               ###
###  EXECUTE bash gentoo-install  ###
###  UPON ENTERING THE CHROOT     ###
###                               ###
#####################################
#####################################

'

chroot /mnt/gentoo /bin/bash
