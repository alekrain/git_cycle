#=========================================================================================
# Bash Script
#
# NAME: git_pull_for_salt.sh
# VERSION: 0.1
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.07.14
#
# PURPOSE: Performs a git pull against all of the minions.
#
# CHANGE LOG:
#   2015.11.24  - Added lockfile code.
#               - Changed values of hosts_dir and git_ssh_key into variables.
#               - Added if/else logic to check for .git and do git clone
#
# NOTES: This script was made to be used on the salt master as a way of
#   retrieving changed files from minions.
#   It requires:
#     1. git_cycle/init.sls has been exected on the minion.
#     2. A git user has been setup on the master.
#     3. A directory structure on the master that looks like:
#       /srv/salt/hosts/
#       ├── minion1
#       ├── minion2
#     4. Git clone needs to have been run from inside each of the minion
#        directories against the corresponding minion.
#   Though this script needs to be run manually the first time around whenever
#     a new minion and host folder is added, I drop it in the git user's
#     crontab and redirect the output to a log file.
#

# Set Variables
git_ssh_key=/home/git/.ssh/git_cycle_ssh_key
hosts_dir=/srv/salt/hosts;

# Check for a running ssh-agent, if not create one and load the key
if [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent -s`
        ssh-add ${git_ssh_key};
fi

# Move into /srv/salt/hosts.
# Jump into each host dir and run git pull or git clone if there's no .git dir.
echo `date`
cd ${hosts_dir};
ls | while read host;
do
        cd ${host};
        if [ -d ".git" ]; then
          echo "Pulling for:" ${host}
          git pull origin master;
        else
          echo "Cloning ${host}"
          git clone ${host}:/.git .
        fi
        echo ""
        cd ${hosts_dir};
done;
echo ''

# Remove the SSH key from memory and kill the SSH agent.
ssh-add -D
ssh-agent -k
