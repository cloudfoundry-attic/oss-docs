##OpenStack Installation:

###OpenStack Code Names:
 Each OpenStack service has a code name. Code Names to be used in this document


| Service name 	| Code name 	 
| -----------------------	| -------------------------------
| Identity 	| Keystone 	
| Compute 	| Nova 	
| Image 	| Glance 	
| Dashboard 	| Horizon 	
| Object Storage 	| Swift 	 
| Networking 	| Quantum                  


##Version:
     OpenStack Essex(2012.1) Ubuntu 12.04

##Prerequisites:

###Hardware Requirements:
   
   1. A Box with Virtualization Enabled.

   2. 64 GB RAM (32 GB was sufficient for deploying Micro bosh and Wordpress)

   3. 12 processing cores

   4. (2) hard drives

   5. (2) ethernet cards.



###Multi Node Installation (Types of Nodes required):
 
   1. 1 Controller 

   2. x Compute Nodes 

   3. No special Storage Service (Swift) needed. 

   4. Nova Volume and Glance will be used for Storage 


Networking Topology : Flat DHCP (Nova Network service running on Controller Node)



##1. Prepare System

###Update and upgrade the system.

     sudo s
     apt-get update
     apt-get upgrade

 Install vim It is a text editor and is much easier to use than vi editor


     apt-get install vim

