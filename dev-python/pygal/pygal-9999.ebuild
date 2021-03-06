# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy{1_8,1_9,2_0} )

inherit distutils-r1 git-2

DESCRIPTION="pygal is a dynamic SVG charting library"
HOMEPAGE="http://pygal.org/"
EGIT_REPO_URI="git://github.com/Kozea/${PN}.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scipy"

RDEPEND="dev-python/lxml
         scipy? ( sci-libs/scipy )"
DEPEND="${RDEPEND}"
