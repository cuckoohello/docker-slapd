FROM debian:jessie
MAINTAINER Yafeng Shan <cuckoo@kokonur.me>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates ssl-cert slapd ldap-utils && \
  apt-get clean

RUN usermod -a -G ssl-cert openldap && rm -rf /var/lib/ldap/* /etc/ldap/slapd.d/*

# Add VOLUMEs to allow backup of config and databases
# * To store the data outside the container, mount /var/lib/ldap as a data volume
VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap"]

ADD slapd.sh /

ENV LDAP_ROOTPASS password
ENV LDAP_ORGANISATION LDAP ORGANISATION
ENV LDAP_DOMAIN example.com

ENTRYPOINT ["/slapd.sh"]

CMD ["-h", "ldap:/// ldaps:/// ldapi:///"]

EXPOSE 389 636
