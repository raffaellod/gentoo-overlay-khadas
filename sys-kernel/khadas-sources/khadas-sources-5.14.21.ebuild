# Copyright 1999-2021 Gentoo Authors
# Copyright 2021 Raffaello D. Di Napoli
# Distributed under the terms of the GNU General Public License v2
# -*- coding: utf-8; mode: sh; tab-width: 3; indent-tabs-mode: t -*-

EAPI=8
ETYPE=sources
K_SECURITY_UNSUPPORTED=1
EXTRAVERSION=-khadas
inherit kernel-2
detect_version

DESCRIPTION='Full sources with Khadas patches'
HOMEPAGE='https://www.kernel.org'
SRC_URI="${KERNEL_URI}"

KEYWORDS='~arm64'

khadas_boards='edge vim1 vim2 vim3 vim3l'
REQUIRED_USE="${REQUIRED_USE} ?? ("
for board in ${khadas_boards}; do
	IUSE="${IUSE} khadas_boards_${board}"
	REQUIRED_USE="${REQUIRED_USE} khadas_boards_${board}"
done
unset board
REQUIRED_USE="${REQUIRED_USE} )"

use_board() {
	local board
	for board in ${khadas_boards}; do
		if use khadas_boards_${board}; then
			echo ${board}
			return
		fi
	done
	echo generic
}

src_unpack() {
	kernel-2_src_unpack
	mkdir "${WORKDIR}/khadas_patches"
	(
		cd "${WORKDIR}/khadas_patches"
		unpack "${FILESDIR}/khadas_patches-$(ver_cut 1-2).tar.xz"
	)
	(
		cd arch/arm64/configs
		local board=$(use_board)
		unpack "${FILESDIR}/khadas_${board}.config.xz"
		mv khadas_${board}.config ${board}_defconfig
	)
}

src_prepare() {
	eapply "${WORKDIR}/khadas_patches"

	kernel-2_src_prepare

	local board=$(use_board)
	ln -fs "${board}_defconfig" arch/arm64/configs/defconfig

	if [[ ${board} != generic ]]; then (
		# Discard/don’t compile device trees for boards other than ${board}.
		cd arch/arm64/boot/dts
		if ! use khadas_boards_edge; then
			sed -i -e '/-khadas-edge\(-[^.]\+\)\?.dtb$/d' rockchip/Makefile
		fi
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
	); fi
}
