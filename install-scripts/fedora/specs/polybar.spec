# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       polybar
Version:    3.4.3
Release:    1%{?dist}
Summary:     A fast and easy-to-use status bar

License:    MIT
URL:        https://polybar.github.io/
Source0:    https://github.com/polybar/%{name}/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildArch:      x86_64

BuildRequires:  alsa-lib-devel
BuildRequires:  cairo-devel
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  jsoncpp-devel
BuildRequires:  libcurl-devel
BuildRequires:  libmpdclient-devel
BuildRequires:  libnl3-devel
BuildRequires:  libxcb-devel
BuildRequires:  pulseaudio-libs-devel
BuildRequires:  python
BuildRequires:  python2
BuildRequires:  pkgconf
BuildRequires:  xcb-proto
BuildRequires:  xcb-util-cursor-devel
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-image-devel
BuildRequires:  xcb-util-wm-devel
BuildRequires:  xcb-util-xrm-devel
BuildRequires:  wireless-tools-devel

Requires:       alsa-lib
Requires:       cairo
Requires:       curl
Requires:       jsoncpp
Requires:       libmpdclient
Requires:       libnl3
Requires:       pulseaudio-libs
Requires:       wireless-tools
Requires:       xcb-util-cursor
Requires:       xcb-util-image
Requires:       xcb-util-wm
Requires:       xcb-util-xrm

%description
The main purpose of Polybar is to help users create awesome status bars. It has built-in functionality to display information about the most commonly used services.

%prep
rm -rf lib/i3ipcpp lib/xpp
%setup
rm -rf lib/i3ipcpp/* lib/xpp/*
git clone https://github.com/polybar/i3ipcpp lib/i3ipcpp
git clone https://github.com/polybar/xpp lib/xpp
cd lib/i3ipcpp && git checkout cb008b3 && cd ../../
cd lib/xpp && git checkout c1a0f59 && cd ../../



%build
rm -rf build/ && mkdir -p build && cd build && cmake ..
make 


%install
cd build
%make_install


%files
%license LICENSE
/usr/lib/debug/usr/local/bin/polybar-%{version}-1%{?dist}.x86_64.debug
/usr/lib/debug/usr/local/bin/polybar-msg-%{version}-1%{?dist}.x86_64.debug
/usr/local/bin/polybar
/usr/local/bin/polybar-msg
/usr/local/share/bash-completion/completions/polybar
/usr/local/share/doc/polybar/config
/usr/local/share/man/man1/polybar.1
/usr/local/share/zsh/site-functions/_polybar
/usr/local/share/zsh/site-functions/_polybar_msg




%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
