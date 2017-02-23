#=========================================================================================
# SaltStack State File
#
# NAME: nrpe/mapr.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.06.15
#
# PURPOSE: On cluster nodes, this makes sure that the user nagios has the right uid/gid.
#
# CHANGE LOG:
#
# NOTES:
#

{% if salt['grains.get']('roles') == 'mapr' %}

mapr_cluster_nrpe_gid:
  group.present:
    - name: nagios
    - gid: 494
  require:
    - pkg: nrpe_install

mapr_cluster_nrpe_uid:
  user.present:
    - name: nagios
    - uid: 494
    - gid: 494
  require:
    - pkg: nrpe_install
    - group: mapr_cluster_nrpe_gid

mapr_cluster_usr_lib64_nagios_plugins:
  file.directory:
    - name: /usr/lib64/nagios/plugins
    - user: root
    - group: root
    - recurse:
      - user
      - group
  require:
    - file: nrpe_install

mapr_cluster_var_spool_nagios:
  file.directory:
    - name: /var/spool/nagios
    - user: nagios
    - group: nagios

{% endif %}
