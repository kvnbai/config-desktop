
#!/bin/bash

while true; do
  read -p "
If sudo is not enabled during installation (Debian). Login as root (on tty2) then execute the
commands below before proceeding.

apt install -y sudo
groupadd wheel
usermod -aG wheel $(whoami)
usermod -aG sudo $(whoami)
usermod -g wheel $(whoami)
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers

Changes will reflect on the next login. Proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) echo "";;
    * ) break;;
  esac
done

while true; do
  read -p "Will use for dual boot with other linux [yN]?   " wdb
  case $wdb in
    [Yy]* )
      while true; do
        echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
        read -p "Enter UID or [e]xit:   " uid
        case $uid in
          [Ee]* ) break;;
          * )
            while true; do
              echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2:

usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Would you like to proceed [Yn]?   " wultp
                    case $wultp in
                      [Nn]* ) ;;
                      * )
                        break 4;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    * ) break;;
  esac
done

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

sudo dpkg --add-architecture i386
if [ "$os" = "debian" ]; then
  if cat /etc/apt/sources.list | grep -q "main contrib non-free"; then
    echo "Non-free repos already added."
  else
    sudo sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
    echo "Non-free repos added."
  fi
fi

sudo apt update
sudo apt -y upgrade

# non-free kernel drivers
sudo apt install -y --no-install-recommends firmware-linux-nonfree

sudo apt install -y build-essential linux-headers-$(uname -r)
sudo apt install -y --no-install-recommends autoconf automake cmake make dkms pkgconf

sudo apt install -y --no-install-recommends at
sudo systemctl enable atd
sudo systemctl start atd

# Sound
sudo apt install -y --no-install-recommends alsa-utils

# Gstreamer
sudo apt install -y --no-install-recommends gstreamer1.0-x gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-vaapi
sudo apt install -y --no-install-recommends gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

sudo apt install -y --no-install-recommends openjdk-11-jdk
sudo apt install -y browser-plugin-freshplayer-pepperflash

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* )
      sudo apt install -y --no-install-recommends intel-microcode
      break;;
    [Aa]* )
      sudo apt install -y --no-install-recommends amd64-microcode
      break;;
    * ) echo Invalid input
  esac
done

## GPU DRIVERS
generate_intel_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/20-intel.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  echo '
Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
EndSection

Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
  Option      "TearFree" "true"
  Option      "DRI"    "3"
EndSection
  ' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;


  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

generate_ati_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/20-radeon.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-radeon.conf;
  fi

  echo '
Section "Device"
  Identifier "Radeon"
  Driver "radeon"
EndSection

Section "Device"
  Identifier  "Radeon"
  Driver "radeon"
  Option "AccelMethod" "glamor"
  Option "DRI" "3"
  Option "TearFree" "on"
  Option "ColorTiling" "on"
  Option "ColorTiling2D" "on"
  Option "SWCursor" "True"
EndSection
' | sudo tee -a /etc/X11/xorg.conf.d/20-radeon.conf;

  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

generate_amd_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/10-screen.conf ];then
    sudo touch /etc/X11/xorg.conf.d/10-screen.conf;
  fi

  if [ ! -f /etc/X11/xorg.conf.d/20-radeon.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-radeon.conf;
  fi

  echo '
Section "Screen"
  Identifier     "Screen"
  DefaultDepth    24
  SubSection      "Display"
    Depth         24
  EndSubSection
EndSection
' | sudo tee -a /etc/X11/xorg.conf.d/10-screen.conf;

  echo '
Section "Device"
  Identifier "AMD"
  Driver "amdgpu"
EndSection

Section "Device"
  Identifier  "AMD"
  Driver "amdgpu"
  Option "DRI" "3"
  Option "TearFree" "on"
  Option "SWCursor" "True"
EndSection
' | sudo tee -a /etc/X11/xorg.conf.d/20-radeon.conf;


  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

while true; do
  read -p "

What GPU are you using?
  [i]ntel
  [a]md
  [n]vidia
  [v]m
  [e]xit

Enter GPU:   " gpui
  case $gpui in
    [Vv]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-vmware
      echo Driver for VM installed;
      break;;
    [Ii]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-intel
      # 32bit packages included
      sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx

      sudo apt install -y --no-install-recommends libvulkan1
      sudo apt install -y --no-install-recommends mesa-vulkan-drivers
      generate_intel_gpu_config
      echo Intel drivers installed;
      break;;
    [Aa]* )
      while true; do
        read -p "


