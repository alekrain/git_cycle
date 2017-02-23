#=========================================================================================
# SaltStack State File
#
# NAME: sudoers/init.sls
# VERSION: 1.0
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE: 2015.06.15
#
# PURPOSE:
#   Replace the default sudoers file.
#
# CHANGE LOG:
#
# NOTES:

{% set hostname = salt['grains.get']('id') %}

sudoers_installed:
  pkg.installed:
    - name: sudo

sudoers_file:
  file.managed:
    - name: /etc/sudoers
    - source:
      - salt://hosts/{{ hostname }}/etc/sudoers
      - salt://sudoers/sudoers
    - user: root
    - group: root
    - mode: 440
