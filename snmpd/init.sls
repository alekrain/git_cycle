#=========================================================================================
# SaltStack State File 
#
# NAME: snmpd/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.08.24
#
# PURPOSE: Setup SNMPd
#
# CHANGE LOG:
#
# NOTES: 
#

{% set hostname = salt['grains.get']('id')|lower %}

snmpd_pkgs:
  pkg.installed:
    - names:
      - net-snmp

snmpd_conf:
  file.managed:
    - name: /etc/snmp/snmpd.conf
    - source:
      - salt://hosts/{{ hostname }}/etc/snmp/snmpd.conf
      - salt://snmpd/snmpd.conf
    - user: root
    - group: root
    - mode: 640
  require:
    - pkg: snmpd_pkgs

snmpd_service:
  service.running:
    - name: snmpd
    - enable: True
  watch:
    - file: snmpd_conf