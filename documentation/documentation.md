# Introduction

BOSH is a framework and tool-chain for release engineering, deployment and life cycle management of distributed services, particularly Cloud Foundry. In this manual we describe the architecture, topology, configuration and use of BOSH, as well as the structure and conventions used in packaging and deployment.

BOSH introduces a fairly prescriptive way of managing systems and services. It was originally developed in the context of the Cloud Foundry Application Platform as a Service, but even if this has been the primary consumer, the framework is general purpose and can be used to deploy other distributed services on top of a Cloud Provider Interface (CPI) provided by VMware vSphere, Amazon Web Services, or OpenStack.

# BOSH Components #

## Fig 1. Interaction of BOSH Components

![Figure 1](fig1.pdf)

## Infrastructure as a Service (IaaS)

The core BOSH engine is abstracted away from any particular Infrastructure as a Service (IaaS), such as VMware vSphere, AWS or OpenStack. The interface to these is implemented as plugins to BOSH. Currently, BOSH supports both VMware vSphere and Amazon Web Services. Virtual Machines (VMs) are created and destroyed through workers, which are sent instructions from the Director. Those VMs are created based on a **Stemcell** that is uploaded to BOSH's Blobstore through the Command Line Interface (CLI).

## Cloud Provider Interface (CPI)

As a user of BOSH you're not directly exposed to the the BOSH Cloud Provider Interface, but it can be helpful to understand it's primitives when learning how BOSH works. The current examples of these interfaces are in:	`bosh/vsphere_cpi/lib/cloud/vsphere/cloud.rb` for vSphere, and `bosh/aws_cpi/lib/cloud/aws/cloud.rb` for Amazon Web Services. Within those subdirectories are Ruby classes with methods to do the following: 

* create_stemcell
* delete_stemcell
* create_vm
* delete_vm
* reboot_vm
* configure_networks
* create_disk
* delete_disk
* attach_disk
* detach_disk

In addition to these methods are others specific to each cloud interface. For example, the Amazon Web Services interface includes methods for elastic block storage, which are unnecessary on vSphere. Please refer to the API documentation in the files listed above for a detailed explanation of the CPI primitives.

The CPI is used primarily to do low level creation and management of resources in an IaaS, once a resource is up and running,command and control is handed over to the higher level BOSH Director-Agent interaction.

## BOSH Director

The Director is the core orchestrating component in BOSH which controls creation of VMs, deployment and other life cycle events of software and services.

## BOSH CLI

The BOSH Command Line Interface is the mechansim for users to interact with BOSH using a terminal session. BOSH commands follow the format shown below:

	$bosh [--verbose] [--config|-c <FILE>] [--cache-dir <DIR>]
            [--force] [--no-color] [--skip-director-checks] [--quiet]
            [--non-interactive]

A full overview of BOSH commands and installation appears in the [BOSH CLI][bosh_cli] and [BOSH installation][bosh_install] sections.

## Stemcells

A BOSH stemcell is a VM template with an embedded BOSH Agent. The stemcell used for Cloud Foundry is a standard Ubuntu distribution, and only the .These are uploaded using the BOSH CLI and used by the Director when creating VMs through the CPI. When the Director create a VM through the CPI, it will pass along configurations for networking and storage as well as the location and credentials for the BOSH Message Bus and the BOSH Blobstore.

## Releases

A Release in BOSH is a packaged bundle of service descriptors (known as Jobs in BOSH), a collection of software bits and configurations. A release contains all the static bits (source or binary) required to have BOSH manage an application or a distributed service. A Release is typcially not restricted to any particular environment an as such it can be re-used across clusters handling different stages in a service life cycle, such as development, QA, staging or production. The BOSH CLI manages both the creation of releases and the deployments into specific environment.

## Deployments

While BOSH Stemcells and Releases are static compnents, we say that they are bound together into a Deployment by what we call a Deployment Manifest. In the Deployment Manifest you declare pools of VMs, which networks they live on, which Jobs (service componens) from the Release you want to activate. Job configuration specify life cycle parameters, the number instances of a Job, as well as network and storage requirements. In the Deployment Manifest you can also speficy properties at various levels used to paramaterize configuration templates contained in the Release.

Using the BOSH CLI you specify a Deployment Manifest and perform a Deploy operation (+bosh deploy+), which will take this specification and go out to your cluster and either create or update resources in accordance to the specification.

## Blobstore

## BOSH Monitor

## Message bus

# Using BOSH

# Installation[bosh_install]

TODO: replace this with gem install of cli gem
TODO: remove this section when we don't need chef_deployer anymore

BOSH is a Ruby based toolchain and we suggest that you are set up with
the following

-  rbenv available at [https://github.com/sstephenson/rbenv](https://github.com/sstephenson/rbenv)
-  Ruby 1.9.2

# Configure BOSH Director

[NOTE]
The current +chef-solo+ based installer is being re-written as a
mini-bosh instance.

To install BOSH into an infrastructure we currently assume that the
target VMs have been created.

TODO: check if we can provide vm_builder instructions for creating and
//uploading these to IaaS.

		~/projects/deployments/mycloud/cloud
		  assets/
		    director/
		      director.yml.erb       	 <1>
		      chef.rb                    <2>
		      config.yml                 <3>

	cd ~/projects/bosh/chef_deployer
	rake install

	cd ~/projects/bosh/release
	chef_deployer deploy ~/projects/deployments/mycloud/cloud

# BOSH CLI [bosh_cli]

Go Oleg

# Some section that has stemcells + releases / Director interaction

upload

# Releases

## Release Repository

A BOSH release is built from a directory tree following a structure
described in this section:

## Jobs
TODO: job templates
TODO: use of properties
TODO: "the job of a vm"
TODO: monitrc (gonit)
TODO: DNS support

## Packages
TODO: ishisness!
TODO: compilation
TOOD: dependencies
TODO: package specs

## Sources
 final release

## Blobs
 TODO: configuration options for Blobstore (Atmos vs S3)

## Versioning schemes

## Configuring Releases

## Building Releases

## Final Releases


# BOSH Deployments

TODO: capture all the steps that the deployment does

## BOSH Property Store

## BOSH Deployment Manifest
TODO: options global/job propertes
TODO: cloud_properties for the cli

# BOSH Troubleshooting
TODO: cloud check
TODO: BOSH SSH
TODO: logs
