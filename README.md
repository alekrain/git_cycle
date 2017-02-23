# GitCycle
A process for config management on snowflake servers.

GitCycle is a process that I created to help in small-ish environments where Linux servers are often unique little snowflakes and the admins are accustomed to making changes on the fly rather than through config management. By using the GitCycle, I only had to convince the admins to git add and git commit the config files they were changing on those systems.

I developed this methodology using SaltStack as my config management system, but there's no reason why it can't be used in other systems. However, everything here is based on using SaltStack.

I've also included some of my original Salt states that I used in conjunction with GitCycle. You should have the idea of how this works after looking at the first.

**Overview Example:**
1. Admin makes a change the /etc/nagios/nrpe.cfg
2. Admin git adds and git commits /etc/nagios/nrpe.cfg
3. From my Salt Master the git_cycle.sh script is kicked off via crontab.
4. It connects to this server and pulls the changes from the git repo
5. The next time I run my config management system, it utilizes the changes that were found and pulled back, thus avoiding overwriting the changes that the admin made.

**How it works:**
1. On the Salt Master we need to do some setup work:
  * Create a git user and group.
  * Generate a SSH public/private key pair for the git user and put the public key into the SaltStack pillar data for git_cycle.
  * Copy the git_cycle.sh script into the git user's home directory.
  * Create an entry in the git user's crontab to execute the git_cycle.sh script. Bonus points for redirecting the output to a log file.
  * Create a folder to store the files from your hosts in. For me, I put those files in alongside the state files that will be using them. So, /srv/salt/hosts.
  * For each Minion I want to retrieve files for, just create a sub directory:<br>
  /srv/salt/hosts/<br>
  └── Minion1<br>
  ├── Minion2
2. Running the git_cycle/init.sls SaltStack state file on a Minion does several things:
  * It creates a "git" user and group.
  * Adds a public key the the git user's authorized_keys file.
  * Adds specified users to the git group
  * Copies a .gitconfig file to each user's home directory.
  * It creates a git repository in the root of the Minion's filesystem. Putting it there allows files from anywhere in the filesystem to be added.
3. Go through and git add and commit some files on your minion.
4. Back on the Salt Master as the Git user:
  * Execute the bash script git_cycle.sh. Accept when prompted about the remote hosts keys.
  * You should now see the Minion files populating in the /srv/salt/hosts/ directory.
5. Keep in mind that you have these files now when crafting your states. In the below example, salt first tries to use the host specific nrpe.cfg file that we git pull from the server. Failing that it will fall back to the default file which I keep stored with the state file.

Drop in the nrpe.cfg file specific for this host. Or if its a new host, just use the default.
```
{% set hostname = salt['grains.get']('id') %}
nrpe_config_file:
  file.managed:
    - name: /etc/nagios/nrpe.cfg
    - source:
      - salt://hosts/{{ hostname }}/etc/nagios/nrpe.cfg
      - salt://nrpe/nrpe.cfg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
```