What driver to use?
  Check: https://en.wikipedia.org/wiki/Template:AMD_graphics_API_support
  [1] AMDGPU    - GCN 3, GCN 4 and newer
  [2] ATI       - TeraScale 1, TeraScale 2, TeraScale 3, GCN 1, GCN 2
  [e]xit
  " amdd
        case $amdd in
          [1]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-amdgpu
            # 32bit packages included
            sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx libva-glx1

            generate_amd_gpu_config
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-ati
            # 32bit packages included
            sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx libva-glx1

            sudo apt install -y --no-install-recommends libvulkan1
            sudo apt install -y --no-install-recommends mesa-vulkan-drivers

            generate_ati_gpu_config
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-nvidia nvidia-detect
      # 32bit packages included
      sudo apt install -y nvidia-driver libgl1-mesa-dri libgl1-nvidia-glx nvidia-xconfig

      generate_nvidia_gpu_config
      sudo nvidia-xconfig
      echo NVIDIA drivers installed;
      break;;
  esac
done

# Adding intel backlight
if ls /sys/class/backlight | grep -q "^intel_backlight$"; then
  if [ !$(ls /etc/X11/xorg.conf.d | grep -q ^20-intel.conf$) ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  echo '
Section "Device"
  Identifier  "Card0"
  Driver      "intel"
  Option      "Backlight"  "intel_backlight"
EndSection
  ' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;
    echo Added intel_backlight;
fi

## Hardware acceleration drivers installation
sudo apt install -y --no-install-recommends mesa-va-drivers mesa-vdpau-drivers
sudo apt install -y --no-install-recommends libvdpau1 libvdpau-va-gl1

# Network
while true; do
  lspci -nnk | grep 0280 -A3
  read -p "


Wireless drivers installation:
If your driver is not listed, check:
https://wiki.archlinux.org/index.php/Wireless_network_configuration

[1] Show Network Controller
[2] Broadcom
[m] Modprobe a module
[e] Exit

Enter action:   " wd
  case $wd in
    [Ee]* ) break;;
    [Mm]* )
      while true; do
        read -p "Enter module:   " m
        case $m in
          * ) sudo modprobe -a $m; break;;
        esac
      done;;
    [1] ) lspci | grep Network;;
    [2] )
      sudo apt install -y --no-install-recommends linux-headers-$(uname -r) linux-image-$(uname -r);
      sudo apt install -y --no-install-recommends broadcom-sta-dkms wireless-tools;
      sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
      sudo modprobe wl
      echo "
Installation done...
";;
  esac
done

# TRRS
while true; do
  read -p "
Detect microphone plugged in a 4-pin 3.5mm (TRRS) jack [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        echo "
Devices:
"
        aplay --list-devices
        read -p "


Check your HD Audio model here:
https://dri.freedesktop.org/docs/drm/sound/hd-audio/models.html or
http://git.alsa-project.org/?p=alsa-kernel.git;a=blob;f=Documentation/sound/alsa/HD-Audio-Models.txt;hb=HEAD

Enter HD Audio Model (e.g. mbp101, macbook-pro, laptop-dmic etc) or [e]xit:   " hdam
        case $hdam in
          [Ee] ) break 2;;
          * )
            sudo touch /etc/modprobe.d/alsa-base.conf;
            echo "
options snd_hda_intel index=0
options snd_hda_intel model=$hdam" | sudo tee /etc/modprobe.d/alsa-base.conf
            break;;
        esac
      done;;
  esac
done


if [ -d /etc/gdm ]; then
  # use lightdm instead
  sudo systemctl disable gdm
fi

# Greeter
sudo apt install -y --no-install-recommends lightdm slick-greeter
sudo apt install -y --no-install-recommends fonts-noto
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=slick-greeter/g' /etc/lightdm/lightdm.conf

