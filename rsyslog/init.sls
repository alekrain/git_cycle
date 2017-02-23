#=========================================================================================
# SaltStack State File
#
# NAME: rsyslog/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.06.26
#
# PURPOSE: Setup rsyslog clients to talk to a syslog server
#
# CHANGE LOG:
#    2015.10.09
#     - Added map.jinja to support using different configuration files based on
#       roles.
#     - Also added some jinja logic to skip all declarations in this state if
#       the syslog role is found in grains.
#
# NOTES:
#

{% set hostname = salt['grains.get']('id') %}
{% from "rsyslog/map.jinja" import rsyslog_config %}

{% if 'syslog' not in salt.grains.get('roles') %}

# Install rsyslog if it's not already
rsyslog_install:
  pkg.installed:
    - names:
      - rsyslog

# Copy in the rsyslog configuration file.
rsyslog_configuration_file:
  file.managed:
    - name: /etc/rsyslog.conf
    - source:
      - salt://hosts/{{ hostname }}/etc/rsyslog.conf
      - salt://rsyslog/{{ rsyslog_config }}
    - user: root
    - group: root
    - mode: 644
  require:
    - pkg: rsyslog_install

# Restart the rsyslog service if the configuration file changes
rsyslog_service:
  service.running:
    - name: rsyslog
    - enable: True
    - watch:
      - file: rsyslog_configuration_file
  require:
    - file: rsyslog_configuration_file

{% endif %} {# if 'syslog' not in salt.grains.get('roles') #}
