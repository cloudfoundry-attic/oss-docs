# BOSH Deployments #

## Steps of a Deployment ##

When you do a deploy using BOSH the following sequence of steps occur:

1. Preparing deployment
    * binding deployment - Creates an entry in the Director's database for the deployment if it doesn't exist.
    * binding release - Makes sure the release specified in deployment configuration exists then locks it from being deleted.
    * binding existing deployment - Takes existing VMS and sets them up to be used for the deployment.
    * binding resource pools - Gives idle VMs network reservations.
    * binding stemcells - Makes sure the stemcell specified has been uploaded and then locks it from being deleted.
    * binding templates - Sets up internal data objects to track packages and their pre-reqs for installation.
    * binding unallocated VMs - For each job instance required it determines whether a VM running the instance already exists and assigns one if not.
    * binding instance networks - Reserves networks for each VM that doesn't have one.
1. Compiling packages - Calculates all packages and their dependencies that need to be compiled.  It then begins compiling the packages and storing their output in the blobstore.  The number of `workers` specified in the deployment configuration determines how many VMs can be created at once for compiling.
1. Preparing DNS - Creates DNS entry if it doesn't exist.
1. Creating bound missing VMs - Creates new VMs, deletes extra/oudated/idle VMs.
1. Binding instance VMs - Any unbound VMs are setup for the deployment.
1. Preparing configuration - Pulls in the configurations for each job to be run.
1. Updating/deleting jobs - Deletes unneeded instances, creates needed instances, updates existing instances if they are not already updated.  This is the step where things get pushed live.
1. Refilling resource pools - Creates missing VMs across resource pools after all instance updaters are finished to create additional VMs in order to balance resource pools.

## BOSH Deployment Manifest

