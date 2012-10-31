# Install and prepare vSphere Cluster#

Before we start the cloudfoundry deployment we need to setup a vsphere cluster. In this guide we will be using minimal configuration to setup the cluster:

1. 2 servers to install ESXi ( x core processor , y GB Ram : x and y depend on the hardware config chosen)
2. 1 server to install vcenter(this can also be a vm in any of the esxi server)
3. Storage server (SAN is recommended but you can also use other storages like openfiler)
4. Switch 
5. Network : IP Ranges atleast 100 IPs

##Install ESXi and vCenter##

Cloud Foundry can be deployed on top of variety of Infrastructures, ESXi and vCenter happen to be one of them. 
There is no difference from the standard installation. After installation your ESXi will look like the image below

![esxi] (https://raw.github.com/rajdeepd/bosh-oss-docs/master/bosh/documentation/images/esxi5.png)

##Prepare vCenter for Cloud Foundry Deployment##


##Create the Datacenter##

In vCenter, go to `Hosts and Clusters` then click on `Create a Datacenter`. A new datacenter will be created in the left panel. Give a suitable name and press the enter key. 

![datacenter](https://raw.github.com/aneeshep/bosh-oss-docs/master/bosh/documentation/images/datacenter.png)

##Create a Cluster##

Now the datacenter is created. Next task to create a Cluster and add ESXi hosts to the cluster.

1. Select the datacenter we created in the above step.
2. Click on `Create a cluster` link.
3. `New cluster wizard` will open. Give a suitable name to the cluster, Click next and follow the wizard

Once you finish, you can see the new cluster created in the left panel

![cluster1] (https://raw.github.com/aneeshep/bosh-oss-docs/master/bosh/documentation/images/cluster1.png)


###Create the resource pool###

Create a resource pool.

###Add the ESXi hosts to the cluster###

1. Select the cluster we have created in the above step.
2. Click on the `Add a Host` link
3. `Add host wizard` will appear. Give the ip address/hostname and login credentials for the ESXi host. click next and follow the wizard

Once you finish You can see the newly added host in the left panel

![host1](https://raw.github.com/aneeshep/bosh-oss-docs/master/bosh/documentation/images/add_host.png)




##Create the required folders for vms, templates and disk path##

Micro BOSH and BOSH uses predefined locations for vms, template and disk_path that you will define in the deployment manifest.

###Create the vm and template folder###

 1. Click on Inventory, `Select Vms and Templates`
 2. Select the datacenter we have created in the above steps.
 3. Click on the `New folder` icon on the top of the left panel to create new folder
 4. Create 4 folders as follows:

   + MicroBOSH\_VMs , MicroBOSH\_Templates (for micro bosh)
   + CF\_VMs, CF\_Templates ( for bosh)

![vms_and_folders](https://raw.github.com/aneeshep/bosh-oss-docs/master/bosh/documentation/images/vms_templates.png)

###Create the disk path###

1. Click on Inventory, `Datastore and Datastore Clusters`
2. Right clik the datastore in which you want to store the disks of vms, Select `Browse Datastore` . The Datastore will open in a new window.
3. Click on the `Create new folder` on the top the window to create new folder.
4. Create 2 folders as follows:



MicroBOSH\_Disks ( for micro bosh)
CF\_Disks( for bosh)

![datastore1] (https://raw.github.com/aneeshep/bosh-oss-docs/master/bosh/documentation/images/datastore.png)


Done. vSphere cluster is ready fo Cloud Foundry deployment.



