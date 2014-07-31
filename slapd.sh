#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_ROOTPASS=${LDAP_ROOTPASS}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

if [ -z "$(ls -A /var/lib/ldap)" ]; then
  status "configuring slapd for first run"

  cat <<EOF | debconf-set-selections
slapd slapd/no_configuration boolean false
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/password1 password ${LDAP_ROOTPASS}
slapd slapd/password2 password ${LDAP_ROOTPASS}
slapd slapd/backend select HDB
slapd slapd/purge_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/move_old_database boolean true
EOF

  dpkg-reconfigure -f noninteractive slapd

else
  status "found already-configured slapd"
fi

status "starting slapd"
set -x
exec /usr/sbin/slapd -g openldap -u openldap -F /etc/ldap/slapd.d -d 0 "$@"
