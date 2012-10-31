# BOSH Components #

## Fig 1. Interaction of BOSH Components ##

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

## Releases ##

A Release in BOSH is a packaged bundle of service descriptors known as Jobs. Jobs are collections of software bits and configurations.
Any given Release contains all the static bits (source or binary) required to have BOSH manage an application or a distributed service.

A Release is typically not restricted to any particular environment. As such, it can be re-used across clusters handling different stages in a service life cycle, such as Development, QA, Staging, or Production.
The [BOSH CLI](#bosh-cli) manages both the creation of Releases and their deployments into specific environments.

See the [Packages](#packages) section for a deeper look at both Releases and [Jobs](#jobs).

## Deployments ##

While BOSH [Stemcells](#stemcells) and [Packages](#packages) are static components, they are bound together into a Deployment by a [BOSH Deployment Manifest](#bosh-deployment-manifest).
In the Deployment Manifest, you declare pools of VMs, which networks they live on, and which [Jobs](#jobs) (service components) from the Releases you want to activate.
Job configurations specify life cycle parameters, the number of instances of a Job, and network and storage requirements.
Furthermore, the Deployment Manifest allows you to specify properties used to parameterize configuration templates contained in the Release.

Using the [BOSH CLI](#bosh-cli), you specify a Deployment Manifest and perform a Deploy operation (`bosh deploy`), which creates or updates resources on your cluster according to your specifications.
Refer to the [Steps of a Deployment](#steps-of-a-deployment) for examples.

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