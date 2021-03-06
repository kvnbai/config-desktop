
# x11-themes/papirus-icon-theme
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils
DESCRIPTION="Papirus is a free and open source SVG icon theme for Linux"
HOMEPAGE="https://github.com/PapirusDevelopmentTeam/${PN}"
SRC_URI="https://github.com/PapirusDevelopmentTeam/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND="x11-libs/gtk+:3"
RDEPEND="${DEPEND}"
BDEPEND=""

DESTDIR="/usr/share/icons"
THEMES=("Papirus" "ePapirus" "Papirus-Dark" "Papirus-Light")

src_compile() {
  echo "Nothing to compile."
}

src_install() {
  for theme in "${THEMES[@]}"; do
    test -d "${S}/$theme" || continue
    echo " ==> Installing '$theme' ..."
    sudo mkdir -p "${D}${DESTDIR}/$theme"
    sudo cp -raf "${S}/$theme/." "${D}${DESTDIR}/$theme/"
    sudo cp -raf \
      "${S}/AUTHORS" \
      "${S}/LICENSE" \
      "${D}${DESTDIR}/$theme" || true
    echo " ==> '$theme' installed..."
  done
}

pkg_postinst() {
  xdg_icon_cache_update
}

pkg_postrm() {
  xdg_icon_cache_update
}
