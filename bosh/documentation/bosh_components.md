# BOSH Components #

#### Fig 1. Interaction of BOSH Components ####

![Interaction of BOSH Components](https://github.com/cloudfoundry/oss-docs/raw/master/bosh/documentation/fig1.png)

<!--
\begin{figure}[htbp]
\centering
\includegraphics[keepaspectratio,width=\textwidth,height=0.75\textheight]{fig1.png}
\caption{Interaction of BOSH Components}
\label{}
\end{figure}
-->

## Infrastructure as a Service (IaaS) ##

The core BOSH engine is abstracted from any particular Infrastructure as a Service (IaaS). IaaS interfaces are implemented as plugins to BOSH. Currently, BOSH supports both VMware vSphere and Amazon Web Services.

## Cloud Provider Interface ##

The IaaS interface plugins communicate through a Cloud Provider Interface (CPI) offered by the particular IaaS vendors such as VMware or Amazon. As a BOSH user there is no need to be concerned with the IaaS or CPI, but it can be helpful to understand its primitives when learning how BOSH works. The current examples of these interfaces are in:	`bosh/vsphere_cpi/lib/cloud/vsphere/cloud.rb` for vSphere, and `bosh/aws_cpi/lib/cloud/aws/cloud.rb` for Amazon Web Services. Within those subdirectories are Ruby classes with methods to do the following:

	create_stemcell / delete_stemcell
	create_vm  / delete_vm  / reboot_vm
	configure_networks
	create_disk / delete_disk / attach_disk / detach_disk

Please refer to the [API documentation](https://github.com/cloudfoundry/bosh/blob/master/cpi/lib/cloud.rb) in these files for further explanation of the CPI primitives.

## BOSH Director ##

The Director is the core orchestrating component in BOSH which controls creation of VMs, deployment, and other life cycle events of software and services. Command and control is handed over to the the Director-Agent interaction after the CPI has created resources.

There are specific sub components to manage each of the tasks mentioned above. All these are instances of the following classes referenced from the ApiController.

![director-components](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-components.png)

### Deployment Manager ###
Responsible for creating, updating and deleting the deployments which are specified in the deployment file.

Endpoints and Http Method type exposed by the director which are used to access the deployment manager are described below.

| URL 	| Http Method Type	| Description
| ----------------------------------------------------------------------	| ---------------------------	| ------------------
| /deployments 	| POST	|
| /deployments/:deployment/jobs/:job 	| PUT	| Change the state of a job in a deployment based on the parameter
| /deployments/:deployment/jobs/:job/:index/logs 	| GET	| Get logs of a particular job in a deployment
| /deployments/:name	| DELETE	| Delete a deployment

### Instance Manager ###
Instance Manager helps in managing VM Instances created using Bosh deployments.

Some of the functions it performs are 
1. Helps in connecting to the VM instance using ssh through an Agent Client
2. Finding an instance
3. Fetching log from a particular instance


Figure below describes the flow when a user tries to SSH into a VM using Bosh CLI

![director-instance_manager_1](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-instance_manager_1.png)

### Problem Manager ###
This component helps scan a deployment for problems and helps apply resolutions.
It uses a model deployment_problem to keep info about the problem and has 1: many relationship with Deployment Model.


### Property Manager ###
Properties are attributes specified for  jobs in the deployment file.
Allows you to find properties associated with a deployment, update a particular property for a deployment. References the deployment Manager.


### Resource Manager ###
Used to get access to the resources stored in the BlobStore. Some of the actions performed through a resource manager are

	1. Get a Resource using an Id
	2. Delete a resource by giving an resource Id
	3. Get the resource path from an Id

### Release Manager ###
Manages the creation and deletion of releases. Each release references a Release Manager and contains a Deployment Plan object as well as an array of templates.

Director routes the request coming at the following endpoints to the release manager for managing the release lifecycle

| URL 	| Http Method Type	| Response Body	| Description
| -------------	| ---------------------------	| ---------------------------------------------------------------------------------------------------------------------------	| ------------------------------------------------------
| /releases	|        GET	| {"name"     => release.name,"versions" => versions, "in_use"   => versions_in_use}	| Get the list of all releases uploaded 
| /releases 	|        POST	| 	| Create a release for the user specified.


#### Lifecycle of a Release ####
Figure below shows the interaction between various components of a Director when a release is created/ updated or deleted.

![release-lifecycle](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-release-manager.png)


### Stemcell Manager ###
Stemcell Manager manages the Stem cells. It is responsible for creating, deleting or finding a stemcell.

![director-stemcell-manager](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-stemcell-manager.png)

Table below shows the endpoints exposed by the director for managing the Stemcells lifecycle

|     URL 	| Http Method Type	| Response Body	| Description
| -----------------	| ---------------------------	| ---------------------------------------------------------------------------------------------------------------------------	| -------------------------
| /stemcells	|        GET	| { "name" => stemcell.name, "version" => stemcell.version, "cid"     => stemcell.cid}	| Json specifying the stemcell  name, version and cid of the stem cell.
| /stemcells 	|        POST	| 	| Stemcell binary file
| /stemcells	|       DELETE	| 	| Delete the specified stemcell


### Task Manager ###
Task Manager is responsible for managing the tasks which are created and are being run the Job Runner

![director-task-manager](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-task-manager.png)

Following Http Endpoints are exposed by the Director to get information about a task

|     URL 	| Http Method Type	| Response Body	| Description
| -----------------	| ---------------------------	| -----------------	| -------------------------
| /tasks	|        GET	| 	| Get all the tasks being executed of type"update_deployment", "delete_deployment", "update_release","delete_release", "update_stemcell", "delete_stemcell"
| /tasks/:id	|        GET	| 	| Send back output for a task with the given id
| /tasks/:id/output 	|        GET	| 	| Sends back output of given task id and params[:type]
| /task/:id	|       DELETE	| 	| Delete the task specified by a particular Id
	

### User Manager ###
Manages the users stored in the Director’s database. Main functions performed by the User Manager are

	1. Create a User
	2. Delete a User
	3. Authenticate a User
	4. Get a User
	5. Update a User


User Management is delegated by the director to the User Manager with the following URLs

|     URL 	| Http Method Type	| Http Request Body	| Description
| -----------------	| ---------------------------	| ------------	| -------------------------
| /users	|        POST	| 	| Create a User	
| /users/:username 	|        PUT	| 	| Update a User
| /users/:username	|       DELETE	| 	| Delete a User


### VM State Manager ###
Helps fetch the VM State by creating a task which runs the Hob : VmState 

The vm state is fetched by creating a GET request on the `/deployments/:name/vms` endpoint in the Director. `name` is the name of the deployment.

![director-vm-state-manager](https://raw.github.com/cloudfoundry/oss-docs/master/bosh/documentation/images/director-vm-state-manager.png)

## BOSH Agent ##

BOSH Agents listen for instructions from the BOSH Director. Every VM contains an Agent. Through the Director-Agent interaction, VMs are given [Jobs](#jobs), or roles, within Cloud Foundry.
If the VM's job is to run MySQL, for example, the Director will send instructions to the Agent about which packages must be installed and what the configurations for those packages are.

## BOSH CLI ##

The BOSH Command Line Interface is how users interact with BOSH using a terminal session. BOSH commands follow the format shown below:

    $ bosh [--verbose] [--config|-c <FILE>] [--cache-dir <DIR>]
           [--force] [--no-color] [--skip-director-checks] [--quiet]
           [--non-interactive]

For more details on the options, [install](#installing-bosh-command-line-interface) the [BOSH Command Line Interface](http://rubygems.org/gems/bosh_cli) gem and run the `bosh` command.

## Stemcells ##

A Stemcell is a VM template with an embedded [BOSH Agent](#bosh-agent) The Stemcell used for Cloud Foundry is a standard Ubuntu distribution.
Stemcells are uploaded using the [BOSH CLI](#bosh-cli) and used by the [BOSH Director](#bosh-director) when creating VMs through the [Cloud Provider Interface] (#cloud-provider-interface).
When the Director creates a VM through the CPI, it will pass along configurations for networking and storage, as well as the location and credentials for the [Message Bus](#message-bus) and the [Blobstore](#blobstore).


## Blobstore ##

The BOSH Blobstore is used to store the content of Releases (BOSH [Jobs](#jobs) and [Packages](#packages) in their source form as well as the compiled image of BOSH Packages.
[Releases](#releases) are uploaded by the [BOSH CLI](#bosh-cli) and inserted into the Blobstore by the [BOSH Director](#bosh-director).
When you deploy a Release, BOSH will orchestrate the compilation of packages and store the result in the Blobstore.
When BOSH deploys a BOSH Job to a VM, the BOSH Agent will pull the specified Job and associated BOSH Packages from the Blobstore.

BOSH also uses the Blobstore as an intermediate store for large payloads, such as log files (see BOSH logs) and output from the BOSH Agent that exceeds the max size for messages over the message bus.

There are currently three Blobstores supported in BOSH:

1. [Atmos](http://www.emc.com/storage/atmos/atmos.htm)
1. [S3](http://aws.amazon.com/s3/)
1. [simple blobstore server](https://github.com/cloudfoundry/bosh/tree/master/simple_blobstore_server)

For example configurations of each Blobstore, see the [Blobs](#blobs) section. The default BOSH configuration uses the simple blobstore server, as the load is very light and low latency is preferred.

## Health Monitor ##

The BOSH Health Monitor receives health status and life cycle events from the [BOSH Agent](#bosh-agent) and can send alerts through notification plugins (such as email). The Health Monitor has a simple awareness of events in the system, so as not to alert if a component is updated.

## Message Bus ##

BOSH uses the [NATS](https://github.com/derekcollison/nats) message bus for command and control.