The BOSH Deployment manifest is a YAML file defining the layout and properties of the deployment. When BOSH user initiates a new deployment using CLI, BOSH Director receives a version of deployment manifest and creates a new deployment plan using this manifest (see [Steps of a Deployment](#steps-of-a-deployment)). Manifest contains several sections:

* `name` [String, required] Deployment name. Single BOSH Director can manage multiple deployments and distinguishes them by name.
* `director_uuid` [String, required] Director UUID. Identifies BOSH Director that manages given deployment. A targeted Director UUID should match this property in order for BOSH CLI to allow any operations on the deployment.
* `release` [Hash, required] Release properties.
	* `name` [String, required] Release name. References a release name that wiill be used to resolve the components of the deployment (packages, jobs).
	* `version` [String, required] Release version. Points to the exact release version to use.
* `compilation` [Hash, required] Package compilation properties.
	* `workers` [Integer, required] How many compilation VMs will be created to compile packages.
	* `reuse_compilation_vms` [Boolean, optional] If set to true, compilation VMs will be re-used when compiling packages. If false, every time new package needs to be compiled (as a part of current deployment), a new worker VM will be created (up to a number of compilation workers) and it will be shut down after single package compilation is finished. Defaults to false. Recommended to set to true if IaaS takes a long time to create/delete VMs or to optimize package compilation cost (as compilation VMs are usually short-lived and some IaaS billing round up usage time to the hour).
	* `network` [String, required] Network name, references a valid network name defined in `networks` section. Compilation VMs will be assigned all their network properties according to the type and other properties of that network.
	* `cloud_properties` [Hash, required] Any IaaS-specific properties that will be used to create compilation VMs.
* `update` [Hash, required] Instance update properties. These control how job instances will be updated during the deployment.
	* `canaries` [Integer, required] Number of canary instances. Canary instances are being updated before other instances and any update error for canary instance means the deployment should stop. This prevents a buggy package or job from taking over all job instances, as only canaries will be affected by a problematic code. After canaries are done, other instances of this job will be updated in parallel (respecting `max_in_flight` setting).
	* `canary_watch_time` [Range<Integer>, Integer] How long to wait for canary update to declare job healthy or unhealthy. If Integer is given, director will sleep for that many seconds and check if job is healthy. If Range `lo..hi` is given it will wait for `lo` ms, see if job is healthy, and if it's not it will sleep some more, all up until `hi` ms have passed. If job is still unhealthy it will give up.
	* `update_watch_time` [Range<Integer> Integer]: Semantically no different from `canary_watch_time`, used for regular (non-canary) updates.
	* `max_in_flight` [Integer, required] Maximum number of non-canary instance updates that can happen in parallel.
* `networks` [Hash<Array>, required] Describes the networks used by deployment. See [nework_spec] for details.
* `resource_pools` [Hash<Array>, required] Describes resource pools used by deployment. See [resource_pool_spec] for details.
* `jobs` [Hash<Array>, required] Lists jobs included in into this deployment. See [job_spec] for details.
* `properties` [Hash, required] Global deployment properties. See [job_cloud_properties] for details.

### Network spec ###

Network spec specifies a network configuration that can be referenced by jobs. Different environments have very different networking capabilities, so there are several network types. Each type has a required `name` property that identifies the network within BOSH and has to be unique.

The more details network type description follows:

1. `dynamic` The network is not managed by Bosh. VMs using this network are expected to get their IP addresses and other network configuration from DHCP server or some other way, BOSH will trust each VM to report its current IP address as a part of its `get_state` response. The only extra property this network supports is `cloud_properties`, containing any IaaS-specific network details for CPI.
2. `manual` The network is completely managed by BOSH. Ranges are provided for dynamic, static and reserved IP pools, DNS servers. Manually managed networks can be further divided into subnets. When using this type of network BOSH takes care of assigning IP addresses, making network-related sanity checks and telling VMs which network configuration they are meant to use. This type of network has only one extra property `subnets`, an array of Hashes, where each hash is a subnet spec, containing the following properties):
	* `range` [String, required] Subnet IP range (as defined by Ruby NetAddr::CIDR.create semantics) that includes all IPs from this subnet.
	* `gateway` [String, optional] Subnet gateway IP.
	* `dns` [Array<String>, optional] DNS IP addresses for this subnet.
	* `cloud_properties` opaque IaaS-specific details passed on to CPI.
	* `reserved` [String, optional] Reserved IP range. IPs from that range will never be assigned to BOSH-managed VMs, these are supposed to be managed outside of BOSH completely.
	* `static` [String, optional] Static IP range. When jobs request static IPs, they all should be coming from some subnet static IP pool.
3. `vip` The network is just a collection of virtual IPs (e.g. EC2 elastic IPs) and each job spec will provide a range of IPs it supposed to have. Actual VMs are not aware of these IPs. The only extra property this network supports is `cloud_properties`, containing any IaaS-specific network details for CPI.

### Resource pool spec ###

Resource pool spec is essentially a blueprint for VMs created and managed by BOSH. There might be multiple resource pools within a deployment manifest, `name` is used to identify and reference them, so it needs to be unique. Resource pool VMs are created within a deployment and later jobs are applied to these VMs. Jobs might override some of the resource pool settings (i.e. networks) but in general resource pools are a good vehicle to partition jobs according to capacity and IaaS configuration needs. The resource pool spec properties are:

* `name`[String, required] Unique resource pool name.
* `network` [String, required] References a network name (see [network_spec] for details). Idle resource pool VMs will use this network configuration. Later, when the job is being applied to these resource pool VMs, networks might be reconfigured to meet job's needs.
* `size` [Integer, required] Number of VMs in the resource pool. Resource pool should be at least as big as the total number of job instances using it. There might be extra VMs as well, these will be idle until more jobs are added to fill them in.
* `stemcell` [Hash, required] Stemcell used to run resource pool VMs.
	* `name` [String, required] Stemcell name.
	* `version` [String, required] Stemcell version.
* `cloud_properties` [Hash, required] IaaS-specific resource pool properties (see [job_cloud_properties]).
* `env` [Hash, optional] VM environment. Used to provide specific VM environment to CPI `create_stemcell` call. This data will be available to BOSH Agent as VM settings. Default is {} (empty Hash).

### Job spec ###

Job is one or more VMs (called instances) running the same software and essentially representing some role. Job uses job template, which is a part of a release, to populate VM with packages, configuration files and control scripts that tell BOSH Agent what is to run on a particular VM. The most commonly used job properties are:

* `name` [String, required] Unique job name.
* `template` [String, required] Job template. Job templates are a part of a release and usually contained (in the raw form ) in release 'jobs' directory in release repo and get uploaded to BOSH Director as a part of a release bundle.
* `persistent_disk` [Integer, optional] Persistent disk size. If it's a positive integer, persistent disk will be created and attached to each job instance VM. Defaults to 0 (no persistent disk).
* `properties` [Hash, optional] Job properties. See [job_cloud_properties] for details.
* `resource_pool` [String, required] Resource pool to run job instances. References a valid resource pool name in `resource_pool` section.
* `update` [Hash, optional] Job-specific update settings. This allows overriding global job update settings on a per-job settings (similar to `properties`).
* `instances` [Integer, required] Number of job instances. Each instance is a VM running this particular job.
* `networks` [Array<Hash>] Networks required by this job. For each network the following properties can be specified:
	* `name` [String, required] Specifies network name in `networks` section.
	* `static_ips` [Range, optional] Specifies the range of IP addresses job supposed to reserve from that network.
	* `default` [Array, optional] Specifies which of default network components (dns, gateway) are populated from this network (this only makes sense if there are multiple networks).

### Job properties and cloud properties ###

There are two kinds of properties that can be featured in the deployment manifest.

1. cloud_properties: an opaque Hash that is being passed (usually "as-is") to CPI. Usually it controls some IaaS-specific properties (such as VM configuration parameters, network VLAN names etc). CPI is up to validate if these properties are correct.
2. job properties. Almost any non-trivial job needs some properties filled in, so it can understand how to talk to other jobs and what non-default settings to use. BOSH allows to list global deployment properties in a properties section of the deployment manifest. All this properties are recursively converted by director from Hash to a Ruby OpenStruct object, so they can be accessed by using original Hash key names as method names. The resulting OpenStruct is exposed under `properties` name and can be addressed in any job configuration template (using ERB syntax). Here's an example of de
fining and using a property:

File `deployment_manifest.yml`

	…
	properties:
	  foo:
	    bar:
	      baz

File	`jobs/foobar_manager/templates/config.yml.erb`

	---
	bar_value: <%= properties.foo.bar %>

Global properties are available to any job. In addition every job can define it's own `properties` section, these properties are only accessible within configuration templates of that job. Local job properties are being recursively merged into global job properties, so accessing them requires exactly the same syntax. Note that this can also be used to override global properties on per-job basis.

### Instance spec ###

Instance spec is a special object accessible to any job configuration file, similar to `properties` (actually `properties` is just a shortcut for `spec.properties`, so they are just a small part of spec). It contains a number of properties that can be used by job creator to access the details of a particular job instance environment and potentially make runtime-based decisions at the time of creating a job.

Two important parts of the instance spec are `job` and `index`. `job` contains job name and `index` contains 0-based instance index. This index is important if you want to only perform some actions (i.e. database migrations) on a particular job instance or want to test a new feature only on several instances but not all of them. Other things available through this spec are `networks` and  `resource_pool` which might be useful to get some data about job whereabouts.

## BOSH Property Store ##

Deployment manifest is a YAML file but it gets processed by ERB before being actually used, thus it might contain ERB expressions. This allows BOSH Director to substitute some properties saved in its database, so that sensitive or volatile data is only set at the time of deployment but not by manifest author at the time of creating the actual manifest.

BOSH CLI has several commands allowing property management:

	set property <name> <value>
	get property <name>
	unset property <name>
	properties

You can set the property using `bosh set property <name> <value>` and then reference it in the deployment manifest using `<%= property(name) %>` syntax.

