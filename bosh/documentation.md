## Introduction ##

Cloud Foundry BOSH is an open source tool chain for release engineering, deployment and lifecycle management of large scale distributed services. In this manual we describe the architecture, topology, configuration, and use of BOSH, as well as the structure and conventions used in packaging and deployment.

BOSH was originally developed in the context of the Cloud Foundry Application Platform as a Service, but the framework is general purpose and can be used to deploy other distributed services on top of Infrastructure as a Service (IaaS)products such as VMware vSphere, Amazon Web Services, or OpenStack.

#### [BOSH Components](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_components.md) #####

This document describes the following components in detail and the function they play. 
*    Command Line Interface
*    BOSH Director
*    BOSH Agent
*    BOSH CLI
*    Stemcells
*    Blobstore
*    Health Monitor
*    Message Bus

## Installing Cloud Foundry using BOSH on vSphere##

Following Steps and sections provide more detail on installing Cloud Foundry on vSphere

+    Hardware requirement
+    Installing vSphere and vCenter
+    Install BOSH CLI
+    Install Micro BOSH using BOSH CLI
+    Use Micro BOSH to Install BOSH
+    Deploy Cloud Foundry using BOSH

#### [Hardware Requirement](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/hardware_spec.md) ####
This document lists the minimum hardware requirements for installing BOSH and Cloud Foundry

#### [Installing and Setting up vSphere and vCenter 5.0](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/Install_and_prepare_vsphere.md) ####
This document shows the steps to be followed to prepare vSphere and vCenter for Cloud Foundry deployment.


#### [Installing BOSH CLI](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_cli.md) ####
This document describes in detail installation steps for BOSH Command Line Interface.

#### [Deploying Micro BOSH](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/deploying_micro_bosh.md) ####
This document describes the installation steps for deploying Micro BOSH

####[Deploying BOSH using Micro BOSH](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/deploying_bosh_with_micro_bosh.md) ####
In this section we cover how to use Micro BOSH to deploy BOSH

####[Deploy Cloud Foundry using BOSH](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/deploy_cf_vsphere.md) ####
In this document we describe in detail the steps to install Cloud foundry on vSphere using BOSH

##Reference Documents ##
##### [BOSH CLI Reference] (https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_cli_reference.md) #####
This document provides informations about all the flags of `bosh` command line reference.
##### [BOSH Releases Reference ](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_releases.md) #####
This document describes in details Releases and its sub components : Jobs, Packages and Blobs. It also talks about the configuring and publishing releases.
##### [BOSH Deployments](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_deployments.md) #####
This document describes in more detail
+    Steps of a BOSH Deployment
+    BOSH Deployment file : the yaml file's components
+    BOSH Property Store

##### [BOSH Troubleshooting](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/bosh_troubleshooting.md) #####
This document describes the troubleshooting tips while trying to deploy BOSH.
+    How to ssh into a running job
+    Analyzing the logs : Director, Agent and Services Logs
+    BOSH Cloud Check tool

#####[Deploying to AWS using BOSH](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/deploy_to_aws_using_bosh.md)####
Note : Content in this section is still being built
