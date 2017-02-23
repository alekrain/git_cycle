#=========================================================================================
# SaltStack State File
#
# NAME: iptables/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.05.25
#
# PURPOSE: Install the IP tables conf file and restart the IP Tables service.
#
# CHANGE LOG:
#   2015.06.13 - Added support for host specific or default iptables rules.
#
# NOTES:
#

{% from "iptables/map.jinja" import iptables_params with context %}
{% set hostname = salt.grains.get('id')|lower %}
{% set osfinger = salt.grains.get('osfinger') %}

# Make sure iptables-service is installed if the os is CentOS7.
{% if osfinger == 'CentOS Linux-7' %}
iptables_installed:
  pkg.installed:
    - names:
      - iptables-services

iptables_service_enabled:
  service.running:
    - name: iptables
    - enable: True
    - watch:
      - file: iptables_configuration
  require:
    - pkg: iptables_installed

{% elif osfinger == 'CentOS-6' %}
# Restart the IP Tables service. Remember, iptables isn't a process that stays alive.
# That means you can't use service.running to restart it.
iptables_service:
  cmd.run:
    - name: {{ iptables_params.service_command }} {{ iptables_params.servicename }} restart
    - cmd: /root
  watch:
    - file: iptables_configuration
{% endif %} {# if osfinger == #}

# Copy the iptables configuration to the server
iptables_configuration:
  file.managed:
    - name: {{ iptables_params.configuration }}
    - source:
      - salt://hosts/{{ hostname }}{{ iptables_params.configuration }}
      - salt://iptables/iptables
    - user: root
    - group: root
    - mode: 600
