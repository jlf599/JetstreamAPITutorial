# Gateways OpenStack API Tutorial

# Introduction to OpenStack CLI
The OpenStack command line interface (CLI) is only one way to interact with OpenStack’s RESTful API. In this exercise we will use the command line clients installed on Jetstream instances to OpenStack entities; e.g. images, instances, volumes, objects, networks, etc.

We'll be using a host that's been prepped with a recent OpenStack python client and the appropriate credentials. Typically you would need to have the CLI clients installed. The latest client is available from https://pypi.python.org/pypi/python-openstackclient

Instructions for installing clients for multiple operating systems is here: https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html

Note that many people prefer installing in a virtualenv. An example of that would be:
```
[user@localhost]$ virtualenv ~/venv
[user@localhost]$ source ~/venv/bin/activate
(venv)user@localhost$ pip install python-openstackclient
```
Also note that we will **NOT** be installing the clients for this tutorial.

## Some background getting started Jetstream Documentation

Getting started with the Jetstream’s OpenStack API
http://wiki.jetstream-cloud.org/Using+the+Jetstream+API

Notes about accessing Jetstream’s OpenStack API
http://wiki.jetstream-cloud.org/After+API+access+has+been+granted

SDKs for programmatically accessing OpenStack’s APIs
https://developer.openstack.org/firstapp-libcloud/getting_started.html

openrc.sh for Jetstream’s OpenStack API
http://wiki.jetstream-cloud.org/Setting+up+openrc.sh

## Getting started with the hands on portion of the tutorial
### Insuring that your credentials are in order
Jetstream is an XSEDE resource and you must have an XSEDE account before you can use it either via the Atmosphere user interface or the OpenStack API. The following steps must work before proceeding; specifically, accessing the Horizon dashboard. If you cannot login to the Horizon dashboard, nothing else will work. When you first get API access on Jetstream, that's typically how we recommend people test their credentials.

## Access Openstack Client Server

To access the client server, use your provided username and password, and log in to

```
ssh your_training_user@tutorial.jetstream-cloud.org
```

You'll actually want to have **TWO** connections to this host. The reasons will be more obvious later.

You may experience a delay after typing in your password - this is normal! Don't cancel your connection.

## Configure openstack client

First, double-check the openrc.sh with your training account info - the file already exists in your home directory. Normally you'd have to create your own -- refer to http://wiki.jetstream-cloud.org/Setting+up+openrc.sh 

```
[Tutorial] train60 ~--> cat ./openrc.sh
export OS_PROJECT_DOMAIN_NAME=tacc 
export OS_USER_DOMAIN_NAME=tacc 
export OS_PROJECT_NAME=TG-CDA170005 
export OS_USERNAME=SET_ME
export OS_PASSWORD='REDACTED' 
export OS_AUTH_URL=ADD_END_POINT
export OS_IDENTITY_API_VERSION=3
```

In the real world you will want not want to save your password in a file. A much more secure way to set OS_PASSWORD is to read it from the command line when the openrc is sourced. E.g.

```
echo "Please enter your OpenStack Password: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
```

Next, add these environment variables to your shell session:
```
source openrc.sh
```

Ensure that you have working openstack client access by running:
```
openstack image list | grep JS-API-Featured
```

# A few notes about openstack commands
## Command structure
* openstack NOUN VERB PARAMETERS
* openstack help [NOUN [VERB [PARAMETER]]]
* openstack NOUN VERB -h will also produce the help documentation
* Common NOUNs include image, server, volume, network, subnet, router, port, etc.
* Common verbs are list, show, set, unset, create, delete, add, remove, etc.
* Two commonly used verbs are list and show
* list will show everything that your project is allowed to view
* show takes a name or UUID and shows the details of the specified entity

E.g. 

```
openstack image list
openstack image show JS-API-Featured-Centos7-Oct-21-2017
openstack image show 479c5802-de20-497a-bc0d-8f2f1816801d
```

It's also important to note that the OpenStack CLI client offers help for the commands

E.g.

```
openstack help image
openstack help image show
```

## Names verses UUIDs
* Names and Universally Unique Identifier (UUID) are interchangeable on the command line
* IMPORTANT POINT TO NOTE: OpenStack will let you name two or more entities with the same names. If you run into problems controlling something via its name, then fall back to the UUID of the entity.
* Once you have two entities with the same name, your only recourse is to use the UUID

