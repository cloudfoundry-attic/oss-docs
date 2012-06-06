# Single and Multi Node VCAP Deployments using dev_setup


_Author: **Mahesh Patil**_

## Background

Cloud Foundry is made up of a number of system components (Cloud Controller,
Health Manager, DEA, Router, etc.). These components can run co-located in a
single VM/single OS or can be spread across several machines/VMs.

For development purposes, the preferred environment is to run all of the core
components within a single VM and then interact with the system from outside of
the VM via an ssh tunnel. The pre-defined domain `*.vcap.me` maps to local host,
so when you use this setup, the end result is that your development environment
is available at [http://api.vcap.me](http://api.vcap.me).

For large scale or multi-VM deployments, the system is flexible enough to allow
you to place system components on multiple VMs, run multiple nodes of a given
type (e.g., 8 Routers, 4 Cloud Controllers, etc.)

In the [github.com/cloudfoundry/vcap](http://github.com/cloudfoundry/vcap) repository, we have published a VCAP installation scheme called _dev_setup_ which uses [Chef](https://github.com/opscode/chef). Please review the contents of the [dev_setup](https://github.com/cloudfoundry/vcap/tree/master/dev_setup) directory. You can use this scheme to do a single-node or multi-node VCAP install. This document walks through a single node and a multi node installation using the dev_setup scripts.

Versions of these instructions have been used for production deployments, and
for our own development purposes. Many of us develop on mac laptops, so some
additional instructions for this environment have been included.

## Disclaimer

These scripts are tested with and assume a pristine Ubuntu 10.04 64-bit install. Other Ubuntu releases, Linux distributions, and operating systems have not been verified with this installation method and are unlikely to work.

## Prerequisites: Pristine VM with SSH

* setup a VM with a pristine Ubuntu 10.04 server 64-bit image,
  [download here](http://www.ubuntu.com/download/ubuntu/download)
* setup your VM with 1G or more of memory
* you may wish to snapshot your VM now in case things go pear shaped
* to enable remote access (more fun than using the console), install ssh.

Install ssh:

    sudo apt-get install openssh-server

# Single Node Deployment

This section will guide you through installation and verification of a single node Cloud Foundry (VCAP) deployment. This is the quickest way to get up and running with a VCAP environment suitable for development and testing.

## Single Node Installation

1. Run the setup script.
	
	It'll ask for your sudo password at the beginning and towards the end. The entire process takes about half an hour, so just keep a loose eye on it.

		sudo apt-get install curl
		bash < <(curl -s -k -B https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup)

	At the end of the script execution, you should messages similar to:
    
	    ---------------  
	    Deployment info  
	    ---------------  
	    Status: successful  
	    Config files: /home/cfsupp/cloudfoundry/.deployments/devbox/config  
	    Deployment name: devbox  
	    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev start
	
	If the installation stops due to an error, please be sure to review the **Known Issues** section at the end of this document.
	
2. Start the system

		~/cloudfoundry/vcap/dev_setup/bin/vcap_dev start

3. *Optional, mac/linux users only*, create a local ssh tunnel.

	From your VM, run `ifconfig` and note your eth0 IP address, which will look something like: `192.168.252.130`

	Now go to your mac terminal window and verify that you can connect with SSH:

	    ssh <your VM user>@<VM IP address>

	If this works, log out create a local port 80 tunnel:

	    sudo ssh -L <local-port>:<VM IP address>:80 <your VM user>@<VM IP address> -N

	If you are not already running a local web server, use port 80 as your local port,
	otherwise you may want to use 8080 or another common http port.

	Once you do this, from both your mac, and from within the vm, `api.vcap.me` and `*.vcap.me`
	will map to localhost which will map to your running Cloud Foundry instance.
	
## Trying Your Setup

1. Validate that you can connect and tests pass.

	From the console of your vm, or from your mac (thanks to local tunnel):

    	vmc target api.vcap.me
		vmc info
	
	Note: If you are using a tunnel and selected a local port other than 80 you
	will need to modify the target to include it here, like `api.vcap.me:8080`.

2. This should produce roughly the following:

    	VMware's Cloud Application Platform
    	For support visit http://support.cloudfoundry.com

    	Target:   http://api.vcap.me (v0.999)
		Client:   v0.3.10

3. Play around as a user, start with:

		vmc register --email foo@bar.com --passwd password
		vmc login --email foo@bar.com --passwd password

4. To see what else you can do try:
		
		vmc help
	
## Testing Your Setup

1. Once the system is installed, you can run the following Basic System
	Validation Tests (BVTs) to ensure that major functionality is working. BVTs
	require additional dependencies of Maven and the JDK, which can be installed with:

		sudo apt-get install default-jdk maven2

	Now that you have the necessary dependencies, you can run the BVTs:

    	cd cloudfoundry/vcap
		cd tests && bundle package; bundle install && cd ..
		rake tests

2. Unit tests can also be run using the following:

		cd cloud_controller
		rake spec
		cd ../dea
		rake spec
		cd ../router
		rake spec
		cd ../health_manager
		rake spec
	
### You are done, make sure you can run a simple hello world app:

1. Create an empty directory for your test app (lets call it env), and enter it.

		mkdir env && cd env

2. Cut and paste the following app into a ruby file (lets say env.rb):

		require 'rubygems'
		require 'sinatra'
		require 'json/pure'

		get '/' do
		  host = ENV['VMC_APP_HOST']
		  port = ENV['VMC_APP_PORT']
		  "<h1>XXXXX Hello from the Cloud! via: #{host}:#{port}</h1>"
		end

		get '/env' do
		  res = "<html><body style=\"margin:0px auto; width:80%; font-family:monospace\">" 
		  res << "<head><title>CloudFoundry Environment</title></head>"
		  res << "<h3>CloudFoundry Environment</h3>"
		  res << "<div><table>"
		  ENV.keys.sort.each do |key|
		    value = begin
		              "<pre>" + JSON.pretty_generate(JSON.parse(ENV[key])) + "</pre>"
		            rescue
		              ENV[key]
		            end
		    res << "<tr><td><strong>#{key}</strong></td><td>#{value}</tr>"
		  end
		  res << "</table></div></body></html>"
		end


3. Create and push 4 instances of the test app:
		
		vmc push env --instances 4 --mem 64M --url env.vcap.me -n

4. Test it in the browser:

	[http://env.vcap.me](http://env.vcap.me)

	Note that hitting refresh will show a different port in each refresh, reflecting the four different active instances.

5. Check the status of your app by running:

		vmc apps

	Which should yield the following output:

		+-------------+----+---------+-------------+----------+
		| Application | #  | Health  | URLS        | Services |
		+-------------+----+---------+-------------+----------+
		| env         | 1  | RUNNING | env.vcap.me |          |
		+-------------+----+---------+-------------+----------+

# Multi Node Deployment

This section will provide some background information on the _dev_setup_ scripts for VCAP installation, and then guide you through deployment of a 4-node VCAP environment consisting of 2 MySQL Nodes, 1 DEA Node, and the last node containing the rest of the VCAP components.

## Prior to Installation

### Prerequisites
1. Please review the vcap_dev_setup
[README](https://github.com/cloudfoundry/vcap/tree/master/dev_setup#readme)

2. Clone VCAP repository
    
    	$ git clone https://github.com/cloudfoundry/vcap.git

3. Tar up dev_setup directory

    	$ cd vcap
    	$ tar czvf dev_setup.tar.gz dev_setup

4. Copy over dev_setup.tar.gz file to the servers where you will be
installing VCAP and components.

5. Uncompress and extract dev_setup.tar.gz file in the servers where the file was copied to.

### Scripts in dev_setup/bin directory

1. _vcap_dev_setup_: Main script which will be invoked to do the VCAP and component installation

		usage: ./vcap_dev_setup options

		OPTIONS:
		  -h           Show this message
		  -a           Answer yes to all questions
		  -p           http proxy i.e. -p http://username:password@host:port/
		  -c           deployment config
		  -d           cloudfoundry home
		  -D           cloudfoundry domain (default: vcap.me)
		  -r           cloud foundry repo
		  -b           cloud foundry repo branch/tag/SHA


2. _vcap_dev_: Script to start/stop components

		Usage: ./vcap_dev [--name deployment_name] [--dir cloudfoundry_home_dir] [start|stop|restart|tail|status]
		    -n, --name deployment_name       Name of the deployment
		    -d, --dir cloud_foundry_home_dir Cloud foundry home directory

### Deployment Specifications

The [vcap_dev/deployments](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments) directory 
contains the deployment specifications. This directory has a 
[README](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments#readme) as well, please review. The single node deployment (instructions above) uses the  [devbox.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/devbox.yml) deployment specification, which installs all the components in the local server. In the next section we'll walk through deployment of the [multihost_mysql](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments/sample/multihost_mysql) specification.


## Multi Node Deployment Walkthrough

We will walk through the deployment of VCAP components in 4 nodes (example IP addresses included):

  4. **Cloud Controller, Router, Health Manager, Services** - `10.20.143.190`
  1. **DEA** - `10.20.143.187`
  2. **MySQL Node 0** - `10.20.143.188`
  3. **MySQL Node 1** - `10.20.143.189`
 
This deployment is described in 
[deployments/sample/multihost_mysql](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments/sample/multihost_mysql) - please review the deployment configuration files.

 
### 1. Copy over and Extract dev_setup scripts

As covered in the **Prerequisites** section, copy over the _dev_setup.tar.gz_ to the individual nodes and extract them.

### 2. Install First Node: _rest.yml_ on 10.20.143.190

There are no changes required for the deployment configuration used for this node:
[rest.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/rest.yml)

    
    ---  
    deployment:  
      name: "rest"  
    jobs:  
      install:  
        - nats_server  
        - cloud_controller:  
            builtin_services:  
              - redis  
              - mongodb  
              - mysql  
        - router  
        - health_manager  
        - ccdb  
        - redis:  
            index: "0"  
        - redis_gateway  
        - mysql_gateway  
        - mongodb:  
            index: "0"  
        - mongodb_gateway

Invoke the vcap_dev_setup script with the configuration file option:

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/rest.yml   
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Hit http://security.ubuntu.com lucid-security Release.gpg   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Hit http://us.archive.ubuntu.com lucid Release.gpg
    
    .. and more ..


If the installation stops due to an error, please be sure to review the **Known Issues** section at the end of this document. IF successful, the installation will end with messages similar to below. We will _not start_ the
components yet, but will install other components in the other
nodes and finish by starting them up in sequence.

    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/rest/config  
    Deployment name: rest  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n rest start

### 3. Install DEA Node:  _dea.yml_ on 10.20.143.187

The deployment configuration used for this node,
[dea.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/dea.yml), requires some modification (please note that the modified `nats_server` host):

    ---  
    # Deployment  
    # ----------  
    deployment:  
      name: "dea"
    
    jobs:  
      install:  
        - dea  
      installed:  
        - nats_server:  
          host: "10.20.143.190"  
          port: "4222"  
          user: "nats"  
          password: "nats"

Install using vcap_dev_setup script passing in the dea.yml configuration in
command line:

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/dea.yml   
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US 
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]
    Ign http://apt.opscode.com lucid-0.10/main Packages
    Ign http://apt.opscode.com lucid-0.10/main Packages
    Hit http://security.ubuntu.com lucid-security Release.gpg
    Get:3 http://apt.opscode.com lucid-0.10/main Packages [14.6kB]
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/main Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/restricted Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/universe Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/multiverse Translation-en_US
    
    .. and more ..

If the installation stops due to an error, please be sure to review the **Known Issues** section at the end of this document. Upon successful installation you will see messages similar to below. We will
wait to start the components and proceed with installation of MysQL Node 0.
    
    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/dea/config  
    Deployment name: dea  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n dea start


### 4. Install First MySQL Node: _mysql0.yml_ on 10.20.143.188

The deployment configuration used for this node, [mysql0.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql0.yml), requires some modification (please note that the modified `nats_server` host):

    
    ---  
    deployment:  
      name: "mysql0"  
    jobs:  
      install:  
        - mysql:  
            index: "0"  
       installed:  
         - nats_server:  
           host: "10.20.143.190"
           port: "4222"  
           user: "nats"  
           password: "nats"


Install using vcap_dev_setup script with the mysql0.yml deployment configuration option:

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/mysql0.yml
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Ign http://apt.opscode.com lucid-0.10/main Packages
    
    .. and more ..

At the end of installation, you will see messages similar to below. We will
not start the components now, but will move on to installing 
MySQL Node 1.

    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/mysql0/config  
    Deployment name: mysql0  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql0 start


### 5. Install Second MySQL Node: _mysql1.yml_ on 10.20.143.189

The deployment configuration used for this node, [mysql1.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql1.yml), requires some modification (please note that the modified `nats_server` host):

    
    ---  
    deployment:  
      name: "mysql1"  
    jobs:  
      install:  
        - mysql:  
          index: "1"  
      installed:  
        - nats_server:  
          host: "10.20.143.190"  
          port: "4222"  
          user: "nats"  
          password: "nats"

Install using vcap_dev_setup script with the mysql0.yml deployment
configuration option:

    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/mysql1.yml
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Get:3 http://security.ubuntu.com lucid-security Release.gpg [198B]  
    Hit http://us.archive.ubuntu.com lucid Release.gpg   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Get:4 http://apt.opscode.com lucid-0.10/main Packages [14.6kB]   
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/main Translation-en_US  
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/main Translation-en_US   
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/restricted Translation-en_US   
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/restricted Translation-en_US  
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/universe Translation-en_US  
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/universe Translation-en_US
    
    .. and more ..

At the end of install, you will messages similar to the following.

    
    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/mysql1/config  
    Deployment name: mysql1  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql1 start


### 5. Start up all the components

1. Start all the components installed on the _**rest**_ deployment
node (`10.20.143.190`)

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n rest start 
    	Setting up cloud controller environment  
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/rest/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start health_manager mongodb_gateway router redis_gateway mongodb_backup redis_node mongodb_node mysql_gateway redis_backup cloud_controller -c /home/cfsupp/cloudfoundry/.deployments/rest/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	health_manager : RUNNING  
    	mongodb_gateway : RUNNING  
    	router : RUNNING  
    	redis_gateway : RUNNING  
    	redis_node : RUNNING  
    	mongodb_node : RUNNING  
    	mysql_gateway : RUNNING  
    	cloud_controller : RUNNING

2. Start components installed on the **_dea_** deployment node (`10.20.143.187`)

    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n dea start  
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/dea/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/dea/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start dea -c /home/cfsupp/cloudfoundry/.deployments/dea/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	dea : RUNNING

3. Start components installed on the **_mysql0_** deployment node (`10.20.143.188`)

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql0 start 
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/mysql0/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/mysql0/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start mysql_backup mysql_node -c /home/cfsupp/cloudfoundry/.deployments/mysql0/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	mysql_node : RUNNING

4. Start components installed on the **_mysql1_** deployment node (`10.20.143.189`)

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql1 start**  
   	 	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/mysql1/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/mysql1/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start mysql_backup mysql_node -c /home/cfsupp/cloudfoundry/.deployments/mysql1/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	mysql_node : RUNNING

## Multi Node Installation Verification

The cloud_controller component listens for commands on the `api.vcap.me` endpoint, which points to `127.0.0.1`. Run the vcap command-line client, `vmc`, on the node where cloud_controller is running (the **rest** node at `10.20.143.190`).

    
    $ vmc target
    
    [http://api.vcap.me]
    
    $ vmc info
    
    VMware's Cloud Application Platform  
    For support visit http://support.cloudfoundry.com
    
    Target: http://api.vcap.me (v0.999)  
    Client: v0.3.12
    
    $ vmc register
    Email: user@vmware.com  
    Password: *******  
    Verify Password: *******  
    Creating New User: OK  
    Successfully logged into [http://api.vcap.me]
    
    $ vmc info
    
    VMware's Cloud Application Platform  
    For support visit http://support.cloudfoundry.com
    
    Target: http://api.vcap.me (v0.999)  
    Client: v0.3.12
    
    User: user@vmware.com  
    Usage: Memory (0B of 2.0G total)  
     Services (0 of 16 total)  
     Apps (0 of 20 total)
    
    $ vmc services
    
    ============== System Services ==============
    
    +---------+---------+-------------------------------+  
    | Service | Version | Description                   |  
    +---------+---------+-------------------------------+  
    | mongodb | 1.8 | MongoDB NoSQL store               |  
    | mysql   | 5.1 | MySQL database service            |  
    | redis   | 2.2 | Redis key-value store service     |  
    +---------+---------+-------------------------------+
    
    =========== Provisioned Services ============
    
      
    $ vmc frameworks
    
    +-----------+  
    | Name      |  
    +-----------+  
    | sinatra   |  
    | spring    |  
    | node      |  
    | grails    |  
    | lift      |  
    | rails3    |  
    | otp_rebar |  
    +-----------+

We will push a simple Sinatra application which prints out 
envrionment variables available to the app in Cloud Foundry. Paste the following into a file
named env.rb

	require 'rubygems'
	require 'sinatra'
	require 'json/pure'

	get '/' do
	  host = ENV['VMC_APP_HOST']
	  port = ENV['VMC_APP_PORT']
	  "<h1>XXXXX Hello from the Cloud! via: #{host}:#{port}</h1>"
	end

	get '/env' do
	  res = "<html><body style=\"margin:0px auto; width:80%; font-family:monospace\">" 
	  res << "<head><title>CloudFoundry Environment</title></head>"
	  res << "<h3>CloudFoundry Environment</h3>"
	  res << "<div><table>"
	  ENV.keys.sort.each do |key|
	    value = begin
	              "<pre>" + JSON.pretty_generate(JSON.parse(ENV[key])) + "</pre>"
	            rescue
	              ENV[key]
	            end
	    res << "<tr><td><strong>#{key}</strong></td><td>#{value}</tr>"
	  end
	  res << "</table></div></body></html>"
	end
	
Then push the app to your VCAP instance:
    
    $ vmc push env -n  
    Creating Application: OK  
    Uploading Application:  
     Checking for available resources: OK  
     Packing application: OK  
     Uploading (1K): OK   
    Push Status: OK  
    Staging Application: OK   
    Starting Application: OK
    
    $ curl -I env.vcap.me 
    HTTP/1.1 200 OK   
    Server: nginx/0.7.65  
    Date: Wed, 07 Sep 2011 23:39:09 GMT  
    Content-Type: text/html;charset=utf-8  
    Connection: keep-alive  
    Keep-Alive: timeout=20  
    Vary: Accept-Encoding  
    Content-Length: 4239

We will create and bind a mysql service to the application

    
    $ vmc create-service mysql mysql-env env  
    Creating Service: OK  
    Binding Service: OK  
    Stopping Application: OK  
    Staging Application: OK   
    Starting Application: OK
    
    $ vmc apps
    
    +-------------+----+---------+----------------+--------------+  
    | Application | #  | Health  | URLS           | Services     |  
    +-------------+----+---------+----------------+--------------+  
    | sv-env      | 1  | RUNNING | env.vcap.me    | mysql-env    |  
    +-------------+----+---------+----------------+--------------+
       

# Known Issues

## Installation fails behind an HTTP proxy

If you are behind an HTTP proxy, please make sure to configure the Ubuntu VM to use the proxy prior to installation.

1. Set the environment variables `http_proxy, https_proxy, no_proxy`:

		$ http_proxy="http://<proxy-host>:<proxy-port>"
		$ https_proxy=$http_proxy
		$ no_proxy="localhost,vcap.me"
		$ export http_proxy https_proxy no_proxy
	
	Sometimes (not typical), you may need to specify a userid and password, this depends on the environment. Please ask your system administrator or helpdesk.

		http_proxy=http://<username>:<password>@<proxy-host>:<proxy-port>
	
	To ensure the proxy is used when commands are run as the `root` user (which occurs when _dev_setup_ asks for the `sudo` password), edit `/etc/sudoers` and add the following configuration:

		Defaults env_keep = "http_proxy https_proxy no_proxy"

2. VCAP installation uses maven for certain components to download external dependencies. You'll want to add your proxy information to the maven settings file:
		
		$ mkdir ~/.m2
		$ vi ~/.m2/settings.xml

		<settings>
		  <proxies>
		    <proxy>
		      <active>true</active>
		      <protocol>http</protocol>
		      <host>proxy-host.yourcompany.com</host>
		      <port>3128</port>
		      <username>proxy-user</username>
		      <password>proxy-password</password>
		      <nonProxyHosts>localhost|*.vcap.me</nonProxyHosts>
		    </proxy>
		  </proxies>
		</settings>
		
	You may need to specify an HTTPS proxy as well in `~/cloudfoundry/.deployments/<deployment_name>/deploy/maven/apache-maven-3.0.4/bin/m2.conf`:
	
		set https.proxyHost default proxy-host.yourcompany.com
		set https.proxyPort default 3128
		
## Installation of  _rack_ fails with _ArgumentError_
The error may look similar to:
   
    	[Wed, 31 Aug 2011 14:36:56 -0700] WARN: failed to find gem rack (>= 0, runtime) from [http://gems.rubyforge.org/]  
    	[Wed, 31 Aug 2011 14:36:56 -0700] DEBUG: sh(/home/cfsupp/cloudfoundry/.deployments/devbox/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "")  
    	[Wed, 31 Aug 2011 14:36:56 -0700] ERROR: gem_package[rack] (ruby::default line 75) has had an error  
    	[Wed, 31 Aug 2011 14:36:56 -0700] ERROR: gem_package[rack] (/home/cfsupp/cloudfoundry/vcap/dev_setup/cookbooks/ruby/recipes/default.rb:75:in `from_file') had an error:  
    	gem_package[rack] (ruby::default line 75) had an error: Expected process to exit with [0], but received '1'
    	[Tue, 06 Sep 2011 15:16:44 -0700] FATAL: Chef::Exceptions::ShellCommandFailed: gem_package[rack] (ruby::default line 75) had an error: Expected process to exit with [0], but received '1'  
    	---- Begin output of /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" ----  
    	STDOUT:   
    	STDERR: ERROR: While executing gem ... (ArgumentError)
    	Illformed requirement [""] 
    	---- End output of /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" ----  
    	Ran /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" returned 1

If you re-run the vcap_dev_setup script, the script picks up where it left off and should successfully 
install rack. You may get a similar error more than once; if so, please try re-running vcap_dev_setup again until it completes.
