# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/dulwich/dulwich-0.9.3.ebuild,v 1.1 2013/10/18 22:56:00 radhermit Exp $

EAPI=5
PYTHON_COMPAT=( python3_3 )

inherit distutils-r1 git-2

DESCRIPTION="Dulwich is a pure-Python implementation of the Git file formats and protocols."
HOMEPAGE="http://samba.org/~jelmer/dulwich/ http://pypi.python.org/pypi/dulwich"
EGIT_REPO_URI="git://github.com/eberle1080/dulwich-py3k.git"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc test"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/nose[${PYTHON_USEDEP}]
		virtual/python-unittest2[${PYTHON_USEDEP}]
	)"
RDEPEND=""

DISTUTILS_IN_SOURCE_BUILD=1

python_compile_all() {
	sed -i -e "s:'bin/dulwich', 'bin/dul-daemon', 'bin/dul-web'::" setup.py || die
	use doc && emake -C docs html
}

python_test() {
	ln -s "${BUILD_DIR}"/lib/dulwich/*.so dulwich/ || die
	nosetests || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/build/html/. )
	distutils-r1_python_install_all
}
