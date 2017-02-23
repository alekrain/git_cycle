#=========================================================================================
# SaltStack State File
#
# NAME: git_cycle/init.sls
# VERSION: 1.0
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE: 2015.07.07
#
# PURPOSE: Prepares a Minion for the Git Cycle.
#    1. Create a git user on the Minion
#    2. Add the Salt Pub Key into the Minion git user's authorized_key file.
#    3. Creates /.git
#    4. Allow the git user access to /.git
#
# CHANGE LOG:
#
# Notes:
#  Because the git.present function does not work in such a way as to allow installing
#  a git repo into the / directory, I ended up creating an empty repo on my own box,
#  zipping the contained folders, and then creating two declarations to handle getting
#  those folders into the correct place. The first creates /.git and then unzips the
#  contents of the git.zip file into it. The second makes sure the permissions are
#  recursively correct for /.git
#

{% set hostname = salt.grains.get('id')|lower %}
{% from "git_cycle/map.jinja" import admin_group with context %}
{% for git_user, git_args in salt.pillar.get('git_cycle', {}).iteritems() %}

{{ git_user }}:
  # Create and setup the user account
  group.present:
    - gid: {{ git_args.gid }}
  user.present:
    - fullname: {{ git_user }}
    - shell: {{ git_args.shell }}
    - home: {{ git_args.home }}
    - uid: {{ git_args.uid }}
    - gid: {{ git_args.gid }}
    - password: {{ git_args.password }}

# Create the user's home directory
{{ git_args.home }}:
  file.directory:
    - user: {{ git_user }}
    - group: {{ git_user }}
    - mode: 700
  require:
    - user: {{ git_user }}

# Create the user's .ssh directory
{{ git_args.home }}/.ssh:
  file.directory:
    - user: {{ git_user }}
    - group: {{ git_user }}
    - mode: 700
  require:
    - file: {{ git_args.home }}

# Add the git ssh pub key
git_cycle_add_key_to_{{ git_user }}:
  ssh_auth.present:
    - user: {{ git_user }}
    - enc: {{ git_args.ssh_key_type }}
    - name: {{ git_args.ssh_key_pub }}
    - comment: {{ git_args.ssh_key_comment }}
  require:
    - file: {{ git_args.home }}/.ssh

# The git.zip file contains an empty repo. We simply unzip it into /.git
git_cycle_git_dir:
  archive.extracted:
    - name: /.git
    - source: salt://git_cycle/git.zip
    - source_hash: sha1=3ada2f0979c239f723582aaf6bdabff784ed81c1
    - archive_format: zip
    - if_missing: /.git/HEAD

# Create a directory to put a git repo in and give the git user full control of it.
git_cycle_change_perms:
  file.directory:
    - name: /.git
    - user: {{ git_user }}
    - group: {{ git_user }}
    - dir_mode: 2770
    - file_mode: 660
    - recurse:
      - user
      - group
      - mode
  require:
    - user: {{ git_user }}
    - archive: git_cycle_git_dir

{% endfor %} {# for git_user, git_args in salt.pillar.get('git_cycle') #}

# Add a list of users specified in pillar to the git group
{% for group, users in salt.pillar.get('git_groups', {}).iteritems() %}

{% if users is iterable %}
{% for user in users %}
add_{{ user }}_to_group_{{ group }}:
  group.present:
    - name: {{ group }}
    - addusers:
      - {{ user }}
{% endfor %} {# for group in args.groups #}
{% endif %} {# if arg.groups is iterable #}

{% endfor %}

# Add gitconfig to root
git_cycle_add_gitconfig_to_root:
  file.managed:
    - name: /root/.gitconfig
    - source: salt://users/gitconfig
    - template: jinja
    - defaults:
      user: root
    - user: root
    - group: root
    - mode: 660
