# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/tox/tox-1.3.ebuild,v 1.2 2012/02/15 11:32:00 djc Exp $

EAPI="4"
PYTHON_DEPEND="2:2.6 3:3.1"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="cffi-based cairo bindings for Python"
HOMEPAGE="http://pypi.python.org/pypi/${PN}/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="raster"

DEPEND=""
RDEPEND="${DEPEND}
         >=dev-python/cffi-0.6
         x11-libs/cairo
         raster? ( x11-libs/gdk-pixbuf )"
