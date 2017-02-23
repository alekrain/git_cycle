#=========================================================================================
# SaltStack State File 
#
# NAME: ossec_agent/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.06.24
#
# PURPOSE: 
#   1. Install Atomic's repo for OSSEC.
#   2. Install the OSSEC HIDS Client package.
#   3. Install the ossec.conf file specific to that host, or alternatively, a default.
#
# CHANGE LOG:
#
# NOTES: 
#

{% set hostname = salt['grains.get']('id') %}

# Setup the repository
/etc/yum.repos.d/atomic.repo:
  file.managed:
    - name: []
    - source: salt://ossec/atomic.repo
    - user: root
    - group: root
    - mode: 644

# Install the OSSEC HIDS Client Package
install_ossec_hids_client:
  pkg.installed:
    - name: ossec-hids-client
  require:
    - file: /etc/yum.repos.d/atomic

# Replace their default config file with our host specific one, or lacking that, one
# that has our defaults.
/var/ossec/etc/ossec-agent.conf:
  file.manage:
    - name: []
    - source:
      - salt://hosts/{{ hostname }}/var/ossec/etc/ossec-agent.conf
      - salt://ossec-agent/ossec-agent.conf
    - user: root
    - group: root
    - mode: 600
  require:
    - pkg: install_ossec_hids_client
