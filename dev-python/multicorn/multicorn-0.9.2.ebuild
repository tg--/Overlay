# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

MY_PN="Multicorn"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A data access library"
HOMEPAGE="http://multicorn.org"
SRC_URI="http://api.pgxn.org/dist/multicorn/${PV}/multicorn-${PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="lxml docutils imap"

DEPEND=">=dev-db/postgresql-server-9.2:9.2
        dev-python/log-colorizer
        dev-python/sqlalchemy[postgres]
        lxml? ( dev-python/lxml )
        imap? ( dev-python/imapclient )
        docutils? ( dev-python/docutils )"
RDEPEND="${DEPEND}"

src_compile() {
    emake || die
    distutils_src_compile
}

src_install() {
    emake NO_PYTHON="1" DESTDIR="${D}" USE_PGXS=1 install || die
    distutils_src_install
}