Copy script (openstack_base_1.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

It will install ntp, tgt target, openiscsi-client. 

    ./openstack_base_1.sh

1. NTP - It keeps all the services in sync across multiple machines, we need to install NTP.
2. tgt target -  features an iscsi target, we need it for nova-volume service.
3. openiscsi-client - is required to run nova-compute service.

After running above script update networking configuration as follows

As stated earlier we need 2 nic cards. eth0 is the machine's link to the outside world, eth1 is the interface we'll be using for our virtual machines. We'll also make nova bridge clients via eth0 into the internet.

     vim /etc/network/interfaces

Below is the example configuration.

     auto lo
     iface lo inet loopback

     auto eth0
     iface eth0 inet static
     address 10.0.0.2
     netmask 255.0.0.0
     gateway 10.0.0.1

     auto eth1
     iface eth1 inet static
     address 192.168.22.1
     netmask 255.255.255.0


Note:- Make sure that you have given the actual machine IP under eth0 as address.In this example 10.0.0.2 is the machine IP, which is the OpenStack Controller.

   Points to remember:

    1.	Controller Node IP - 10.0.0.2(We will be using this ip while installing keystone and nova)
    2.	eth1 ip series - 192.168.22.1

 
restart the networking interface.

    /etc/network/interfaces restart

Copy script (openstack_base_2.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a>  and run. 

It will install bridge-utils, rabbitmq-server and kvm.

    ./openstack_base_2.sh

 1. RabbitMQ, AMQP and Python Memcache - OpenStack components use RabbitMQ, and AMQP-implementation to communicate each other.
 2. KVM - OpenStack uses KVM and libvirt to control virtual machines.


Note:- Now you can check the support for the virtualization using the below command:
         
     kvm-ok.

     output should be:
     INFO: /dev/kvm exists
     KVM acceleration can be used

##2. Install MySQL

MySQL - Nova and glance will use MySQL to store their runtime data.

Copy script (openstack_mysql.sh)  from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

It will install mysql and also creates OpenStack databases and users. 

    
    ./openstack_mysql.sh

You'll be prompted for a password which will be the password of users and databases MySQL:

    Enter a password to be used for the OpenStack services to talk to MySQL (users nova, glance, keystone) : vmware

 During the installation process you will be prompted for a root password for MySQL. 

    1. You can use the same password, vmware. 
    2. At the end of the MySQL install you'll be prompted for your root password again. Enter same password vmware.

After MySQL is running, you should be able to login with any of the OpenStack users and/or the root admin account by doing the following:

    mysql -u root -pvmware
    mysql -u nova -pvmware nova
    mysql -u keystone -pvmware keystone
    mysql -u glance -pvmware glance

##3. Installing Keystone

The Keystone service manages users, tenants (accounts or projects) and offers a common identity system for all the OpenStack components.

Copy script (openstack_keystone.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

It will install keystone.

    ./openstack_keystone.sh

You'll be prompted for a token, the password(vmware) and your email address. The email address is used to populate the user's information in the database.

    Enter a token for the OpenStack services to auth with keystone: admin
    Enter the password you used for the MySQL users (nova, glance, keystone): vmware
    Enter the email address for service accounts (nova, glance, keystone): user@vmware.com

Check the status of Keystone installation:

To set the environment variables run the following command:

     . ./stackrc 
     keystone user-list

The output should be something like this:

               id	                  enabled	       email	        name
    b32b9017fb954eeeacb10bebf14aceb3	True	     demo@mail.com	    demo
    bfcbaa1425ae4cd2b8ff1ddcf95c907a	True	     glance@mail.com	glance
    c1ca1604c38443f2856e3818c4ceb4d4	True	     nova@mail.com	    nova
    dd183fe2daac436682e0550d3c339dde	True	     admin@mail.com	    admin

Finally most importantly Update template file like below:

    vim /etc/keystone/default_catalog.templates
 config for TemplatedCatalog, using camelCase because I don't want to do 

    # translations for keystone compat
    catalog.RegionOne.identity.publicURL = http://10.0.0.2:$(public_port)s/v3.0
    catalog.RegionOne.identity.adminURL = http://10.0.0.2:$(admin_port)s/v2.0
    catalog.RegionOne.identity.internalURL = http://10.0.0.2:$(public_port)s/v2.0
    catalog.RegionOne.identity.name = Identity Service

    # fake compute service for now to help novaclient tests work
    catalog.RegionOne.compute.publicURL = http://10.0.0.2:$(compute_port)s/v1.1/$(tenant_id)s
    catalog.RegionOne.compute.adminURL = http://10.0.0.2:$(compute_port)s/v1.1/$(tenant_id)s
    catalog.RegionOne.compute.internalURL = http://10.0.0.2:$(compute_port)s/v1.1/$(tenant_id)s
    catalog.RegionOne.compute.name = Compute Service

    catalog.RegionOne.volume.publicURL = http://10.0.0.2:8776/v1/$(tenant_id)s
    catalog.RegionOne.volume.adminURL = http://10.0.0.2:8776/v1/$(tenant_id)s
    catalog.RegionOne.volume.internalURL = http://10.0.0.2:8776/v1/$(tenant_id)s
    catalog.RegionOne.volume.name = Volume Service

    catalog.RegionOne.ec2.publicURL = http://10.0.0.2:8773/services/Cloud
    catalog.RegionOne.ec2.adminURL = http://10.0.0.2:8773/services/Admin
    catalog.RegionOne.ec2.internalURL = http://10.0.0.2:8773/services/Cloud
    catalog.RegionOne.ec2.name = EC2 Service

    catalog.RegionOne.image.publicURL = http://10.0.0.2:9292/v1
    catalog.RegionOne.image.adminURL = http://10.0.0.2:9292/v1
    catalog.RegionOne.image.internalURL = http://10.0.0.2:9292/v1
    catalog.RegionOne.image.name = Image Service

Note:- Replace the ip 10.0.0.2 with the actual IP of contoller node.

Note:- If you are using vim used the following command
:%s/localhost/10.0.0.2/g

Restart Keystone service 
    
     service keystone restart

##4. Installing Glance

Glance is Openstacks Image Manager service.

Set up a logical volume for Nova to use for creating snapshots and volumes. Here you need secondary Hard Disk attached to the server.

Here's the output from the format and volume creation process:


We need to install lvm2 (logical Volume Manager) to create volumes.

    apt-get install lvm2

    fdisk /dev/sdb

    Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
    Building a new DOS disklabel with disk identifier 0xb39fe7af.
    Changes will remain in memory only, until you decide to write them.
    After that, of course, the previous content won't be recoverable.

    <b>Warning:</b> invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

    Command (m for help): n
    Partition type:
      p   primary (0 primary, 0 extended, 4 free)
      e   extended
    Select (default p): p
    Partition number (1-4, default 1): 1
    First sector (2048-62914559, default 2048): 
    Using default value 2048
    Last sector, +sectors or +size{K,M,G} (2048-62914559, default 62914559): 
    Using default value 62914559

    Command (m for help): w
    The partition table has been altered!

    Calling ioctl() to re-read partition table.
    Syncing disks.
    pvcreate -ff /dev/sdb1
     Physical volume "/dev/sdb1" successfully created
    vgcreate nova-volumes /dev/sdb1
     Volume group "nova-volumes" successfully created
 

Copy script (openstack_glance.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

    ./openstack_glance.sh

The script will download an Ubuntu 12.04 LTS cloud image from StackGeek's S3 bucket. 

Now Test Glance

    glance index

The output should display the newly added image.


##5. Installing Nova

OpenStack Compute, codenamed Nova, is the most important openstack component. 

Note:- Create a file called nova-restart.sh like below and place it exactly where install-nova.sh resides. install-nova.sh uses this file to restart nova services.



We will execute this file whenever we need to restart nova.

    #!/bin/bash

    # Make sure only root can run our script
    if [ "$(id -u)" != "0" ]; then
     echo "You need to be 'root' dude." 1>&2
     exit 1
    fi

    # stop and start nova
    for a in libvirt-bin nova-network nova-compute nova-api nova-objectstore nova-scheduler nova-volume nova-vncproxy; do service "$a" stop; done
    for a in libvirt-bin nova-network nova-compute nova-api nova-objectstore nova-scheduler nova-volume nova-vncproxy; do service "$a" start; done



Copy script (openstack_nova.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

    ./openstack_nova.sh

You'll immediately be prompted for a few items, including your existing network interface's IP address, the fixed network address, and the floating pool addresses:



    #######################################################################################
    The IP address for eth0 is probably 10.0.1.35. Keep in mind you need an eth1 for this to work.
    #######################################################################################
    Enter the primary ethernet interface IP: 10.0.1.35
    Enter the fixed network (eg. 10.0.2.32/27): 10.0.2.32/27
    Enter the fixed starting IP (eg. 10.0.2.33): 10.0.2.33
    #######################################################################################
    The floating range can be a subset of your current network.  Configure your DHCP server
    to block out the range before you choose it here.  An example would be 10.0.1.224-255
    #######################################################################################
    Enter the floating network (eg. 10.0.1.224/27): 10.0.1.224/27
    Enter the floating network size (eg. 32): 32



Test Nova

    nova list

This should display all the nova services running

    nova image-list

This should display the image we uploaded while installing glance.

Nova Version:

    nova-manage version list
    2012.1.3-dev (2012.1.3-LOCALBRANCH:LOCALREVISION)




##6. Installing Horizon

Copy script (openstack_horizon.sh) from  <a href="https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/openstack_scripts"> here </a> and run. 

Install Dashboard

    ./openstack_horizon.sh

Restart Apache

    service apache2 restart

Test Dashboard

    Open Browser and enter below URL:

    http://10.0.0.2 - This is the IP of controller node/where you installed dashboard.

    It should display the OpenStack Dashboard. Use below credentials to login to Dashboard

    User ID : admin
    password : vmware



# Installing Additional Compute Nodes

##Prerequisites:

1. Install 64 bit version of Ubuntu server 12.04


## Step 1 : Prepare your System

Update and upgrade the system.

    sudo su
    apt-get update
    apt-get upgrade

Install vim  - It is a text editor and is much easier to use than vi editor

    apt-get install vim


## Step 2 : Network Configuration

Install bridge-utils

    apt-get install bridge-utils

Edit the  /etc/network/interfaces file so as to looks like this

    vim /etc/network/interfaces

Below is the example configuration.
    auto lo
    iface lo inet loopback

    auto eth0
    iface eth0 inet static
    address 10.0.0.2
    netmask 255.0.0.0
    gateway 10.0.0.1

    auto eth1
    iface eth1 inet static
    address 192.168.22.1
    netmask 255.255.255.0

Note:- Make sure that you have given the actual machine IP under eth0 as address.In this example 10.0.0.2 is the machine IP, which is the OpenStack Controller.

Points to remember:-
1.Controller Node IP - 10.0.0.2(We will be using this ip while installing keystone and nova)
2.eth1 ip series - 192.168.22.1

 Restart Network

    /etc/init.d/networking restart

## Step 3 : Install NTP

To keep all the services in sync across multiple machines, we need to install NTP.

    apt-get install ntp

Update <b>ntp.conf</b> and add below lines.

    vim /etc/ntp.conf
    server 10.0.0.2

Note:- Make sure that you have given the actual machine IP of OpenStack Controller node.

Restart NTP
  
    service ntp restart


## Step 4: Install Nova

Install the nova-components and dependencies

    apt-get install nova-compute

Update the <b>/etc/nova/nova.conf</b>

    vim /etc/nova/nova.conf


Note:- Copy the contents of nova.conf from controller node and paste here.

Restart nova-compute

    service nova-compute restart

Check if the second compute node is detected by Controller node or not.

    nova-manage service list

Note:- You can run this command either on controller or compute node.


The output should be something like this:


       Binary                   Host             Zone             Status     State Updated_At
    nova-network             controller          nova             enabled    :-)   2012-04-20 08:58:43
    nova-scheduler           controller          nova             enabled    :-)   2012-04-20 08:58:44
    nova-volume              controller          nova             enabled    :-)   2012-04-20 08:58:44
    nova-compute             controller          nova             enabled    :-)   2012-04-20 08:58:45
    nova-cert                controller          nova             enabled    :-)   2012-04-20 08:58:43
    nova-compute             compute-node        nova             enabled    :-)   2012-04-21 10:22:27





