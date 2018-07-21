Add this to /etc/skel -- this stops the forced updates. Not a best practice but in the name of expediency for a tutorial, it's necessary.

vi cloud.cfg

#cloud-config
packages: []

package_update: false
package_upgrade: false
package_reboot_if_required: false

final_message: "Boot completed in $UPTIME seconds"

------------------

Create the accounts:

list.txt should just have usernames in a text file, one per line -- or any other delimited file you can awk cleanly

*Make sure the list isn't dos format (vi will say [dos] at the bottom -- not sure about other editors) - you can easily fix this in vi by opening the file, doing :set ff=unix, and then saving the file.*

`cat list.txt| awk '{system("adduser " $1)}'`  

If you're using an Atmo instance, you'll either need to add these accounts to the users group (which might inadvertantly give them sudo access) or create a new group to add them to -- which you'll then need to add to the sshd_config at the bottom.

`groupadd train`

`awk '{system("usermod -G train " $1)}' passlist.txt`

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

-----------------
To set passwords via cleartext:

`awk '{ system("echo " $1":"$2" |chpasswd") }' userlist.txt`

Assuming a file with username in col 1 and pass in col 2

-----------------
Generate openrc for the API class host -- make sure the allocation/PROJECT_NAME is correct as that can possibly change. Also, make sure you set the ENDPOINT

This assumes your input file has fields 
XSEDE_Username XSEDE_Password TACC_Username TACC_Password 
--> change the awk vars as needed if you format varies. 

`for user in $(awk '{print $1'} account.list); do awk -v user="$user" '$0 ~ user {print "export OS_PROJECT_DOMAIN_NAME=tacc \nexport OS_USER_DOMAIN_NAME=tacc \nexport OS_PROJECT_NAME=TG-CDA170005 \nexport OS_USERNAME="$3"\nexport OS_PASSWORD='\''" $4 "'\'' \nexport OS_AUTH_URL=https://iu.jetstream-cloud.org:35357/v3 \nexport OS_IDENTITY_API_VERSION=3" }' account.list > /home/$user/openrc.sh; done`


