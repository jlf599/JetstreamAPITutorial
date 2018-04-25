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

`cat list.txt| awk '{system("adduser " $1)}'`  

If you're using an Atmo instance, you'll either need to add these accounts to the users group (which might inadvertantly give them sudo access) or create a new group to add them to -- which you'll then need to add to the sshd_config at the bottom.

-----------------
To set passwords via cleartext:

`awk '{ system("echo " $1":"$2" |chpasswd") }' userlist.txt`

Assuming a file with username in col 1 and pass in col 2

-----------------
Generate openrc for the API class host:

for user in $(awk '{print $4'} account.list)
do
  awk -v user="$user" '$0 ~ user {print "export OS_PROJECT_DOMAIN_NAME=tacc \nexport OS_USER_DOMAIN_NAME=tacc \nexport OS_PROJECT_NAME=tg-trA100001s \nexport OS_USERNAME="$4"\nexport OS_PASSWORD='\''" $3 "'\'' \nexport OS_AUTH_URL=ENDPOINT_URL_GOES_HERE \nexport OS_IDENTITY_API_VERSION=3" }' account.list > /home/$user/openrc.sh
done

