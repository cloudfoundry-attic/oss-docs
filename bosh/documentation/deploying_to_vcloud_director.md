#Deploying to vCloud Director Using Cloud Foundry BOSH#

In this tutorial we learn how to deploy a simple Wordpress application on vCloud Director using BOSH.

##Prerequisites##


To get started with BOSH on vCloud you need:

1. An account in a [vCloud organization](http://www.google.com/url?q=http%3A%2F%2Fpubs.vmware.com%2Fvcd-51%2Ftopic%2Fcom.vmware.vcloud.users.doc_51%2FGUID-B2D21D95-B37F-4339-9887-F7788D397FD8.html&sa=D&sntz=1&usg=AFQjCNFXvafOCSo6mu2RqwrqInMggIb0qA) with [organization administrator](http://www.google.com/url?q=http%3A%2F%2Fpubs.vmware.com%2Fvcd-51%2Ftopic%2Fcom.vmware.vcloud.users.doc_51%2FGUID-5B60A9C0-612A-4A3A-9ECE-694C40272505.html&sa=D&sntz=1&usg=AFQjCNHJSQwucHuiTCSsoGSivJX9DnguHw) credentials
2. A vCloud virtual datacenter with an Internet routable network and a block of assigned IP addresses
3. A Mac or *NIX computer


##Installing the BOSH Deployer##

We assume you already have Ruby (1.9.2) and rubygems (1.8) installed. To install the BOSH deployer gem (which includes the BOSH CLI):

	gem install bosh_deployer


## Micro BOSH Stemcells##

+ We have published micro BOSH stemcells for download. When you are ready to use the BOSH deployer download a micro BOSH stemcell.

Download a micro BOSH stemcell with version >= 0.8.0 (coming soon)  Use bosh-release version #11 or higher.

Note :  Stemcells for vSphere work for vCloud Director


		% bosh public stemcells
		+---------------------------------------+--------------------------------------------------+
		| Name 	                                | Tags                                             |
		+---------------------------------------+--------------------------------------------------+
		| bosh-stemcell-aws-0.6.4.tgz           | aws, stable                                      |
		| bosh-stemcell-vsphere-0.6.4.tgz       | vsphere, stable                                  |
		| bosh-stemcell-vsphere-0.6.7.tgz       | vsphere, stable                                  | 
		| micro-bosh-stemcell-aws-0.6.4.tgz     | aws, micro, stable                               |
		| micro-bosh-stemcell-vsphere-0.6.4.tgz	| vsphere, micro, stable                           |
		+---------------------------------------+--------------------------------------------------+

To download use `bosh download public stemcell <stemcell_name>` as shown below
	
	% bosh download public stemcell micro-bosh-stemcell-0.8.0.tgz

##Deploying Micro BOSH##

To deploy Micro Bosh on vCloud you will need to prepare resources from the cloud infrastructure managed by vCloud for use by BOSH.

##Preparing vCloud virtual data center resources##

+ Add a catalog where stemcells and media (ISOs) for BOSH will be stored.

![vcloud_catalog](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/vcloud_images/vcloud_catalog.png)

+ Add a network to the virtual datacenter.  Configure the network to be directly connected to the virtual datacenter external network.  Steps to [Create an External Direct Organization vDC Network](http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.admin.doc_51/GUID-E8A80C28-6C16-4E83-828C-0510DA3B00F8.html).

##Create the Directory Structure##

The BOSH deployer will deploy applications based on files in expected directory locations:

	mkdir ~/deployments
	cd ~/deployments
	mkdir vcloud

##Create Micro BOSH Config File##

Micro BOSH configurations are set in the `micro_bosh.yml`, which you need to create.

+ Create `~/deployments/vcloud/micro_bosh.yml` using [this template](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/samples/micro_bosh-vcloud.yml).

   1. Update the instance of `x.x.x.x` with one of the IPs from the block assigned to you. Change the other IP addresses `n.n.n.n`  to match your network’s netmask, gateway, DNS and NTP server addresses.
   2. Under the vcds section, replace `v.v.v.v` with the address of the vCloud instance and enter your vCloud credentials.
   3. Save the file

##Deploying Micro BOSH##

Micro BOSH can now be deployed from your deployments directory.

+ Make sure you are in your deployments directory:

		cd ~/deployments

+ Select the deployment you created:

		bosh micro deployment vcloud

Note: don’t be concerned by seemingly inaccurate message WARNING! Your target has been changed to `http://vcloud:25555!

+ Start the deployment using the micro stemcell downloaded earlier:

		bosh micro deploy ~/stemcells/micro-bosh-stemcell-vsphere-0.8.0.tgz

+ Within 20 minutes your instance of micro BOSH will be deployed. After the ‘Done’ message appears, you have a running micro BOSH instance.

+ If your deployment failed for some reason use the following to clean up:

		bosh micro delete

+ Log in to the Micro BOSH:

		bosh login

+ Type the default account name is admin and the password is admin
+ Change the account name and password using the command below. Don’t say we didn’t tell you if someone deletes your deployment!

		bosh create user <username> <password>

##Deploying an Application Using BOSH##

We have created a sample three-tier application (Nginx, Apache + PHP with WordPress, and MySQL) to demonstrate how you can use BOSH, and the next step is to deploy it using your newly created micro BOSH instance.

##Uploading the Sample Release##

The sample release is on Github for your cloning convenience:

+ First make a git clone of the sample application release repository:

		cd ~
		git clone git://github.com/cloudfoundry/bosh-sample-release.git
		cd bosh-sample-release

+ Upload the release to micro BOSH:

		bosh upload releases/wordpress-1.yml

##Uploading the Latest Stem Cell##

Now we download the latest stem cellto upload to our micro BOSH instance.

   * Download the latest BOSH stem cell for vCloud:

		bosh download public stemcell bosh-stemcell-vsphere-0.6.7.tgz

   * Upload it to your micro BOSH instance:

		bosh upload stemcell bosh-stemcell-vsphere-0.6.7.tgz
		
##Create a Private Network##

   1. [Add private networks](http://pubs.vmware.com/vcd-51/index.jsp?topic=%2Fcom.vmware.vcloud.admin.doc_51%2FGUID-6E69AF88-31E0-4DD8-A79E-E8E4B6F68878.html) to separate application components from each other and from direct access by users. Here, “cf-net” is a direct network added earlier and “cf-routed” is a private network.
	![vcloud_private_network](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/vcloud_images/vcloud_private_network.png)

   1. To allow machines on the private network to talk outside the network, e.g. the micro BOSH, [configure a source NAT rule on the network](http://www.google.com/url?q=http%3A%2F%2Fpubs.vmware.com%2Fvcd-51%2Findex.jsp%3Ftopic%3D%252Fcom.vmware.vcloud.admin.doc_51%252FGUID-464E27A8-3238-4553-ABCF-77808D3A510D.html&sa=D&sntz=1&usg=AFQjCNGXS8KPBo_PsbMblK3bh835u_FFmg).

	![vcloud_source_nat](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/vcloud_images/vcloud_source_nat.png)

##Create a Deployment Manifest##

   1. Get the director UUID using the following command:

		bosh status

   2. Copy the file [wordpress-vcloud.yml](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/samples/wordpress-vcloud.yml) in the bosh-sample-release directory and update it to suit your network.


##Deploy##

   1. Select the deployment manifest you just created:

		bosh deployment ~/wordpress-vcloud.yml

   1. Initiate the deployment:

		bosh deploy

   1. Sit back and enjoy the show!

##Connect to the deployed sample application##

Once your deployment is complete point your browser to the IP of the vm where nginx job is running `http://<nginx-vm-staticip>`.

Congratulations. You just used BOSH to deploy an application to vCloud!