if cat /usr/lib/systemd/system/lightdm.service | grep -q 'Alias=display-manager.service'; then
  if cat /usr/lib/systemd/system/lightdm.service | grep -q '\[Install\]'; then
    echo '[Install]' | sudo tee -a /usr/lib/systemd/system/lightdm.service
  fi

  echo 'Alias=display-manager.service' | sudo tee -a /usr/lib/systemd/system/lightdm.service
fi

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# Install window tiling manager
sudo apt install -y --no-install-recommends i3 i3status i3lock rxvt-unicode

# File manager
sudo apt install -y --no-install-recommends nautilus

if [ ! -f "$HOME/.riced" ];then
  mkdir -p $HOME/.config
  mkdir -p $HOME/.config/i3

  # Fix default i3 config
  sudo cp /etc/i3/config $HOME/.config/i3/config
  sudo chown $(whoami):$(whoami) $HOME/.config/i3/config

  sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
  sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config
  sed -i 's/dmenu_run/dmenu/g' $HOME/.config/i3/config

  sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
  sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config
  sudo sed -i 's/dmenu_run/dmenu/g' /etc/i3/config

  cp -raf $(pwd)/rice/xinitrc $HOME/.xinitrc

  echo '
*.foreground:   #c5c8c6
*.background:   #1d1f21
*.cursorColor:  #c5c8c6
*.color0:       #282a2e
*.color8:       #373b41
*.color1:       #a54242
*.color9:       #cc6666
*.color2:       #8c9440
*.color10:      #b5bd68
*.color3:       #de935f
*.color11:      #f0c674
*.color4:       #5f819d
*.color12:      #81a2be
*.color5:       #85678f
*.color13:      #b294bb
*.color6:       #5e8d87
*.color14:      #8abeb7
*.color7:       #707880
*.color15:      #c5c8c6

  ' | tee $HOME/.Xresources
fi

sudo cp $HOME/.Xresources /root/.Xresources

mainCWD=$(pwd)
while true; do
  read -p "

Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )

      # will use for manually installed packages, /tmp has limited space
      cd /tmp

      sudo apt install -y --no-install-recommends curl wget vim httpie lsof git tmux gedit

      # theme icon
      git clone --recurse-submodules https://github.com/daniruiz/flat-remix.git
      cd flat-remix

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      sudo mkdir -p /usr/share/icons && sudo cp -raf Flat-Remix* /usr/share/icons/
      sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix
      cd /tmp

      # gtk theme
      git clone --recurse-submodules https://github.com/daniruiz/flat-remix-gtk.git
      cd flat-remix-gtk

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      sudo mkdir -p /usr/share/themes && sudo cp -raf Flat-Remix-GTK* /usr/share/themes/
      cd /tmp

      # display
      sudo apt install -y --no-install-recommends nitrogen arandr lxappearance xbacklight x11-xserver-utils

      sudo apt install -y --no-install-recommends notification-daemon
