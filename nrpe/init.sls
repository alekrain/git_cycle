#=========================================================================================
# SaltStack State File
#
# NAME: nrpe/init.sls
# VERSION: 0.2
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install NRPE and setup it's configuration file. If there is no config specified
#   for the host, then use a default config.
#
# CHANGE LOG:
#   2015.06.24 - Added in a declaration to copy in all the plugins that are needed for
#       this host. Also added
#
# NOTES:
#

# Check to make sure this is not the nagios server
{% set hostname = salt['grains.get']('id') %}

# Get variables from map.jinja
{% from "nrpe/map.jinja" import nrpe_vars with context %}

# If this is a MapR node, then run the mapr.sls first
{% if salt['grains.get']('roles') == 'mapr' %}
include:
  - nrpe.mapr
{% endif %}

# Make sure the NRPE package is installed.
nrpe_install:
  pkg.installed:
    - name: {{ nrpe_vars.package }}

# Make sure NRPE is running.
nrpe_running:
  service.running:
    - name: {{ nrpe_vars.service }}
    - enable: True
    - watch:
       - file: nrpe_config_file
  require:
    - pkg: nrpe_install

# Drop in the nrpe.cfg file specific for this host. Or if its a new host, just the default
nrpe_config_file:
  file.managed:
    - name: {{ nrpe_vars.conf }}
    - source:
      - salt://hosts/{{ hostname }}{{ nrpe_vars.conf }}
      - salt://nrpe/nrpe.cfg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

# Drop in the Nagios plugins that are required for this host. If its a new host, then
# just the default plugins will be put in.
nrpe_plugins:
  file.recurse:
    - name: {{ nrpe_vars.plugins_dir }}
    - source:
      - salt://hosts/{{ hostname }}{{ nrpe_vars.plugins_dir }}
      - salt://nrpe/plugins
    - user: root
    - group: root
    - dir_mode: 775
    - file_mode: 755
    - clean: False

nrpe_plugins_selinux_context:
  cmd.run:
    - name: /sbin/restorecon -R -v /usr/lib64/nagios/plugins
    - user: root
    - group: root
  require:
    - file: nrpe_plugins

# Copy over the SELinux Policy Modules for check_uptime.sh and check_version.sh to work.
nrpe_selinux_check_uptime_policy_file:
  file.managed:
    - name: /root/check_uptime.pp
    - source: salt://nrpe/check_uptime.pp
    - user: root
    - group: root
    - mode: 660
  require:
    - file: nrpe_plugins

# Copy over the SELinux Policy Modules for check_version.sh and check_version.sh to work.
nrpe_selinux_check_version_policy_file:
  file.managed:
    - name: /root/check_version.pp
    - source: salt://nrpe/check_version.pp
    - user: root
    - group: root
    - mode: 660
  require:
    - file: nrpe_plugins

# Write the policies into SELinux
nrpe_selinux_check_uptime_policy:
  cmd.wait:
    - name: /usr/sbin/semodule -i /root/check_uptime.pp
    - timeout: 60
    - watch:
      - file: nrpe_selinux_check_uptime_policy_file

nrpe_selinux_check_version_policy:
  cmd.wait:
    - name: /usr/sbin/semodule -i /root/check_version.pp
    - timeout: 60
    - watch:
      - file: nrpe_selinux_check_version_policy_file
