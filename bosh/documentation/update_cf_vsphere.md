# Update Cloud Foundry Deployment Using Bosh #

This document helps you to update the Cloud Foundry Deployment with a new release. We will upload a new Cloud Foundry release, configure the deployment manifest, and run: `bosh deploy`

Note: Target should be set to BOSH Director (which was set while deploying Cloud Foundry). You can check it by running following command:
+ `bosh status`

Output of the above command is similar to listing below:

          $ bosh status
            Updating director data... done

            Director
            Name      dev124
            URL       http://192.168.9.24:25555 # BOSH Director IP address
            Version   0.6 (release:15efc489 bosh:441aa172)
            User      admin
            UUID      1936f9dc-d9ff-429a-a334-8d8001b0ba21
            CPI       vsphere

            Deployment
             Manifest  /home/rajdeep/cloudfoundry_2/deployments/cf/cloudfoundry.yml


If it is not set to BOSH director then follow the steps on this link to set it to BOSH DIRECTOR:
[Deploy Cloud Application Platform - Cloud Foundry](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/deploy_cf_vsphere.md)

## Get Latest Cloud Release ##

To get the Latest Release, go to the release folder and run 'update' command as follows:

1. `cd cf-release`
2. `./update`

Now upload the new release as follows:

+ `bosh upload release releases/appcloud-119.yml`

You'll see a flurry of output as BOSH configures and uploads release components.

For the purpose of this tutorial, we'll use a sample [deployment manifest](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/tutorial/examples/dev124.yml)

Keep in mind that a manifest of this size requires significant virtual hardware resources to run.

Use the BOSH CLI to set your current deployment. If you placed your deployment manifest yml in `~/cloudfoundry/deployments/cf`, run the following command:

+ `bosh deployment ~/cloudfoundry/deployments/cf/cloudfoundry.yml`

## Deploy ##

Let's summarize what we accomplished in this section.

+ We uploaded the new release to the Director
+ Configured a deployment manifest
+ Set the deployment manifest as the current deployment using the BOSH CLI.

Now execute the deploy command from BOSH CLI:


+ `bosh deploy`

Output of the above command is pretty long and is partially listed below;

        $ bosh deploy
          Getting deployment properties from director...
          Compiling deployment manifest...
          Detecting changes in deployment...

          Release
          changed version:
          - 106
          + 119
          Release version has changed: 106 -> 119
          Are you sure you want to deploy this version? (type 'yes' to continue): yes


If you'd like to learn more about what happens during the deployment process, read the official documentation's [explanation of a deployment](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/documentation/documentation.md#bosh-deployments).


# Verification #

Now we need to verify, that all our VMs and application working fine after the update.

Run the following command to verify that all VMs are running:

+ `bosh vms`

Output of the above command is similar to listing below:

	$ bosh vms
	Deployment `cloudfoundry'

	Director task 30

	Task 30 done

	+-----------------------------+---------+----------------+---------------+
	| Job/index                   | State   | Resource Pool  | IPs           |
	+-----------------------------+---------+----------------+---------------+
	| acm/0                       | running | infrastructure | 192.168.9.38  |
	| acmdb/0                     | running | infrastructure | 192.168.9.37  |
	| backup_manager/0            | running | infrastructure | 192.168.9.120 |
	| ccdb_postgres/0             | running | infrastructure | 192.168.9.32  |
	| cloud_controller/0          | running | infrastructure | 192.168.9.213 |
	| cloud_controller/1          | running | infrastructure | 192.168.9.214 |
	| collector/0                 | running | infrastructure | 192.168.9.210 |
	| dashboard/0                 | running | infrastructure | 192.168.9.211 |
	| dea/0                       | running | deas           | 192.168.9.186 |
	| dea/1                       | running | deas           | 192.168.9.187 |
	| dea/2                       | running | deas           | 192.168.9.188 |
	| dea/3                       | running | deas           | 192.168.9.189 |
	| debian_nfs_server/0         | running | infrastructure | 192.168.9.30  |
	| hbase_master/0              | running | infrastructure | 192.168.9.44  |
	| hbase_slave/0               | running | infrastructure | 192.168.9.41  |
	| hbase_slave/1               | running | infrastructure | 192.168.9.42  |
	| hbase_slave/2               | running | infrastructure | 192.168.9.43  |
	| health_manager/0            | running | infrastructure | 192.168.9.163 |
	| login/0                     | running | infrastructure | 192.168.9.162 |
	| mongodb_gateway/0           | running | infrastructure | 192.168.9.222 |
	| mongodb_node/0              | running | infrastructure | 192.168.9.60  |
	| mongodb_node/1              | running | infrastructure | 192.168.9.61  |
	| mysql_gateway/0             | running | infrastructure | 192.168.9.221 |
	| mysql_node/0                | running | infrastructure | 192.168.9.51  |
	| mysql_node/1                | running | infrastructure | 192.168.9.52  |
	| nats/0                      | running | infrastructure | 192.168.9.31  |
	| opentsdb/0                  | running | infrastructure | 192.168.9.34  |
	| postgresql_gateway/0        | running | infrastructure | 192.168.9.192 |
	| postgresql_node/0           | running | infrastructure | 192.168.9.90  |
	| postgresql_node/1           | running | infrastructure | 192.168.9.91  |
	| rabbit_gateway/0            | running | infrastructure | 192.168.9.191 |
	| rabbit_node/0               | running | infrastructure | 192.168.9.80  |
	| rabbit_node/1               | running | infrastructure | 192.168.9.81  |
	| redis_gateway/0             | running | infrastructure | 192.168.9.190 |
	| redis_node/0                | running | infrastructure | 192.168.9.70  |
	| redis_node/1                | running | infrastructure | 192.168.9.71  |
	| router/0                    | running | infrastructure | 192.168.9.101 |
	| router/1                    | running | infrastructure | 192.168.9.102 |
	| serialization_data_server/0 | running | infrastructure | 192.168.9.123 |
	| service_utilities/0         | running | infrastructure | 192.168.9.121 |
	| services_nfs/0              | running | infrastructure | 192.168.9.50  |
	| services_redis/0            | running | infrastructure | 192.168.9.72  |
	| stager/0                    | running | infrastructure | 192.168.9.215 |
	| stager/1                    | running | infrastructure | 192.168.9.216 |
	| syslog_aggregator/0         | running | infrastructure | 192.168.9.33  |
	| uaa/0                       | running | infrastructure | 192.168.9.212 |
	| uaadb/0                     | running | infrastructure | 192.168.9.35  |
	| vblob_gateway/0             | running | infrastructure | 192.168.9.193 |
	| vblob_node/0                | running | infrastructure | 192.168.9.110 |
	| vcap_redis/0                | running | infrastructure | 192.168.9.36  |
	+-----------------------------+---------+----------------+---------------+

	VMs total: 50

+ Also launch the applications and make sure that all are running fine.