## Creating the cyberinfrastructure and booting your first instance

It is informative to follow what’s happening in the Horizon dashboard as you execute commands. Keep in mind that in OpenStack everything is project based. Everyone in this tutorial is in the same OpenStack project. In the Horizon dashboard you will see the results of all the other students commands as they execute them. You can also affect other objects in your project, so **tread carefully and don't delete someone else's work!** 

## What we’re going to do
* Create security group and add rules
* Create and upload ssh keys
* Create and configure the network (this is only done once)
* Start an instance
* Log in and take a look around
* Shutdown the instance
* Dismantle what we have built

# Create security group and adding rules to the group

By DEFAULT, the security groups on Jetstream (OpenStack in general) are CLOSED - this is the opposite of how firewalls typically work (completely OPEN by default). If you create a host on a new allocation without adding it to a security group that allows access to some ports, you will not be able to use it!

Create the group that we will be adding rules to

```
openstack security group create --description "ssh & icmp enabled" ${OS_USERNAME}-global-ssh
```

Create a rule for allowing ssh inbound from an IP address

```
openstack security group rule create --proto tcp --dst-port 22:22 --src-ip 0.0.0.0/0 ${OS_USERNAME}-global-ssh
```

Create a rule that allows ping and other ICMP packets

```
openstack security group rule create --proto icmp ${OS_USERNAME}-global-ssh
```
*There's a reason to allow icmp. It's a contentious topic, but we recommend leaving it open. http://shouldiblockicmp.com/

Optional rule to allow connectivity within a mini-cluster; i.e. if you boot more than one instance, this rule allows for comminications amongst all those instances. *We won't need this today*

```
openstack security group rule create --proto tcp --dst-port 1:65535 --src-ip 10.0.0.0/0 ${OS_USERNAME}-global-ssh
openstack security group rule create --proto udp --dst-port 1:65535 --src-ip 10.0.0.0/0 ${OS_USERNAME}-global-ssh
```

A better (more restrictive) example might be: *We will continue to not need this today*

```
openstack security group rule create --proto tcp --dst-port 1:65535 --src-ip 10.X.Y.0/0 ${OS_USERNAME}-global-ssh
openstack security group rule create --proto udp --dst-port 1:65535 --src-ip 10.X.Y.0/0 ${OS_USERNAME}-global-ssh
```

Look at your security group (optional)

```
openstack security group show ${OS_USERNAME}-global-ssh
```

Adding/removing security groups after an instance is running (you don't have a server running yet so these will produce an error -- it's just information you might need later).

```
openstack server add    security group ${OS_USERNAME}-api-U-1 ${OS_USERNAME}-global-ssh
openstack server remove security group ${OS_USERNAME}-api-U-1 ${OS_USERNAME}-global-ssh
```

*Note: that when you change the rules within a security group you are changing them in real-time on running instances. When we boot the instance below, we will specify which security groups we want to associate to the running instance.*

## Access to your instances will be via ssh keys
If you do not already have an ssh key we will need to create on. For this tutorial we will create a passwordless key. In the real world, you would not want to do this

```
ssh-keygen -b 2048 -t rsa -f ${OS_USERNAME}-api-key -P ""
```

Upload your key to OpenStack

```
openstack keypair create --public-key ${OS_USERNAME}-api-key.pub ${OS_USERNAME}-api-key
```

Look at your keys (optional)

```
openstack keypair list
```

**If you want to be 100% sure, you can show the fingerprint of your key with

```
ssh-keygen -l -E md5 -f ${OS_USERNAME}-api-key
```

## Looking at Horizon

Open a new tab or window to

### https://iu.jetstream-cloud.org/dashboard/

with your tg???? id and password (in your openrc.sh file), to monitor your build progress on the Horizon interface.
You will also be able to view other trainees instances and networks - **PLEASE do not delete 
or modify anything that isn't yours!**

And let's talk a bit here about Horizon, what it is, and why we're using the CLI and not this GUI...

After the network creation, let's look at Horizon again to see the changes.

## A brief look at volumes

## Create and configure the network (this is usually only done once)

Create the network

```
openstack network create ${OS_USERNAME}-api-net
```

List the networks; do you see yours?

```
openstack network list
```

Create a subnet within your network. 

