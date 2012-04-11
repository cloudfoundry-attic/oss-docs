# Cloud Foundry BOSH FAQ

## What is Cloud Foundry BOSH?
Cloud Foundry BOSH is an open source tool chain for release engineering, deployment and lifecycle management of large scale distributed services.

## What functions does BOSH perform?
Designed to enable the systematic and prescriptive evolution of services, BOSH facilitates the operation of production instances of Cloud Foundry. BOSH automates a variety of cloud infrastructure and allows targeted service updates with consistent results and minimal to no down time.

## Who is BOSH for?
BOSH is primarily designed for staff operating large scale production deployments of Cloud Foundry. While not required to run Cloud Foundry, BOSH is recommended for large scale Cloud Foundry instances.

## Does CloudFoundry.com use BOSH?
Yes, BOSH has been used since the launch of CloudFoundry.com to create and update the production service as well as the dozens of development, test and staging clouds that comprise CloudFoundry.com. BOSH has been used for thousands of deployments of Cloud Foundry.
 
## How is BOSH licensed?
BOSH is open source software and is released under the Apache 2 License.  

## Why did VMware open source BOSH?
VMware open sourced BOSH to enable providers to operate even larger scale and higher quality instances of Cloud Foundry.

## What cloud infrastructure does BOSH support?
BOSH includes a Cloud Provider Interface (CPI), an abstraction layer that can target a variety of cloud infrastructure. Currently there is a production class implementation for VMware vSphere. Support for Amazon Web Services is also available and is a work in progress. VMware is working on vCloud Director support for delivery later in 2012. VMware encourages implementations via open source for other cloud infrastructure (e.g. CloudStack, Eucalyptus, OpenStack).

## Where can I download and learn about BOSH?
BOSH documentation and software can be found at http://cloudfoundry.org/
 
## What does BOSH stand for?
BOSH is a recursive acronym for “BOSH Outer Shell”.
 
## Should I use BOSH for my production deployment of Cloud Foundry?
For large scale and production deployments of Cloud Foundry we recommend using BOSH.

## How does BOSH relate to chef, puppet and configuration management tools?
Chef and Puppet are primarily configuration management tools. BOSH provides the connective tissue between configurations, continuous deployments, package updates, monitoring, virtual machine management, and the overall requirements of a large distributed system. BOSH includes a handful of components, including an open configuration management layer which could leverage chef, puppet, or other solutions.