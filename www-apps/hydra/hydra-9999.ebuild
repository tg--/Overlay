# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit git-2

DESCRIPTION="The hydra website generator"
HOMEPAGE="http://kozea.org"
EGIT_REPO_URI="ssh://git@git.kozea.fr:27015/~/${PN}"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="lighttpd"

RDEPEND=""
DEPEND="${RDEPEND}
        dev-python/multicorn[lxml,docutils]
        dev-db/multicorn
        dev-python/imapclient
        dev-python/flask
        dev-python/html5lib
        dev-python/docutils-html5-writer
        dev-python/python-ghostscript
        =dev-python/wtforms-0.6*
        media-gfx/cairosvg
        dev-python/imaging
        dev-python/pytz
        =dev-python/icalendar-3.2*
        dev-python/soappy
        dev-python/pypet
        dev-python/pyinotify
        dev-python/flask-sqlalchemy
        =dev-python/sqlalchemy-0.7*
        dev-python/flask-weasyprint
        dev-python/pygal
        dev-python/pyyaml
        dev-python/flipflop
        dev-python/docutils-html5-writer
        dev-python/pyquery
        dev-python/sqlalchemy_fdw
        dev-python/pyinotify
        dev-ruby/sass"

HYDRA_DIR="/var/lib/${PN}"
THEMES_DIR=""

src_install() {
        insinto "${HYDRA_DIR}"

        rm -rf .git*
        echo "Generating themes..."
        ./${PN}/static/css/themes/generator.py --once --force
        rm -rf .sass-cache

        rm -rf .git*
        doins -r . || die
        if use lighttpd; then
	        fowners -R lighttpd:lighttpd "${HYDRA_DIR}" || die
            fperms 750 "${HYDRA_DIR}" || die
        fi
        fperms +x "${HYDRA_DIR}/runserver.py" || die
        fperms +x "${HYDRA_DIR}/statuscheck.py" || die
        fperms +x "${HYDRA_DIR}/hydra-groupinfo.fcgi" || die
        fperms +x "${HYDRA_DIR}/hydra-pharminfo.fcgi" || die
        fperms +x "${HYDRA_DIR}/hydra-medsite.fcgi" || die
}

pkg_postinst() {
        einfo
        elog "${PN} is installed in ${HYDRA_DIR}"
		elog "Don't forget to run sqitch:"
		elog "cd ${HYDRA_DIR} && sqitch deploy @v${PV} --set hydra_is_testing=false --set hydra_folder=${HYDRA_DIR}/hydra"
        einfo
}