If you want to list the subnets that have been created, just in case

```
openstack subnet list
```

Then create your subnet - notice that you can all use the same 10.0.0.0 network. You *can* use a different address space, but you don't have to.

```
openstack subnet create --network ${OS_USERNAME}-api-net --subnet-range 10.0.0.0/24 ${OS_USERNAME}-api-subnet1
```

Create a router

```
openstack router create ${OS_USERNAME}-api-router
```

Attach your subnet to the router

```
openstack router add subnet ${OS_USERNAME}-api-router ${OS_USERNAME}-api-subnet1
```

Attach your router to the public (externally routed) network

```
openstack router set --external-gateway public ${OS_USERNAME}-api-router
```

*Note: You cannot attach an instance directly to the public router. This was a conscious design decision. 

Note the details of your router

```
openstack router show ${OS_USERNAME}-api-router
```

### Stopping and smelling the roses

Well, looking at the changes in Horizon -

### https://iu.jetstream-cloud.org/dashboard/

## Start an instance

Note the flavors (sizes) of instances that create

```
openstack flavor list
```

Note the possible images that you can use on the API side of Jetstream.

```
openstack image list --limit 500 | grep JS-API-Featured
```

*Note: Images without the JS-API- string are destined to be boot via Atmosphere. Atmosphere runs various scripts during the boot process. If you are booting via the API then these scripts will not get executed and the booted instance may (probably) will not be usable. We're going to use a CentOS 7 API Featured image

Time to boot your instance -- please note that the image will change! They are updated and named with the date.

```
openstack server create ${OS_USERNAME}-api-U-1 \
--flavor m1.tiny \
--image JS-API-Featured-Centos7-Oct-21-2017 \
--key-name ${OS_USERNAME}-api-key \
--security-group ${OS_USERNAME}-global-ssh \
--nic net-id=${OS_USERNAME}-api-net
```

*Note that ${OS_USERNAME}-api-U-1 is the name of the running instance. A best practice for real usage is to pick a name that helps you identify that server. Each instance you boot should have a unique name; otherwise, you will have to control your instances via the UUID

*Note on patching 

Create an IP address…

```
openstack floating ip create public
```

…then add that IP address to your running instance.

```
openstack server add floating ip ${OS_USERNAME}-api-U-1 <your.ip.number.here>
```

Is the instance reachable?

```
ping <your.ip.number.here>
```

In your second terminal window and/or with your favorite ssh client (if you use an external ssh client, you'll need to get that private key to put in it!)

```
ssh -i ${OS_USERNAME}-api-key centos@<your.ip.number.here> *or*
ssh -i ${OS_USERNAME}-api-key ubuntu@<your.ip.number.here>

```

Creating a volume:

Back in your openstack window, do the following:

```
openstack volume create --size 10 ${OS_USERNAME}-10GVolume
```

Now, add the new storage device to your VM:

```
openstack server add volume ${OS_USERNAME}-api-U-1 ${OS_USERNAME}-10GVolume
```

Let's ssh in and get the volume working (if you're not still logged in via the other window):

```
ssh -i ${OS_USERNAME}-api-key centos@<your.ip.number.here> *or*
ssh -i ${OS_USERNAME}-api-key ubuntu@<your.ip.number.here>
```

