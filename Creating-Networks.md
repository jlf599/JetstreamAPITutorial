# Creating Networks

We've created this separate doc for those that insist that they need to create their own networks. We do not encourage this and instead recommend using the auto_allocated_network that is created automatically for each allocation. 

## Create and configure the network (this is usually only done once)

Create the network

```
openstack network create myusername-api-net [--dns-domain AAA000000.projects.jetstream-cloud.org]
```

The –dns-domain is optional but recommended. You will need to install python-designateclient for dns services.
Substitute your ACCESS allocation number for the generic AAA000000 above.

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
openstack subnet create --network myusername-api-net --use-default-subnet-pool myusername-api-subnet1
```

Create a router

> :warning: You will not be able to create a router without explicit permission from Jetstream2 staff. There are technical and operational reasons to limit the number of routers allowed. 

```
openstack router create myusername-api-router
```

Attach your subnet to the router

```
openstack router add subnet myusername-api-router myusername-api-subnet1
```

Attach your router to the public (externally routed) network

```
openstack router set --external-gateway public myusername-api-router
```

*Note: You cannot attach an instance directly to the public router. This was a conscious design decision. 

Note the details of your router

```
openstack router show myusername-api-router
```