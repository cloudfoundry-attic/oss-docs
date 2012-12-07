# Deploying Micro BOSH #

Installation of BOSH is done using something called Micro BOSH, which is a single VM that includes all of the BOSH components in the same image. If you want to play around with BOSH, or create a simple development setup, you can install Micro BOSH using the [BOSH Deployer](#bosh-deployer). If you would like to use BOSH in production to manage a distributed system, you also use the BOSH Deployer, install Micro BOSH, and then use it as a means to deploy the final distributed system on multiple VMs.

A good way to think about this two step process is to consider that BOSH is a distributed system in itself. Since BOSH's core purpose is to deploy and manage distributed systems, it makes sense that we would use it to deploy itself. On the BOSH team, we gleefully refer to this as [Inception](http://en.wikipedia.org/wiki/Inception).

## BOSH bootstrap ##

### Prerequisites ###

1. We recommend that you run the BOSH bootstrap from Ubuntu since it is the distribution used by the BOSH team, and has been thoroughly tested.

1. Install some core packages on Ubuntu that the BOSH deployer depends on.

		sudo apt-get -y install libsqlite3-dev genisoimage

1. Ruby 1.9.2 or later.

1. Install the BOSH Deployer ruby gem.

		gem install bosh_deployer

Once you have installed the deployer, you will see some extra commands appear after typing `bosh` on your command line.

**The `bosh micro` commands must be run within a micro BOSH deployment directory**

		% bosh help
		...
		Micro
			micro deployment [<name>] Choose micro deployment to work with
			micro status              Display micro BOSH deployment status
			micro deployments         Show the list of deployments
			micro deploy <stemcell>   Deploy a micro BOSH instance to the currently
                                      selected deployment
                            --update  update existing instance
			micro delete              Delete micro BOSH instance (including
                                      persistent disk)
			micro agent <args>        Send agent messages
			micro apply <spec>        Apply spec


### Configuration ###

For a minimal vSphere configuration example, see: `https://github.com/cloudfoundry/bosh/blob/master/deployer/spec/assets/test-bootstrap-config.yml`. Note that `disk_path` is `BOSH_Deployer` rather than `BOSH_Disks`. A datastore folder other than `BOSH_Disks` is required if your vCenter hosts other Directors. The `disk_path` folder needs to be created manually. Also, your configuration must live inside a `deployments` directory and follow the convention of having a `$name` subdir containing `micro_bosh.yml`, where `$name` is your deployment name.

For example:

		% find deployments -name micro_bosh.yml
		deployments/vcs01/micro_bosh.yml
		deployments/dev32/micro_bosh.yml
		deployments/dev33/micro_bosh.yml

Deployment state is persisted to `deployments/bosh-deployments.yml`.

### vCenter Configuration ###

The Virtual Center configuration section looks like the following.

		cloud:
		  plugin: vsphere
		  properties:
		    agent:
		      ntp:
		        - <ntp_host_1>
		        - <ntp_host_2>
		     vcenters:
		       - host: <vcenter_ip>
		         user: <vcenter_userid>
		         password: <vcenter_password>
		         datacenters:
		           - name: <datacenter_name>
		             vm_folder: <vm_folder_name>
		             template_folder: <template_folder_name>
		             disk_path: <subdir_to_store_disks>
		             datastore_pattern: <data_store_pattern>
		             persistent_datastore_pattern: <persistent_datastore_pattern>
		             allow_mixed_datastores: <true_if_persistent_datastores_and_datastore_patterns_are_the_same>
		             clusters:
		             - <cluster_name>:
		                 resource_pool: <resource_pool_name>

If you want to create a role for the bosh user in vCenter, the privileges are defined [here] (https://github.com/rajdeepd/bosh-oss-docs/blob/master/bosh/documentation/vcenter_user_privileges.md).


Before you can run micro BOSH deployer, you have to do the following within Virtual Center:

1. Create the vm_folder

1. Create the template_folder

1. Create the disk_path in the appropriate datastores

1. Create the resource_pool.

Resource pool is optional you can run without a resource pool. Without a resource pool the cluster property looks like:

            		persistent_datastore_pattern: <datastore_pattern>
            		allow_mixed_datastores: <true_if_persistent_datastores_and_datastore_patterns_are_the_same>
            		clusters:
            		- <cluster_name>

The datastore pattern above could just be the name of a datastore or some regular expression matching the datastore name.

If you have a datastore called "vc_data_store_1" and you would like to use this datastore for both persistent and non persistent disks. Your config would look like:

            		datastore_pattern: vc_data_store_1
            		persistent_datastore_pattern:  vc_data_store_1
            		allow_mixed_datastores: true

If you have 2 datastores called "vc_data_store_1", "vc_data_store_2" and you would like to use both datastore for both persistent and non persistent disks. Your config would look like:

            		datastore_pattern: vc_data_store_?
            		persistent_datastore_pattern:  vc_data_store_?
            		allow_mixed_datastores: true

If you have 2 datastores called "vnx:1",  "vnx:2" and you would like to separate your persistent and non persistent disks. Your config would look like

            		datastore_pattern: vnx:1
            		persistent_datastore_pattern: vnx:2
            		allow_mixed_datastores: false

### Deployment ###

1. Download a micro BOSH Stemcell:

		% mkdir -p ~/stemcells
		% cd stemcells
		% bosh public stemcells
		+---------------------------------------+--------------------------------------------------+
		| Name                                  | Tags                                             |
		+---------------------------------------+--------------------------------------------------+
		| bosh-stemcell-aws-0.6.4.tgz           | aws, stable                                      |
		| bosh-stemcell-vsphere-0.6.4.tgz       | vsphere, stable                                  |
		| bosh-stemcell-vsphere-0.6.7.tgz       | vsphere, stable                                  | 
		| micro-bosh-stemcell-aws-0.6.4.tgz     | aws, micro, stable                               |
		| micro-bosh-stemcell-vsphere-0.6.4.tgz | vsphere, micro, stable                           |
		+---------------------------------------+--------------------------------------------------+
		To download use 'bosh download public stemcell <stemcell_name>'.
		% bosh download public stemcell micro-bosh-stemcell-0.6.4.tgz


1. Set the micro BOSH Deployment using:

		% cd /var/vcap/deployments
		% bosh micro deployment dev33
		Deployment set to '/var/vcap/deployments/dev33/micro_bosh.yml'

1. Deploy a new micro BOSH instance.

		% bosh micro deploy ~/stemcells/micro-bosh-stemcell-0.6.4.tgz

1. Update an existing micro BOSH instance. The existing persistent disk will be attached to the new VM.

		% bosh micro deploy ~/stemcells/micro-bosh-stemcell-0.6.4.tgz --update

### Deleting a micro BOSH deployment ###

The `delete` command will delete the VM, Stemcell, and persistent disk.

Example:

		% bosh micro delete

### Checking Status of a micro BOSH deploy ###

The status command will show the persisted state for a given micro BOSH instance.

                Stemcell CID   sc-fba33340-72c9-4bc2-8fea-3a258511a702
                Stemcell name  micro-bosh-stemcell-vsphere-0.6.4
                VM CID         vm-1b15b7e5-af8f-4dba-9212-9e240d662d4f
                Disk CID       1
                Micro BOSH CID bm-05558542-61c0-4a99-802a-1909689c659a
                Deployment     /home/user/cloudfoundry/deployments/micro_bosh/micro_bosh.yml
                Target         http://192.168.9.20:25555 #IP Address of the Director
 

### Listing Deployments ###

The `deployments` command prints a table view of deployments/bosh-deployments.yml.

		% bosh micro deployments

The files in the `deployments` directory need to be saved if you later want to be able to update your micro BOSH instance. They are all text files, so you can commit them to a git repository to make sure they are safe in case your bootstrap VM goes away.

### Applying a specification

The micro-bosh-stemcell includes an embedded `apply_spec.yml`. This command can be used to apply a different spec to an existing instance. The `apply_spec.yml` properties are merged with your Deployment's network.ip and cloud.properties.vcenters properties.

		% bosh micro apply apply_spec.yml

### Sending messages to the micro BOSH agent ###

The CLI can send messages over HTTP to the agent using the `agent` command.

Example:

		% bosh micro agent ping
		"pong"


# Deploying to AWS using BOSH

The BOSH cloud provider interface for AWS allows BOSH to deploy to AWS.

## AWS cloud properties

The cloud properties specific to AWS are

### Resource pools

1. `key_name`

1. `availability_zone`

1. `instance_type`

### Networks

1. `type`

1. `ip`

## Security concern deploying Cloud Foundry to AWS

If you deploy [Cloud Foundry](https://github.com/cloudfoundry/cf-release) to AWS using BOSH, the deployment property `nfs_server.network` needs to be set to `*` (or `10/8`) as we don't have a way to limit the list of IPs belonging to the deployment. To limit access, create and use a security group.

