# Setting up a tutorial host for using the Openstack API on Jetstream

### Add some things to the skel

Add this to /etc/skel -- this stops the forced updates. Not a best practice but in the name of expediency for a tutorial, it's necessary.

```
vi cloud.cfg

#cloud-config
packages: []

package_update: false
package_upgrade: false
package_reboot_if_required: false

final_message: "Boot completed in $UPTIME seconds"
```

<em>Note: You'll likely want to make sure the formatting is correct after putting creating the config file. Cut and paste from Github doesn't preserve the line breaks correctly in my experience.</em>

You'll want to add a few things to /etc/bash.bashrc or in /etc/skel/.bashrc -- set the openstack client to fit the window, make the PS1 prompt be a bit friendlier (optional), and add /usr/local/bin to the path since Pip3 puts the openstack client there:


```
# Added for Openstack tutorial
export CLIFF_FIT_WIDTH=1
PS1="[Tutorial] \u \w-->"
export PATH=/usr/local/bin:$PATH
```

### Before getting started

Everything in here assumes you have a file named account.list with four delimited columns. I generally have been using a four column file, basically just copied and pasted from Excel into a vi'd file on the tutorial host. This walkthrough assumes your input file has fields 

<em>XSEDE_Username XSEDE_Password TACC_Username TACC_Password</em>

If not, you'll have to adjust accordingly.

*Make sure the list isn't dos format (vi will say [dos] at the bottom -- not sure about other editors) - you can easily fix this in vi by opening the file, doing :set ff=unix, and then saving the file.*


### Create the accounts:

`cat account.list| awk '{system("adduser " $1)}'`  

---

#### Atmopshere specific note 

<b>Disregard if using API side</b>

If you're using an Atmo instance, you'll either need to add these accounts to the users group (which might inadvertantly give them sudo access) or create a new group to add them to -- which you'll then need to add to the sshd_config at the bottom.

`groupadd train`

`awk '{system("usermod -G train " $1)}' account.list`

Then edit the sshd_config so it's something like this:

```[js-156-117] root ~-->tail /etc/ssh/sshd_config
#AllowTcpForwarding no
#PermitTTY no 
#ForceCommand cvs server
PermitRootLogin without-password

UseDNS no
Port 22
AllowGroups users root train
```

---

### Set the account passwords

If you're using training accounts, you won't have ssh keys, so you'll need to set passwords. 

To set passwords via cleartext:

`awk '{ system("echo " $1":"$2" |chpasswd") }' account.list`

Assuming a file with username (usually trainXX in col 1 and XSEDE password in col 2. I use the trainXX usernames and usually just use the password XSEDE Help gives me for the login password. It's reasonably secure for a short period of time. 

-----------------

### Generate openrc for the API class host 

Make sure the allocation/PROJECT_NAME is correct as that can possibly change. Also, make sure you set the ENDPOINT if you don't want to use the IU cloud.

This STILL assumes your input file has fields 

*XSEDE_Username XSEDE_Password TACC_Username TACC_Password 

--> change the awk vars as needed if you format varies. 

`for user in $(awk '{print $1'} account.list); do awk -v user="$user" '$0 ~ user {print "export OS_PROJECT_DOMAIN_NAME=tacc \nexport OS_USER_DOMAIN_NAME=tacc \nexport OS_PROJECT_NAME=TG-CDA170005 \nexport OS_USERNAME="$3"\nexport OS_PASSWORD='\''" $4 "'\'' \nexport OS_AUTH_URL=https://iu.jetstream-cloud.org:35357/v3 \nexport OS_IDENTITY_API_VERSION=3" }' account.list > /home/$user/openrc.sh; done`

### Install the openstack client

For installing the python-openstackclient, you may need to update pip3 (all of these are global, as root). Also, you'll might want to check first which pip is the default. While Python3 is present, it may not be the default...best to check before things go sidewise.

*which pip
*pip --version

If pip is 2.x, you might check for pip3

*which pip3

Depending on what you find, you'll either use pip or pip3 -- just using pip3 below as the example

*pip3 install -U pip

and also override the distools PyYAML:

*pip3 install --ignore-installed PyYAML

and then the ever popular

*pip install python-openstackclient

If you need other OpenStack project specific clients (e.g. Magnum or Manila), install accordingly.
