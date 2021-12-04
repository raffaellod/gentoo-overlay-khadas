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
EGIT_BRANCH="khadas-edge-$(ver_cut 1-2).y"
EGIT_CHECKOUT_DIR="${WORKDIR}/linux-${PV}-khadas"
EGIT_CLONE_TYPE=shallow

DESCRIPTION='Khadas kernel sources'
HOMEPAGE='https://github.com/khadas/linux'

KEYWORDS='arm64'
KEYWORDS="${KEYWORDS} amd64" # test hack

khadas_boards='edge'
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
	ln -fs kedge_defconfig arch/arm64/configs/defconfig
}
