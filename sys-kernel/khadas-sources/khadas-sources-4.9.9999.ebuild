# Copyright 1999-2021 Gentoo Authors
# Copyright 2021 Raffaello D. Di Napoli
# Distributed under the terms of the GNU General Public License v2
# -*- coding: utf-8; mode: sh; tab-width: 3; indent-tabs-mode: nil -*-

EAPI=8
ETYPE=sources
K_SECURITY_UNSUPPORTED=1
EXTRAVERSION=-khadas
inherit kernel-2
detect_version
detect_arch

inherit git-r3
EGIT_REPO_URI='https://github.com/khadas/linux.git -> khadas-linux.git'
EGIT_BRANCH="khadas-vims-$(ver_cut 1-2).y"
EGIT_CHECKOUT_DIR="${WORKDIR}/linux-${PV}-khadas"
EGIT_CLONE_TYPE=shallow

DESCRIPTION='Khadas kernel sources'
HOMEPAGE='https://github.com/khadas/linux'

KEYWORDS='arm64'
KEYWORDS="${KEYWORDS} amd64" # test hack

khadas_boards='vim1 vim2 vim3 vim3l'
REQUIRED_USE="${REQUIRED_USE} || ("
for board in ${khadas_boards}; do
	IUSE="${IUSE} khadas_boards_${board}"
	REQUIRED_USE="${REQUIRED_USE} khadas_boards_${board}"
done
unset board
REQUIRED_USE="${REQUIRED_USE} )"

src_prepare() {
	git-r3_src_prepare
	kernel-2_src_prepare
	ln -fs kvims_defconfig arch/arm64/configs/defconfig

	(
		# Discard/don’t compile device trees for boards other than ${board}.
		cd arch/arm64/boot/dts
		if ! use khadas_boards_vim1; then
			sed -i -e '/-khadas-vim\.dtb$/d; / overlays\/kvim$/d' amlogic/Makefile
		fi
		if ! use khadas_boards_vim2; then
			sed -i -e '/-khadas-vim2\.dtb$/d; / overlays\/kvim2$/d' amlogic/Makefile
		fi
		if ! use khadas_boards_vim3; then
			sed -i -e '/-khadas-vim3\.dtb$/d; / overlays\/kvim3$/d' amlogic/Makefile
		fi
		if ! use khadas_boards_vim3l; then
			sed -i -e '/-khadas-vim3l\.dtb$/d; / overlays\/kvim3l$/d' amlogic/Makefile
		fi
	)
}
