# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy{1_8,1_9,2_0} )

inherit distutils-r1

DESCRIPTION="pygal is a dynamic SVG charting library"
HOMEPAGE="http://pygal.org/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/lxml"