#       echo "
# [D-BUS Service]
# Name=org.freedesktop.Notifications
# Exec=/usr/libexec/notification-daemon
# " | sudo tee /usr/share/dbus-1/services/org.freedesktop.Notifications.service

      # audio
      sudo apt install -y --no-install-recommends alsa-utils
      sudo apt install -y --no-install-recommends pulseaudio pulseaudio-utils pavucontrol

      amixer sset "Master" unmute
      amixer sset "Speaker" unmute
      amixer sset "Headphone" unmute
      amixer sset "Mic" unmute
      amixer sset "Mic Boost" unmute

      amixer sset "Master" 100%
      amixer sset "Speaker" 100%
      amixer sset "Headphone" 100%
      amixer sset "Mic" 100%
      amixer sset "Mic Boost" 100%

      # MANUAL: PulseAudio Applet. Some are already installed
      sudo apt install -y --no-install-recommends libglib2.0-dev libgtk-3-dev libnotify-dev
      sudo apt install -y --no-install-recommends libpulse-dev libx11-dev
      sudo apt install -y --no-install-recommends autoconf automake pkgconf

      sudo apt install -y --no-install-recommends libgtk-3-0 libnotify-bin libpulse0

      git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
      cd pa-applet

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      ./autogen.sh && ./configure && make && sudo make install
      cd /tmp

      sudo apt remove -y libglib2.0-dev libgtk-3-dev libnotify-dev
      sudo apt remove -y libpulse-dev libx11-dev

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      # network manager
      sudo apt install -y --no-install-recommends network-manager network-manager-gnome
      sudo systemctl enable NetworkManager

      # fonts - fc-list
      # git clone https://github.com/ryanoasis/nerd-fonts.git
      # ./install
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

      sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
      sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
      sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"

      # terminal
      sudo apt install -y --no-install-recommends neofetch

      # TODO
      # gtk theme change
      sudo apt install -y --no-install-recommends gtk2-engines gtk-murrine-engine gtk2 gtk3

      # mouse cursor theme
      sudo apt install -y --no-install-recommends breeze-cursor-theme
      sudo ln -s /usr/share/icons/breeze_cursors /usr/share/icons/Breeze

      # notification, system monitor, compositor, image on terminal
      sudo apt install -y --no-install-recommends dunst conky compton w3m
      sudo apt install -y --no-install-recommends ffmpegthumbnailer

      # for vifm
      # sudo apt install -y --no-install-recommends python3-pip
      # sudo apt install -y --no-install-recommends redhat-rpm-config

      # sudo apt install -y --no-install-recommends python3-devel libjpeg-turbo-devel zlib-devel libXext-devel
      # sudo pip3 install ueberzug
      # sudo dnf remove -y python3-devel libjpeg-turbo-devel zlib-devel libXext-devel

      # MANUAL: i3lock-color. Some are already installed
      sudo dnf remove -y i3lock
      sudo apt install -y --no-install-recommends cairo-devel libev-devel libjpeg-devel libxkbcommon-x11-devel
      sudo apt install -y --no-install-recommends pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel autoconf automake

      sudo apt install -y --no-install-recommends cairo libev libjpeg-turbo libxcb libxkbcommon
      sudo apt install -y --no-install-recommends libxkbcommon-x11 xcb-util-image pkgconf

      sudo dnf mark install cairo libev libjpeg-turbo libxcb libxkbcommon libxkbcommon-x11 xcb-util-image

      git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
      cd i3lock-color

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      autoreconf -fi && ./configure && make && sudo make install
      echo "auth include system-auth" | sudo tee /etc/pam.d/i3lock
      cd /tmp

      sudo dnf remove -y cairo-devel libev-devel libjpeg-devel libxkbcommon-x11-devel
      sudo dnf remove -y pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel

      # terminal-based file viewer
      sudo apt install -y --no-install-recommends ranger
      # sudo apt install -y --no-install-recommends vifm

      # requirements for ranger [scope.sh]
      sudo apt install -y --no-install-recommends file libcaca python3-pygments atool libarchive unrar lynx
      sudo apt install -y --no-install-recommends mupdf transmission-cli mediainfo odt2txt python3-chardet

      # i3wm customization, dmenu replacement, i3status replacement
      sudo apt install -y --no-install-recommends rofi

      # MANUAL: i3-gaps
      sudo dnf remove -y i3
      sudo apt install -y --no-install-recommends libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel
      sudo apt install -y --no-install-recommends xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel
      sudo apt install -y --no-install-recommends libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel
      sudo apt install -y --no-install-recommends pcre-devel pango-devel automake git gcc

      sudo apt install -y --no-install-recommends libev libxkbcommon-x11 perl pango startup-notification
      sudo apt install -y --no-install-recommends xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl
      sudo apt install -y --no-install-recommends libev xcb-util-cursor xcb-util-keysyms

      git clone --recurse-submodules https://github.com/Airblader/i3.git i3-gaps
      cd i3-gaps

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/
      ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
      make && sudo make install

      sudo dnf remove -y libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel
      sudo dnf remove -y xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel
      sudo dnf remove -y libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel
      sudo dnf remove -y libxkbcommon-x11-devel pcre-devel pango-devel
      cd /tmp

      # MANUAL: polybar
      sudo apt install -y --no-install-recommends cairo-devel xcb-proto xcb-util-devel xcb-util-cursor-devel xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel
      sudo apt install -y --no-install-recommends alsa-lib-devel libcurl-devel jsoncpp-devel libmpdclient-devel pulseaudio-libs-devel libnl3-devel cmake wireless-tools-devel
      sudo apt install -y --no-install-recommends gcc-c++ gcc python python2 git pkgconf

      sudo apt install -y --no-install-recommends cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm
      sudo apt install -y --no-install-recommends alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      sudo apt install -y --no-install-recommends mpd mpc ncmpcpp

      sudo dnf mark install cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm
      sudo dnf mark install alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools
      sudo dnf mark install mpd mpc ncmpcpp

      git clone --recurse-submodules https://github.com/jaagr/polybar.git
      cd polybar

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      rm -rf build/ && mkdir -p build && cd build/
      cmake .. && make -j$(nproc) && sudo make install

      sudo dnf remove -y cairo-devel xcb-proto xcb-util-devel xcb-util-cursor-devel xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel
      sudo dnf remove -y alsa-lib-devel libcurl-devel jsoncpp-devel libmpdclient-devel pulseaudio-libs-devel libnl3-devel wireless-tools-devel
      cd /tmp

      # popup calendar
      # sudo apt install -y --no-install-recommends xdotool yad

      sudo apt install -y --no-install-recommends scrot

      sudo apt install -y --no-install-recommends accountsservice
      user=$(whoami)

      echo "
