# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/cssutils/cssutils-0.9.7.ebuild,v 1.4 2011/06/08 16:26:49 xarthisius Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_2} pypy{1_8,1_9,2_0} )

inherit distutils-r1

DESCRIPTION="Pure Python module to hyphenate text"
HOMEPAGE="http://pygal.org/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scipy"

RDEPEND="dev-python/lxml
         scipy? ( sci-libs/scipy )"
