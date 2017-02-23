#=========================================================================================
# SaltStack Pillar File
#
# NAME: git_cycle/init.sls
# VERSION: 1.0
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.07.07
#
# PURPOSE: This pillar data is made to work with the git_cycle.sls state file.
#
# CHANGE LOG:
#
# NOTES:

git_cycle:
  git:
    home: /home/git
    uid: 000
    gid: 000
    shell: /bin/sh
    password: $6$somesalt$somepassword
    ssh_key_type: ssh-rsa
    ssh_key_pub: AAAASomeSshPubKey
    ssh_key_comment: git_cycle_ssh_key

git_groups:
  git:
    - myUserName
    - anotherAdminUserName
