#=========================================================================================
# SaltStack State File
#
# NAME: psad/init.sls
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.05.18
#
# PURPOSE: Install PSAD
#
# CHANGE LOG:
#
# NOTES:
#   2015.07.09 - AT - Designed to work with CentOS7
#

{% set hostname = salt.grains.get('id') %}

# Install packages that PSAD depends on.
psad_install_packages:
  pkg.installed:
    - names:
      - psmisc
      - perl-ExtUtils-MakeMaker
      - perl-Date-Calc
      - perl-Unix-Syslog

# Copy the PSAD archive to the machine and extract it.
psad_copy_to_machine:
  archive.extracted:
    - name: /usr/local/src/psad-2.4.1
    - source:
      - salt://psad/psad-2.4.1.tar.gz
    - archive_format: tar
    - tar_options: v

# Copy the PSAD install answers file to the machine.
psad_copy_install_answers_to_machine:
  file.managed:
    - name: /usr/local/src/install.answers
    - source:
      - salt://psad/psad_install.answers
    - user: root
    - group: root
    - mode: 644

# Install PSAD
psad_install:
  cmd.run:
    - name: |
        perl install.pl -U -a /usr/local/src/install.answers
    - cwd: /usr/local/src/psad-2.4.1/psad-2.4.1
    - shell: /bin/bash
    - timeout: 300
    - unless: test -x /usr/sbin/psad
    - require:
      - file: psad_copy_to_machine
      - file: psad_copy_install_answers_to_machine
      - pkg: psad_install_packages

# Replace PSAD config file
psad_replace_conf:
  file.managed:
    - name: /etc/psad/psad.conf
    - source:
      - salt://hosts/{{ hostname }}/etc/psad/psad.conf
      - salt://psad/psad.conf
    - user: root
    - group: root
    - mode: 660
    - makedirs: True
    - template: jinja
    - defaults:
      hostname: {{ hostname }}
{% for nic, ip_address in salt.grains.get('ip_interfaces').iteritems() %}
  {% if 'eth0' in nic %}
    {% set interface = nic %}
      interface: 'eth0'
  {% endif %}
{% endfor %}
  require:
    - cmd: psad_install

# Install the PSAD auto_dl file.
psad_auto_dl_replace:
  file.managed:
    - name: /etc/psad/auto_dl
    - source:
      - salt://hosts/{{ hostname }}/etc/psad/auto_dl
      - salt://psad/auto_dl
    - user: root
    - group: root
    - mode: 660
    - makedirs: True
  require:
    - cmd: psad_install

# Iterate through pillar data and ensure all netblocks are in auto_dl
{% for bridge_interface, bridge_data in salt.pillar.get('virtual_hosts:bridges', {}).iteritems() %}
psad_add_bridge_cidr_to_auto_dl_{{ bridge_interface }}:
  file.append:
    - name: /etc/psad/auto_dl
    - text: {{ bridge_data.cidr }}  0;  # {{ bridge_data.provider }}
  require:
    - file: psad_auto_dl_replace
{% endfor %}

# Modify the startup script
psad_etc_rcd_initd:
  file.replace:
     - name: /etc/rc.d/init.d/psad
     - pattern: |
         \/usr\/sbin\/psad
     - repl: /usr/sbin/psad --no-signatures --no-snort-sids \n
     - count: 1
  require:
    - cmd: psad_install