[User]
Icon=/var/lib/AccountsService/icons/$user.png
XSession=i3
SystemAccount=false
" | sudo tee /var/lib/AccountsService/users/$user

      cd $mainCWD
      sudo cp $(pwd)/rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
      sudo chown root:root /var/lib/AccountsService/users/$user
      sudo chown root:root /var/lib/AccountsService/icons/$user.png

      sudo chmod 644 /var/lib/AccountsService/users/$user
      sudo chmod 644 /var/lib/AccountsService/icons/$user.png

      if [ ! -f /usr/share/X11/xorg.conf.d/40-libinput.conf ];then
        sudo touch /usr/share/X11/xorg.conf.d/40-libinput.conf;
      fi

      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
      echo '
# Match on all types of devices but joysticks
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "NaturalScrolling" "true"
EndSection

Section "InputClass"
  Identifier "libinput keyboard catchall"
  MatchIsKeyboard "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "Tapping" "true"
  Option "ScrollMethod" "twofinger"
  Option "NaturalScrolling" "true"
  Option "ClickMethod" "clickfinger"
  Option "TappingDrag" "true"
EndSection

Section "InputClass"
  Identifier "libinput touchscreen catchall"
  MatchIsTouchscreen "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput tablet catchall"
  MatchIsTablet "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection
      ' | sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/dnf" | sudo tee -a "/etc/sudoers"

      if [ ! -f $HOME/.riced ];then
        mkdir -p $HOME/.icons/default
        echo "
[Icon Theme]
Inherits=Breeze
        " | tee $HOME/.icons/default/index.theme
      fi

      sudo mkdir -p /usr/share/icons/default
      echo "
[Icon Theme]
Inherits=Breeze
      " | sudo tee /usr/share/icons/default/index.theme

      if [ ! -f $HOME/.riced ];then
        while true; do
          read -p "Do you want to configure git [Yn]?   " yn
          case $yn in
            [Nn]* ) break;;
            * )
              while true; do
                read -p "Enter email or [e]xit:   " email
                case $email in
                  [Ee] ) break;;
                  * )
                    while true; do
                      read -p "Enter name or [e]xit:   " name
                      case $name in
                        [Ee] ) break 2;;
                        * )
                          while true; do
                            read -p "Enter username or [e]xit:   " username
                            case $username in
                              [Ee] ) break 3;;
                              * ) echo "
[user]
  email = $email
  name = $name
  username = $username
[diff]
  tool = vimdiff
[difftool]
  prompt = false
[color]
  ui = auto
