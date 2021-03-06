
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))
sudo apt update

check_packages() {
  sudo apt install --no-install-recommends $1
}

while true; do
  read -p "Check packages for script 10 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        acpid
        build-essential
        linux-headers-$(uname -r)
        numlockx
        pciutils
        usbutils
        xdg-user-dirs
        dummy-package-to-cancel-install
      "
      break;;
  esac
done

while true; do
  read -p "Check packages for script 20 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        x11-utils
        x11-xserver-utils
        xbacklight
        xfonts-75dpi
        xfonts-100dpi
        xfonts-utils
        xinit
        xserver-xorg-core
        xserver-xorg-input-kbd
        xserver-xorg-input-libinput
        xserver-xorg-input-mouse
        xserver-xorg-video-fbdev
        xserver-xorg-video-vesa

        accountsservice
        alsa-tools
        alsa-utils
        amd64-microcode
        arandr
        at
        atool
        autoconf
        automake
        breeze-cursor-theme
        broadcom-sta-dkms
        browser-plugin-freshplayer-pepperflash
        build-essential
        catdoc
        cmake
        compton
        conky
        curl
        dbus-x11
        dkms
        docx2txt
        dunst
        feh
        ffmpegthumbnailer
        file
        fonts-noto
        g++
        gcc
        gedit
        git
        gstreamer1.0-libav
        gstreamer1.0-plugins-bad
        gstreamer1.0-plugins-base
        gstreamer1.0-plugins-good
        gstreamer1.0-plugins-ugly
        gstreamer1.0-tools
        gstreamer1.0-vaapi
        gstreamer1.0-x
        gtk2-engines
        gtk2-engines-murrine
        httpie
        i3
        i3lock
        i3status
        libxcb-cursor0
        intel-microcode
        libarchive13
        libasound2
        libasound2-dev
        libcaca0
        libcairo2
        libcairo2-dev
        libcurl4-openssl-dev
        libd3dadapter9-mesa
        libegl-mesa0
        libev4
        libev-dev
        libgbm1
        libgl1-mesa-dri
        libglapi-mesa
        libglib2.0-dev
        libglu1-mesa
        libglw1-mesa
        libglx-mesa0
        libgtk2.0-0
        libgtk-3-0
        libgtk-3-dev
        libiw-dev
        libjsoncpp1
        libjsoncpp-dev
        libmpdclient2
        libmpdclient-dev
        libnl-3-200
        libnl-3-dev
        libnotify-bin
        libnotify-dev
        libosmesa6
        libpam0g-dev
        libpango-1.0-0
        libpango1.0-dev
        libpcre3-dev
        libpulse0
        libpulse-dev
        libstartup-notification0
        libstartup-notification0-dev
        libturbojpeg0-dev
        libva-glx2
        libvdpau1
        libvdpau-va-gl1
        libvulkan1
        libx11-dev
        libxcb1
        libxcb-composite0
        libxcb-composite0-dev
        libxcb-cursor0
        libxcb-cursor-dev
        libxcb-ewmh2
        libxcb-ewmh-dev
        libxcb-icccm4
        libxcb-icccm4-dev
        libxcb-image0
        libxcb-image0-dev
        libxcb-keysyms1
        libxcb-keysyms1-dev
        libxcb-randr0
        libxcb-randr0-dev
        libxcb-util0-dev
        libxcb-xinerama0
        libxcb-xinerama0-dev
        libxcb-xrm0
        libxcb-xrm-dev
        libxext-dev
        libxinerama-dev
        libxkbcommon0
        libxkbcommon-dev
        libxkbcommon-x11-0
        libxkbcommon-x11-dev
        libxrandr-dev
        libyajl2
        libyajl-dev
        lightdm
        lightdm-gtk-greeter
        lightdm-gtk-greeter-settings
        linux-headers-$(uname -r)
        linux-image-$(uname -r)
        libxcb-randr0
        lsof
        lxappearance
        lynx
        make
        man-db
        mediainfo
        mesa-opencl-icd
        mesa-utils
        mesa-utils-extra
        mesa-va-drivers
        mesa-vdpau-drivers
        mesa-vulkan-drivers
        mpc
        mpd
        mupdf
        nautilus
        ncmpcpp
        neofetch
        network-manager
        network-manager-gnome
        odt2txt
        openjdk-11-jdk
        pavucontrol
        perl
        pkgconf
        poppler-utils
        psmisc
        pulseaudio
        pulseaudio-utils
        python
        python3-chardet
        python3-dev
        python3-pip
        python3-pygments
        python3-setuptools
        python3-xcbgen
        ranger
        rofi
        rxvt-unicode
        scrot
        tar
        tmux
        transmission-cli
        transmission-common
        unrar
        unzip
        vifm
        vim
        vulkan-utils
        w3m
        wget
        wireless-tools
        x11-xserver-utils
        xbacklight
        xcb-proto
        xinput
        xserver-xorg-video-amdgpu
        xserver-xorg-video-ati
        xserver-xorg-video-intel
        xz-utils
        zip
        zlib1g-dev
        dummy-package-to-cancel-install
      "

      if [ "$os" != "debian" ]; then
        check_packages "libjpeg62 libjpeg62-dev libturbojpeg dummy-package-to-cancel-install"
      else
        check_packages "
          firmware-linux-nonfree
          libjpeg62-turbo
          libjpeg62-turbo-dev
          libturbojpeg0
          libgl1-nvidia-glx
          nvidia-detect
          nvidia-driver
          nvidia-xconfig
          xserver-xorg-video-nvidia
          dummy-package-to-cancel-install
         "
      fi

      break;;
  esac
done

while true; do
  read -p "Check packages for script 30 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        avahi-daemon
        bash-completion
        binutils
        blueman
        bluez
        bluez-cups
        bzip2
        cmake
        cups
        curl
        dkms
        eog
        evince
        exfat-fuse
        exfat-utils
        flatpak
        fuse
        g++
        gamin
        gcc
        gconf2-common
        gconf-service
        gcr
        gdebi
        geary
        gedit
        gimp
        git
        gnome-calculator
        gnome-calendar
        gnome-keyring
        gnome-keyring-pkcs11
        gparted
        gufw
        hfsplus
        hfsprogs
        hfsutils
        httpie
        libattr1
        libattr1-dev
        libbz2-dev
        libfuse-dev
        libgconf-2-4
        libgomp1
        libnss-mdns
        libpam-gnome-keyring
        libreoffice
        libxkbcommon0
        linux-headers-$(uname -r)
        lsof
        make
        mupdf
        ntfs-3g
        os-prober
        p7zip
        p11-kit
        p11-kit-modules
        papirus-icon-theme
        patch
        perl
        pinentry-gnome3
        policykit-1-gnome
        printer-driver-cups-pdf
        pulseaudio-module-bluetooth
        samba
        simplescreenrecorder
        tmux
        transmission-gtk
        ufw
        vim
        virtualbox
        virtualbox-guest-additions-iso
        virtualbox-qt
        vlc
        wget
        xarchiver
        zlib1g
        zlib1g-dev
        dummy-package-to-cancel-install
      "

      if [ "$os" != "debian" ]; then
        check_packages "firefox dummy-package-to-cancel-install"
      else
        check_packages "timeshift firefox-esr dummy-package-to-cancel-install"
      fi

      break;;
  esac
done