Become root on your VM: (otherwise, you'll have to preface much of the following with sudo)
```
sudo su -
```

Find the new volume on the headnode with (most likely it will mount as sdb):
```
[Tutorial] root ~--> dmesg | grep sd
[    1.715421] sd 2:0:0:0: [sda] 16777216 512-byte logical blocks: (8.58 GB/8.00 GiB)
[    1.718439] sd 2:0:0:0: [sda] Write Protect is off
[    1.720066] sd 2:0:0:0: [sda] Mode Sense: 63 00 00 08
[    1.720455] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.725878]  sda: sda1
[    1.727563] sd 2:0:0:0: [sda] Attached SCSI disk
[    2.238056] XFS (sda1): Mounting V5 Filesystem
[    2.410020] XFS (sda1): Ending clean mount
[    7.997131] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    8.539042] sd 2:0:0:0: Attached scsi generic sg0 type 0
[    8.687877] fbcon: cirrusdrmfb (fb0) is primary device
[    8.719492] cirrus 0000:00:02.0: fb0: cirrusdrmfb frame buffer device
[  246.622485] sd 2:0:0:1: Attached scsi generic sg1 type 0
[  246.633569] sd 2:0:0:1: [sdb] 20971520 512-byte logical blocks: (10.7 GB/10.0 GiB)
[  246.667567] sd 2:0:0:1: [sdb] Write Protect is off
[  246.667923] sd 2:0:0:1: [sdb] Mode Sense: 63 00 00 08
[  246.678696] sd 2:0:0:1: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[  246.793574] sd 2:0:0:1: [sdb] Attached SCSI disk
```

Create a new filesystem on the device (from the VM):

```
mkfs.xfs /dev/sdb
```

Create a directory for the mount point and mount it (on the VM):

```
mkdir /testmount
mount /dev/sdb /testmount
df -h
```

Let's clean up the volume (from the instance):
```
cd /
umount /testmount
```

Do this from the shell host:
```
openstack server remove volume ${OS_USERNAME}-api-U-1 ${OS_USERNAME}-10GVolume
openstack volume delete ${OS_USERNAME}-10GVolume
```


## Putting our instance into a non-running state

Reboot the instance (shutdown -r now).

```
openstack server reboot ${OS_USERNAME}-api-U-1

or

openstack server reboot ${OS_USERNAME}-api-U-1 --hard
```

Stop the instance (shutdown -h now). Note that state is not retained and that resources are still reserved on the compute host so that when you decide restart the instance, resources are available to activate the instance.

```
openstack server stop ${OS_USERNAME}-api-U-1
openstack server start ${OS_USERNAME}-api-U-1
```

Pause the instance Note that your instance still remains in memory, state is retained, and resources continue to be reserved on the compute host assuming that you will be restarting the instance.

```
openstack server pause   ${OS_USERNAME}-api-U-1
openstack server unpause ${OS_USERNAME}-api-U-1
```

Put the instance to sleep; similar to closing the lid on your laptop. 
Note that resources are still reserved on the compute host for when you decide restart the instance

```
openstack server suspend ${OS_USERNAME}-api-U-1
openstack server resume  ${OS_USERNAME}-api-U-1
```

Shut the instance down and move to storage. Memory state is not maintained. Ephemeral storage is maintained. 
Note that resources are still reserved on the compute host for when you decide restart the instance

```
openstack server shelve ${OS_USERNAME}-api-U-1
openstack server unshelve ${OS_USERNAME}-api-U-1
```

## Dismantling what we have built
Note that infrastructure such as networks, routers, subnets, etc. only need to be created once and are usable by all members of the project. These steps are included for completeness. And, to clean up for the next class.

Remove the IP from the instance

```
openstack server remove floating ip ${OS_USERNAME}-api-U-1 <your.ip.number.here>
```

Return the IP to the pool

```
openstack floating ip delete <your.ip.number.here>
```

Delete the instance

```
openstack server delete ${OS_USERNAME}-api-U-1
```

Unplug your router from the public network

```
openstack router unset --external-gateway ${OS_USERNAME}-api-router
```

Remove the subnet from the network

```
openstack router remove subnet ${OS_USERNAME}-api-router ${OS_USERNAME}-api-subnet1
```

Delete the router

```
openstack router delete ${OS_USERNAME}-api-router
```

Delete the subnet

```
openstack subnet delete ${OS_USERNAME}-api-subnet1
```

Delete the network

```
openstack network delete ${OS_USERNAME}-api-net
```

Delete the security group

```
openstack security group delete ${OS_USERNAME}-global-ssh
```

Delete the key pair
```
openstack keypair delete ${OS_USERNAME}-api-key
```

For further investigation…
A tutorial was presented at the PEARC17 conference on how to build a SLURM HPC cluster with OpenStack - https://github.com/ECoulter/Tutorial_Practice

The tutorial assumes that a node at IP 149.165.157.95 is running that you need to login to as a first step. (Similar to this exercise.) This node was provided as an easy way to run the class and its only purpose was to provide a host with the openstack CLI clients installed. You can safely skip this step and proceed with executing the openstack commands you see in the tutorial.

There are also two projects going on for virtual clustering:
* https://github.com/ECoulter/Jetstream_Elastic_Slurm
* https://github.com/hpc-cloud-toolkit/ostack-hpc


*Meta: Goo.gl link: https://goo.gl/8ke2fu
