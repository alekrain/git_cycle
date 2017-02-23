#===============================================================================
# SaltStack State File
#
# NAME: dhcpd/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.10.06
#
# PURPOSE: Install a DHCP server and conf file. This state SHOULD fail if called
#    for a machine that doesn't have a conf file already on the salt server.
#
# CHANGE LOG:
#
# NOTES:
#   2015.07.09 - AT - Designed to work with CentOS7.
#

{% set hostname = salt.grains.get('id') %}

# Install DHCP Server
dhcpd_install_packages:
  pkg.installed:
    - names:
      - dhcp

# Copy down the config file from the salt server.
dhcpd_config:
  file.managed:
    - name: /etc/dhcp/dhcpd.conf
    - source: salt://hosts/{{ hostname }}/etc/dhcp/dhcpd.conf
    - user: root
    - group: root
    - mode: 644

# Restart dhcpd if the config file changes, or if the service isn't running.
dhcpd_service:
  service.running:
    - name: dhcpd
    - enabled: True
    - watch:
      - file: dhcpd_config
