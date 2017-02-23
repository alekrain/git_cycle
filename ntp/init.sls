#=========================================================================================
# SaltStack State File
#
# NAME: ntp/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install NTP and setup it's configuration file. If there is no config for the
#   host, then use a default config.
#
# CHANGE LOG:
#    2015.10.06 - Added jinja code to handle setup for an NTP server.
#
# NOTES:
#

{% from "ntp/map.jinja" import ntp_vars with context %}
{% from "ntp/map.jinja" import ntp_config %}
{% set hostname = salt['grains.get']('id') %}

# Install the ntp package if necessary
ntp_install:
  pkg.installed:
    - name: {{ ntp_vars.package }}

# Restart the ntp daemon if the config file changes or start it if it isn't running.
ntp_running:
  service.running:
    - name: {{ ntp_vars.service }}
    - enable: True
    - watch:
       - file: ntp_config_file
  require:
    - pkg: ntp_install

# Install the ntp config file.
ntp_config_file:
  file.managed:
    - name: {{ ntp_vars.conf }}
    - source:
      - salt://hosts/{{ hostname }}{{ ntp_vars.conf }}
      - salt://ntp/{{ ntp_config }}
    - makedirs: True
    - user: root
    - group: root
    - mode: 600
    - template: jinja
  require:
    - pkg: ntp_install