[color \"branch\"]
  current = yellow reverse
  local = yellow
  remote = green
[color \"diff\"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold
[color \"status\"]
  added = yellow
  changed = green
  untracked = cyan
" | tee $HOME/.gitconfig;

                                break 4;;
                            esac
                          done;;
                      esac
                    done;;
                esac
              done;;
          esac
        done

        # create folders for executables
        mkdir -p $HOME/.config/audio
        mkdir -p $HOME/.config/display
        mkdir -p $HOME/.config/conky
        mkdir -p $HOME/.config/keyboard
        mkdir -p $HOME/.config/i3
        mkdir -p $HOME/.config/kali
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/network
        mkdir -p $HOME/.config/polybar
        mkdir -p $HOME/.config/touchpad
        mkdir -p $HOME/.config/themes
        # mkdir -p $HOME/.config/vifm
        # mkdir -p $HOME/.config/vifm/scripts

        # create folders for configs
        mkdir -p  "$HOME/.config/Code"
        mkdir -p  "$HOME/.config/Code/User"
        mkdir -p  "$HOME/.config/Code - OSS"
        mkdir -p  "$HOME/.config/Code - OSS/User"
        mkdir -p  "$HOME/.config/gtk-3.0"

        # copy vscode user settings
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code/User/keybindings.json"
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

        # copy executables
        cp $(pwd)/scripts/volume-manager.sh                   $HOME/.config/audio/volume-manager.sh
        cp $(pwd)/scripts/brightness-manager.sh               $HOME/.config/display/brightness-manager.sh
        cp $(pwd)/scripts/lockscreen.sh                       $HOME/.config/display/lockscreen.sh
        cp $(pwd)/scripts/generate-conky-config.sh            $HOME/.config/conky/generate-conky-config.sh
        cp $(pwd)/scripts/generate-conky-helper.sh            $HOME/.config/conky/generate-conky-helper.sh
        cp $(pwd)/scripts/keyboard-disabler.sh                $HOME/.config/keyboard/keyboard-disabler.sh
        cp $(pwd)/scripts/polybar.sh                          $HOME/.config/i3/polybar.sh
        cp $(pwd)/scripts/polkit-launch.sh                    $HOME/.config/i3/polkit-launch.sh
        cp $(pwd)/scripts/startup.sh                          $HOME/.config/i3/startup.sh
        cp $(pwd)/scripts/kali-rofi.sh                        $HOME/.config/kali/rofi.sh
        cp $(pwd)/scripts/kali-launch.sh                      $HOME/.config/kali/launch.sh
        cp $(pwd)/scripts/spawn-mpd.sh                        $HOME/.config/mpd/spawn-mpd.sh
        cp $(pwd)/scripts/network-connect.sh                  $HOME/.config/network/network-connect.sh
        cp $(pwd)/scripts/update-mirrors.sh                   $HOME/.config/network/update-mirrors.sh
        cp $(pwd)/scripts/toggle-touchpad.sh                  $HOME/.config/touchpad/toggle-touchpad.sh
        cp $(pwd)/scripts/popup-calendar.sh                   $HOME/.config/polybar/popup-calendar.sh
        cp $(pwd)/scripts/update-checker.sh                   $HOME/.config/polybar/update-checker.sh
        cp $(pwd)/scripts/change-theme.sh                     $HOME/.config/themes/change-theme.sh
        cp $(pwd)/scripts/update-polybar-network-interface.sh $HOME/.config/themes/update-polybar-network-interface.sh
        # cp $(pwd)/scripts/vifm-run.sh                         $HOME/.config/vifm/scripts/vifm-run.sh
        # cp $(pwd)/scripts/vifm-viewer.sh                      $HOME/.config/vifm/scripts/vifm-viewer.sh

        # copy keyboard-disabler icons
        # cp $(pwd)/rice/images/keyboard/* $HOME/.config/keyboard

        # make executables
        sudo chmod +x $HOME/.config/audio/volume-manager.sh
        sudo chmod +x $HOME/.config/display/brightness-manager.sh
        sudo chmod +x $HOME/.config/display/lockscreen.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-config.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-helper.sh
        sudo chmod +x $HOME/.config/keyboard/keyboard-disabler.sh
        sudo chmod +x $HOME/.config/i3/polybar.sh
        sudo chmod +x $HOME/.config/i3/polkit-launch.sh
        sudo chmod +x $HOME/.config/i3/startup.sh
        sudo chmod +x $HOME/.config/kali/rofi.sh
        sudo chmod +x $HOME/.config/kali/launch.sh
        sudo chmod +x $HOME/.config/mpd/spawn-mpd.sh
        sudo chmod +x $HOME/.config/network/network-connect.sh
        sudo chmod +x $HOME/.config/network/update-mirrors.sh
        sudo chmod +x $HOME/.config/touchpad/toggle-touchpad.sh
        sudo chmod +x $HOME/.config/polybar/popup-calendar.sh
        sudo chmod +x $HOME/.config/polybar/update-checker.sh
        sudo chmod +x $HOME/.config/themes/change-theme.sh
        sudo chmod +x $HOME/.config/themes/update-polybar-network-interface.sh
        # sudo chmod +x $HOME/.config/vifm/scripts/vifm-run.sh
        # sudo chmod +x $HOME/.config/vifm/scripts/vifm-viewer.sh

        cp -rf $(pwd)/rice/bashrc      $HOME/.bashrc

        # vifm
        # cp -raf $(pwd)/rice/vifmrc  $HOME/.config/vifm/vifmrc

        # copy vim colors
        mkdir -p $HOME/.vim
        cp -raf $(pwd)/rice/vim/*  $HOME/.vim
        cp -raf $(pwd)/rice/vimrc  $HOME/.vimrc

        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

        # copy wallpapers
        mkdir -p $HOME/Pictures/wallpapers
        cp -rf $(pwd)/rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

        # copy ranger configs
        mkdir -p $HOME/.config/ranger
        cp -rf $(pwd)/rice/ranger/* $HOME/.config/ranger

        # copy i3 config
        mkdir -p $HOME/.config/i3
        cp -rf $(pwd)/rice/config-i3      $HOME/.config/i3/config
        cp -rf $(pwd)/rice/i3status.conf  $HOME/.config/i3/i3status.conf

        sed -i 's/# exec --no-startup-id pa-applet/exec --no-startup-id pa-applet/g' $HOME/.config/i3/config

        # copy ncmpcpp config
        mkdir -p $HOME/.ncmpcpp
        cp -rf $(pwd)/rice/config-ncmpcpp $HOME/.ncmpcpp/config

        # copy polybar config
        mkdir -p $HOME/.config/polybar
        cp -rf $(pwd)/rice/config-polybar $HOME/.config/polybar/config
        bash $(pwd)/scripts/update-polybar-network-interface.sh

        # copy i3status config
        sudo cp -rf $(pwd)/rice/i3status.conf /etc/i3status.conf

        # copy mpd config
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/mpd/playlists
        cp -rf $(pwd)/rice/mpd.conf $HOME/.config/mpd/mpd.conf

        # copy neofetch config
        mkdir -p $HOME/.config/neofetch
        cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/config.conf

        # copy compton config
        mkdir -p $HOME/.config/compton
        cp -rf $(pwd)/rice/compton.conf $HOME/.config/compton/config.conf

        # copy dunst config
        mkdir -p $HOME/.config/dunst
        cp -rf $(pwd)/rice/dunstrc $HOME/.config/dunst/dunstrc

        while true; do
          read -p "Do you want to activate keyboard disabler [yN]?   " yn
          case $yn in
            [Yy]* )
              while true; do
                xinput
                read -p "

Enter device ID:   " did
                case $did in
                  * )
                    echo "exec --no-startup-id ~/.config/keyboard/keyboard-disabler.sh $did" | tee -a $HOME/.config/i3/config
                    break 2;;
                esac
              done;;
            * ) break;;
          esac
        done

        touch $HOME/.riced
      fi

      cd $mainCWD

      # sed -i "s/# exec --no-startup-id dnfdragora-updater/exec --no-startup-id dnfdragora-updater/g" $HOME/.config/i3/config
      # sed -i "s/# for_window \[class=\"Dnfdragora-updater\"\]/for_window [class=\"Dnfdragora-updater\"]/g" $HOME/.config/i3/config

      os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))
      mkdir -p "$HOME/.config/neofetch"
      cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      echo "
[Icon Theme]
Inherits=Breeze
      " | sudo tee /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo mkdir -p /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/slick-greeter.conf /etc/lightdm/slick-greeter.conf

      bash $(pwd)/scripts/update-screen-detector.sh
      bash $(pwd)/scripts/update-themes.sh
      sudo dnf -y autoremove

      echo '

####################################
####################################
###                              ###
###    RICING COMPLETE...        ###
###                              ###
####################################
####################################

'

      break;;
  esac
done


