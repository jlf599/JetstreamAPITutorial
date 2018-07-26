#!/bin/bash

# need to make sure these are in the right order
# - things won't delete if router/subnet/network are done
# in the wrong order, right?
os_components=("server" "volume" "router" "subnet" "network" "keypair" "security group")
# made this a single line because doing it with \ got weird...
# - detected any extra spaces as array elements...

public_server_suffix="-headnode"

# Can't stick a variable in that brace expansion...
for user in train{03..50}; do
  source /home/$user/openrc.sh
  server_public_ip=$(openstack server list -f value -c Networks --name ${OS_USERNAME}${public_server_suffix} | sed 's/.*, //')
  echo $OS_USERNAME
  openstack server remove floating ip ${OS_USERNAME}${public_server_suffix} $server_public_ip
  openstack floating ip delete $server_public_ip
  for i in `seq 0 $((${#os_components[*]} - 1))`; do # I apologize.
    echo "Removing ${os_components[$i]} for $OS_USERNAME:"
    openstack ${os_components[$i]} list -f value -c Name | grep ${OS_USERNAME}
    particulars=$(openstack ${os_components[$i]} list -f value -c ID -c Name | grep $OS_USERNAME | cut -f 1 -d' ' | tr '\n' ' ') # this should grab head & computes
    for thing in $particulars; do
      if [[ ${os_components[$i]} =~ "router" ]]; then
        openstack router unset --external-gateway $thing
        subnet_id=$(openstack router show $thing -c interfaces_info -f value | sed 's/\[{"subnet_id": "\([a-zA-Z0-9-]*\)".*/\1/')
        openstack router remove subnet $thing $subnet_id
        openstack router delete $thing
      else
        openstack ${os_components[$i]} delete $thing
      fi
    done
  done

  #ls /home/$user/openrc.sh
  #ls /home/$user/${OS_USERNAME}-api-key*
  #ls -rf /home/$user/.ssh 
  # anything else to delete?
done

#just check that it's all empty
source ./openrc.sh

for i in `seq 0 $((${#os_components[*]} - 1))`; do # I apologize.
  echo "Checking for any remaining ${os_components[$i]}:"
  openstack ${os_components[$i]} list -f value -c Name
done
