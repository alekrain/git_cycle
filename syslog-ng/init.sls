#=========================================================================================
# SaltStack State File 
#
# NAME: syslog-ng/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.10.09
#
# PURPOSE: Setup syslog-ng server
#
# CHANGE LOG:
#
# NOTES: 
#

{% set hostname = salt['grains.get']('id') %}

# Install syslog if it's not already
syslog_install:
  pkg.installed:
    - names:
      - syslog-ng

# Stop and disable rsyslog
syslog_disable_rsyslog:
  service.dead:
    - name: rsyslog
    - enable: False

# Copy in the syslog configuration file.
syslog_configuration_file:
  file.managed:
    - name: /etc/syslog-ng/syslog-ng.conf
    - source:
      - salt://hosts/{{ hostname }}/etc/syslog/syslog-ng.conf
      - salt://syslog-ng/syslog-ng.conf
    - user: root
    - group: root
    - mode: 644
  require:
    - pkg: syslog_install

# Restart the syslog service if the configuration file changes
syslog_service:
  service.running:
    - name: syslog-ng
    - enable: True
    - watch:
      - file: syslog_configuration_file
  require:
    - pkg: syslog_install
