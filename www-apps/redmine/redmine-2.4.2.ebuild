# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/redmine/redmine-1.4.3.ebuild,v 1.1 2012/06/07 16:14:06 matsuu Exp $

EAPI="3"
USE_RUBY="ruby19 ruby20"
inherit eutils depend.apache ruby-ng

DESCRIPTION="Redmine is a flexible project management web application written using Ruby on Rails framework"
HOMEPAGE="http://www.redmine.org/"
SRC_URI="http://www.redmine.org/releases/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE="fastcgi imagemagick ldap lighttpd openid passenger"

RDEPEND=""

ruby_add_rdepend "
	virtual/rubygems
	>=dev-ruby/coderay-1.0.6
	dev-ruby/i18n:0.6
	>=dev-ruby/rails-3.2.13:3.2
	<dev-ruby/builder-3.1:3
	imagemagick? ( >=dev-ruby/rmagick-2 )
	fastcgi? ( dev-ruby/fcgi )
	ldap? ( dev-ruby/ruby-net-ldap )
	openid? ( >=dev-ruby/ruby-openid-2.1.4 )
	passenger? ( www-apache/passenger )"

REDMINE_DIR="/var/lib/${PN}"

pkg_setup() {
	enewgroup redmine
	# home directory is required for SCM.
	enewuser redmine -1 -1 "${REDMINE_DIR}" redmine
}

all_ruby_prepare() {
	rm -r log files/delete.me || die

	# bug #406605
	rm .gitignore .hgignore || die

	rm Gemfile config/preinitializer.rb || die
	#epatch "${FILESDIR}/${PN}-1.4.1-bundler.patch" || die

	echo "CONFIG_PROTECT=\"${EPREFIX}${REDMINE_DIR}/config\"" > "${T}/50${PN}"
	echo "CONFIG_PROTECT_MASK=\"${EPREFIX}${REDMINE_DIR}/config/locales ${EPREFIX}${REDMINE_DIR}/config/settings.yml\"" >> "${T}/50${PN}"
}

all_ruby_install() {
	dodoc doc/{CHANGELOG,INSTALL,README_FOR_APP,RUNNING_TESTS,UPGRADING} || die
	rm -fr doc || die
	dodoc README.rdoc || die
	rm README.rdoc || die
	if use !openid; then
		rm -fr lib/plugins/open_id_authentication || die
	fi

	keepdir /var/log/${PN} || die
	dosym /var/log/${PN}/ "${REDMINE_DIR}/log" || die

	insinto "${REDMINE_DIR}"
	doins -r . || die
	keepdir "${REDMINE_DIR}/files" || die
	keepdir "${REDMINE_DIR}/public/plugin_assets" || die

	if use lighttpd; then
		USER="lighttpd"
	else
		USER="redmine"
	fi

	fowners -R ${USER}:${USER} \
		"${REDMINE_DIR}/config" \
		"${REDMINE_DIR}/files" \
		"${REDMINE_DIR}/public/plugin_assets" \
		"${REDMINE_DIR}/tmp" \
		/var/log/${PN} || die
	# for SCM
	fowners ${USER}:${USER} "${REDMINE_DIR}" || die

	# bug #406605
	fperms -R go-rwx \
		"${REDMINE_DIR}/config" \
		"${REDMINE_DIR}/files" \
		"${REDMINE_DIR}/tmp" \
		/var/log/${PN} || die

	if use passenger ; then
		has_apache
		insinto "${APACHE_VHOSTS_CONFDIR}"
		doins "${FILESDIR}/10_redmine_vhost.conf" || die
	else
		newconfd "${FILESDIR}/${PN}.confd" ${PN} || die
		newinitd "${FILESDIR}/${PN}.initd" ${PN} || die
		keepdir /var/run/${PN} || die
		fowners -R redmine:redmine /var/run/${PN} || die
		dosym /var/run/${PN}/ "${REDMINE_DIR}/tmp/pids" || die
	fi
	doenvd "${T}/50${PN}" || die
}

pkg_postinst() {
	einfo
	if [ -e "${EPREFIX}${REDMINE_DIR}/config/initializers/session_store.rb" ] ; then
		elog "Execute the following command to upgrade environment:"
		elog
		elog "# emerge --config \"=${CATEGORY}/${PF}\""
		elog
		elog "For upgrade instructions take a look at:"
		elog "http://www.redmine.org/wiki/redmine/RedmineUpgrade"
	else
		elog "Execute the following command to initlize environment:"
		elog
		elog "# cd ${EPREFIX}${REDMINE_DIR}"
		elog "# cp config/database.yml.example config/database.yml"
		elog "# \${EDITOR} config/database.yml"
		elog "# chown redmine:redmine config/database.yml"
		elog "# emerge --config \"=${CATEGORY}/${PF}\""
		elog
		elog "Installation notes are at official site"
		elog "http://www.redmine.org/wiki/redmine/RedmineInstall"
	fi
	einfo
}

pkg_config() {
	if [ ! -e "${EPREFIX}${REDMINE_DIR}/config/database.yml" ] ; then
		eerror "Copy ${EPREFIX}${REDMINE_DIR}/config/database.yml.example to ${EPREFIX}${REDMINE_DIR}/config/database.yml and edit this file in order to configure your database settings for \"production\" environment."
		die
	fi

	local RAILS_ENV=${RAILS_ENV:-production}
	local RUBY=${RUBY:-ruby19}

	cd "${EPREFIX}${REDMINE_DIR}"
	if [ -e "${EPREFIX}${REDMINE_DIR}/config/initializers/session_store.rb" ] ; then
		einfo
		einfo "Upgrade database."
		einfo

		einfo "Migrate database."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate || die
		einfo "Upgrade the plugin migrations."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate:upgrade_plugin_migrations # || die
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate_plugins || die
		einfo "Clear the cache and the existing sessions."
		${RUBY} -S rake tmp:cache:clear || die
		${RUBY} -S rake tmp:sessions:clear || die
	else
		einfo
		einfo "Initialize database."
		einfo

		einfo "Generate a session store secret."
		${RUBY} -S rake generate_session_store || die
		einfo "Create the database structure."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate || die
		einfo "Insert default configuration data in database."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake redmine:load_default_data || die
		einfo
		einfo "If you use sqlite3. please do not forget to change the ownership of the sqlite files."
		einfo
		einfo "# cd \"${EPREFIX}${REDMINE_DIR}\""
		einfo "# chown redmine:redmine db/ db/*.sqlite3"
		einfo
	fi
}
