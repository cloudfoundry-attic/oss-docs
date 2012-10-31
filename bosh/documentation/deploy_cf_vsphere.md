
# Deploy Cloud Application Platform - Cloud Foundry #

By now the deployment steps should seem somewhat familiar. We'll target our new BOSH Director (deployed when we used Micro BOSH to deploy BOSH,) upload a public BOSH stemcell, upload a cloud foundry appcloud release, configure and set a cloud application platform deployment manifest, and run: `bosh deploy`
 
## Target New BOSH Director ##

You'll need to target your new BOSH Director. Find out its IP address by running:

+ `bosh vms`

The first time you target the Director, you'll be asked to provide login credentials. These were specified in your BOSH [deployment manifest](./examples/bosh_manifest.yml).

+ `bosh target 10.1.4.225:25555 # Note the default port setting`


## Upload Stemcell ##

Your new Director needs a stemcell in order to deploy your cloud application platform. The steps should seem familiar now. Use your existing public stemcell in the `~/stemcells` directory. Do not use your Micro BOSH stemcell in this case.

+ `bosh upload stemcell ~/stemcells/bosh-stemcell-0.5.2.tgz`

## Get Cloud Release ##

For this exercise, we'll use a Release from the public repository:

+ `gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/cf-release.git`

To upload the release to your Director, you'll need to be in a special 'release' directory once more in order to run the command successfully.

1. ` cd cf-release`

1. `bosh upload release releases/appcloud-82.yml`

You'll see a flurry of output as BOSH configures and uploads release components. 

## Create Cloud Deployment Manifest ##

For the purpose of this tutorial, we'll use a sample [deployment manifest](./examples/dev124.yml)

Keep in mind that a manifest of this size requires significant virtual hardware resources to run. According to the manifest file, you ideally need 72 vCPUs, 200GB of RAM, and 1 TB of storage. The more IOPS you can throw at the deployment, the better.

Use the BOSH CLI to set your current deployment. If you placed your deployment manifest yml in ~/deployments/dev124, run the following command: 

+ `bosh deployment ~/deployments/dev124/dev124.yml`


## Deploy ##

Let's summarize what we accomplished in this section -- we mirrored the steps we used to deploy BOSH. We targeted our new BOSH Director (running as part of a distributed BOSH,) uploaded a stemcell to the Director, uploaded a public cloud application platform release to the Director, configured a deployment manifest, and set the deployment manifest as the current deployment using the BOSH CLI. 

Now you get to watch your vCenter light up with tasks:

+ `bosh deploy`

If you'd like to learn more about what happens during the deployment process, read the official documentation's [explanation of a deployment](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/documentation.md#bosh-deployments).


# Verification #

You watched your vCenter hard at work and followed the deployment logs, and now the job has finished. How do you verify that your platform is indeed functional?

At this point, you've crossed over from `bosh` territory to `vmc`. The `vmc` tool will allow you to push a sample app to your cloud application platform instance and test its functionality.

## Install VMC ##

VMC is the command line tool that will allow you to interact with your cloud application platform. You should be able to run VMC from any other machine that will allow you to install Ruby gems.  

1. Follow the [directions listed here](http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html#installing-vmc-procedure) to install VMC.

## Build Sample App ##

1. Install the Sinatra web framework for Ruby: `gem install sinatra`

1. Write a [sample Sinatra application](http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html#creating-a-simple-sinatra-application) 

## Deploy Sample App ##

*Note* There is one step you will need to add to the instructions listed below. You will need to add a user through vmc after running the `vmc target` command. 

To add a user, run `vmc add-user` and follow the on-screen prompts to create a user.

1. Follow [these instructions](http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html#verifying-the-installation-by-deploying-a-sample-application) to push the sample Sinatra app to your cloud application platform


1. Visit the URL of your application, as provided during the `vmc push` operation, to verify that it works.

*Hint: In the case where you get JSON 404 errors when you try to use vmc to target your api, the best course of action is to use `bosh ssh` to connect to your router VM. The file `router.log` will likely show you if the router bound itself to a different IP address. This is indicative of possible configuration errors in your deployment manifest and/or problems with your external DNS configuration. More [here](https://github.com/cloudfoundry/vcap/issues/37).*

*What is the URL for the target? This is specified in the deployment manifest under the cc: component. It is given as the srv_api_uri: property.

*Where do you specify 'yourdomain.com' in the deployment? In the deployment manifest, there is a `domain: ` property. Put your domain here.

*Do you need DNS configured for your CF instance? Yes. The easiest way to set this up is with a wildcard DNS entry that points to your domain. The router component of CF will take care of routing requests to the correct apps.


# Summary #

In this document, we installed the BOSH CLI, deployed a Micro BOSH instance, used Micro BOSH to deploy BOSH (inception,) and used BOSH to deploy a cloud application platform. 

For a deeper dive into BOSH, check out the [official docs](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/documentation.md#bosh-deployments) on Github. 

There are also Google Groups for both [bosh-dev](https://groups.google.com/a/cloudfoundry.org/group/bosh-dev/topics?lnk) and [bosh-users](https://groups.google.com/a/cloudfoundry.org/group/bosh-users/topics)

