# Introduction

BOSH is a framework and tool-chain for release engineering, deployment and life cycle management of distributed services, particularly Cloud Foundry. In this manual we describe the architecture, topology, configuration and use of BOSH, as well as the structure and conventions used in packaging and deployment.

BOSH introduces a fairly prescriptive way of managing systems and services. It was originally developed in the context of the Cloud Foundry Application Platform as a Service, but even if this has been the primary consumer, the framework is general purpose and can be used to deploy other distributed services on top of a Cloud Provider Interface (CPI) provided by VMware vSphere, Amazon Web Services, or OpenStack.

# BOSH Components #

## Fig 1. Interaction of BOSH Components

![Figure 1](https://github.com/vmware-ac/doxa/raw/master/bosh/documentation/fig1.png)

## Infrastructure as a Service (IaaS)

The core BOSH engine is abstracted away from any particular Infrastructure as a Service (IaaS), such as VMware vSphere, AWS or OpenStack. IaaS interfaces are implemented as plugins to BOSH. Currently, BOSH supports both VMware vSphere and Amazon Web Services. Virtual Machines (VMs) are created and destroyed through Workers, which are sent instructions from the Director. Those VMs are created based on a **Stemcell** that is uploaded to BOSH's Blobstore through the Command Line Interface (CLI).

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

A Release in BOSH is a packaged bundle of service descriptors (known as Jobs in BOSH), a collection of software bits and configurations. A release contains all the static bits (source or binary) required to have BOSH manage an application or a distributed service. A Release is typically not restricted to any particular environment an as such it can be re-used across clusters handling different stages in a service life cycle, such as development, QA, staging or production. The BOSH CLI manages both the creation of releases and the deployments into specific environment.

## Deployments

While BOSH Stemcells and Releases are static components, we say that they are bound together into a Deployment by what we call a Deployment Manifest. In the Deployment Manifest you declare pools of VMs, which networks they live on, which Jobs (service components) from the Release you want to activate. Job configuration specify life cycle parameters, the number instances of a Job, as well as network and storage requirements. In the Deployment Manifest you can also specify properties at various levels used to paramaterize configuration templates contained in the Release.

Using the BOSH CLI you specify a Deployment Manifest and perform a Deploy operation (+bosh deploy+), which will take this specification and go out to your cluster and either create or update resources in accordance to the specification.

## Blobstore

## BOSH Monitor

## Message bus

# Using BOSH

Before we can use BOSH we need to install the BOSH CLI. Also, make sure that you have a running development environment with an uploaded stemcell. You can learn about those steps in the [BOSH Installation][] section.

## Installing BOSH Command Line Interface ##

The following steps install BOSH CLI on Ubuntu 10.04 LTS. If you do not run Ubuntu, it is recommended that you install it on a a local Virtual Machine.

### Install Ruby via rbenv

1. Bosh is written in Ruby. Let's install Ruby's dependencies

		sudo apt-get install git-core build-essential libsqlite3-dev curl libmysqlclient-dev libxml2-dev libxslt-dev libpq-dev

1. Get the latest version of rbenv

		cd
		git clone git://github.com/sstephenson/rbenv.git .rbenv

1. Add `~/.rbenv/bin` to your `$PATH` for access to the `rbenv` command-line utility

		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile

1. Add rbenv init to your shell to enable shims and autocompletion

		echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

1. Download Ruby 1.9.2

		wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz

1. Unpack and install Ruby

		 tar xvfz ruby-1.9.2-p290.tar.gz
		 cd ruby-1.9.2-p290
		 ./configure --prefix=$HOME/.rbenv/versions/1.9.2-p290
		 make
		 make install

1. Restart your shell so the path changes take effect

		source ~/.bash_profile

1. Set your default Ruby to be version 1.9.2

		rbenv global 1.9.2-p290

### Install Local BOSH and BOSH Releases

1. Sign up for the Cloud Foundry Gerrit server at [http://cloudfoundry-codereview.qa.mozycloud.com/gerrit](http://cloudfoundry-codereview.qa.mozycloud.com/gerrit)

**NOTE: PUBLIC GERRIT IN FINAL DRAFT**

1. Set up your ssh public key (accept all defaults)

		ssh-keygen -t rsa
		
1. Copy your key from `~/.ssh/id_rsa.pub` into your Gerrit account
 
1.Create ~/.gitconfig as follows (Make sure that the email specified is registered with gerrit):
		
		[user]
		name = YOUR_NAME
		email = YOUR_EMAIL
		[alias]
		gerrit-clone = !bash -c 'gerrit-clone $@' -
		
1. Clone gerrit tools using git
		
		git clone git@github.com:vmware-ac/tools.git
		
**NOTE: PUBLIC TOOLS REPO IN FINAL DRAFT**

1. Add gerrit-clone to your path

		echo 'export PATH="$HOME/tools/gerrit/:$PATH"' >> ~/.bash_profile

 1. Restart your shell so the path changes take effect

		source ~/.bash_profile

1. Clone BOSH repositories from Gerrit

		git gerrit-clone ssh://cloudfoundry-codereview.qa.mozycloud.com:29418/release.git
		git gerrit-clone ssh://cloudfoundry-codereview.qa.mozycloud.com:29418/bos.git
		
1. Run some rake tasks to install the BOSH CLI

		cd ~/bosh
		rake bundle_install
		cd cli
		bundle exec rake build
		gem install pkg/bosh_cli-x.x.x.gem

### Deploy to your BOSH Environment

With a fully configured environment, we can begin deploying a Cloud Foundry release to our environment. As listed in the prerequisites, you should already have an environment running, as well as the IP address of the BOSH Director. To set this up, skip to the [BOSH Installation][] section.

### Point BOSH at a Target and Clean your Environment ###

1. Target your director (this IP is an example) **NOTE: EXAMPLE WORKS FOR INTERNAL USE (u: admin / p: admin)**

		bosh target 172.23.128.219:25555 

1. Check the state of your BOSH settings.

		bosh status
		
1. The result of your status will be akin to:

		Target         dev48 (http://172.23.128.219:25555) Ver: 0.3.12 (01169817)
		UUID           4a8a029c-f0ae-49a2-b016-c8f47aa1ac85
		User           admin
		Deployment     not set

1. List any previous deployments (we will remove them in a moment). If this is your first deployment, there will be none listed.
    
		bosh deployments

1. The result of `bosh deployments` should be akin to:

		+-------+
		| Name  |
		+-------+
		| dev48 |
		+-------+

1. Delete the existing deployments (ex: dev48) 

		bosh delete deployment dev48

1. Answer `yes` to the prompt and wait for the deletion to complete

1. List previous releases (we will remove them in a moment). If this is your first deployment, there will be non listed.

		`bosh releases`

1. The result of `bosh releases` should be akin to:

		+---------------+---------------+
		| Name	   		| Versions		|
		+---------------+---------------+
		| cloudfoundry	| 47, 55, 58 	|
		+---------------+---------------+
		
1. Delete the existing releases (ex: cloudfoundry) 

		bosh delete release cloudfoundry

1. Answer `yes` to the prompt and wait for the deletion to complete

### Create a Release ###

1. Change directories into the release directory.

**NOTE: This is not correct yet - Get correct locations and names from Oleg**

		cd ~/release
	
	This directory contains the Cloud Foundry deployment and release files.

1. Reset your environment

		bosh reset release

1. Answer `yes` to the prompt and wait for the environment to be reset

1. Create a release

		bosh create release –force –with-tarball
		
1. Answer `cloudfoundry` to the `release name` prompt

1. Your terminal will display information about the release including the Release Manifest, Packages, Jobs, and tarball location.

1. Open `bosh-sample-release/cloudfoundry.yml` in your favorite text editor and confirm that `name` is `cloudfoundry` and `version` matches the version that was displayed in your terminal (if this is your first release, this will be version 1).

### Deploy the Release ###


1. Upload the cloudfoundry release to your Environment

		bosh upload release dev_releases/cloudfoundry-1.tgz
		
1. Your terminal will display information about the upload, and an upload progress bar will reach 100% after a few minutes.

1. Open `releases/cloudfoundry.yml` and make sure that your networking and IP addresses match the environment that you were given.

1. Deploy the Release

		bosh deploy
		
1. Your deployment will take a few minutes.

1. You may now target the Cloud Foundry deployment using VMC, as described in the Cloud Foundry documentation.

# BOSH Installation #

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
