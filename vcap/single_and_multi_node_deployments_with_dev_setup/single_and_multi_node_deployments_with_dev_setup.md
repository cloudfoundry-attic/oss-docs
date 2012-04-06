#Single and Multi Node VCAP Deployments using dev_setup


_Author: **Mahesh Patil**_

## Background

In the [github.com/cloudfoundry/vcap](http://github.com/cloudfoundry/vcap) repository, we have published a VCAP installation scheme called _dev_setup_ which uses [Chef](https://github.com/opscode/chef). Please review the contents of the [dev_setup](https://github.com/cloudfoundry/vcap/tree/master/dev_setup) directory. You can use this scheme to do a single-node or multi-node VCAP install. This document walks thru a single node and a multi node installation using the dev_setup scripts.

## Disclaimer

These scripts are tested with and assume a pristine Ubuntu 10.04 64-bit install. Other Ubuntu releases, Linux distributions, and operating systems have not been verified with this installation method and are unlikely to work.

## Common

1. Please review the vcap_dev_setup
[README](https://github.com/cloudfoundry/vcap/tree/master/dev_setup#readme)

2. Clone VCAP repository
    
    	$ git clone https://github.com/cloudfoundry/vcap.git**

3. Tar up dev_setup directory

    	$ cd vcap
    	$ tar czvf dev_setup.tar.gz dev_setup

4. Copy over dev_setup.tar.gz file to the servers where you will be
installing VCAP and components.

5. Uncompress and extract dev_setup.tar.gz file in the servers where the file was copied to.

## Scripts in dev_setup/bin directory

1. _vcap_dev_setup_ : Main script which will be invoked to do the VCAP and component installation

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


2. _vcap_dev_ : Script to start/stop components

		Usage: ./vcap_dev [--name deployment_name] [--dir cloudfoundry_home_dir] [start|stop|restart|tail|status]
		    -n, --name deployment_name       Name of the deployment
		    -d, --dir cloud_foundry_home_dir Cloud foundry home directory

## Deployment Specification

[vcap_dev/deployments](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments) directory 
contains the deployment specifications. This directory has a 
[README](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments#readme) as well, please review.

## Single Node Deployment

Assuming you are in a pristine Ubuntu 10.04 64-bit environment, you can do a
single node deployment using either of the following two options.

### Option 1

Install curl, get and execute the _vcap_dev_setup_ script from github as below:

    $ sudo apt-get install curl  
    $ bash < <(curl -s -k -B https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup)

If the installation stops due to an error, please be sure to review the **Known Issues** section at the end of this document.

### Option 2

Assuming the steps are done as mentioned in the Common section, change
directory into _dev_setup/bin_.

Running the _bin/vcap_dev_setup_ script without any options will install all components in
the local server and is equivalent to a single node deployment. By default,
the VCAP software will be installed in `~/cloudfoundry/`. For
different options supported by this script, please see the previous section.

Default Installation directory: `$HOME/cloudfoundry`

Please note that the _vcap_dev_setup_ script will clone and update the
Cloud Foundry open source VCAP git repo under the installation directory.
Also, you will see a `$HOME/cloudfoundry/.deployments` directory which will
contain deployment configuration and software.

We will invoke _bin/vcap_dev_setup_ script taking all the default options.
This will use the [deployments/devbox.yml](https://github.com/cloudfoundry/vca
p/blob/master/dev_setup/deployments/devbox.yml) deployment specification,
which will install all the components in the local server.

For example :

    $ bin/vcap_dev_setup
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Get:1 http://theonemirror.eng.vmware.com lucid-security Release.gpg [198B]  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US   
    Get:2 http://theonemirror.eng.vmware.com lucid-updates Release.gpg [198B]  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US   
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Get:3 http://theonemirror.eng.vmware.com lucid-security Release [44.7kB]  
    Get:4 http://theonemirror.eng.vmware.com lucid-updates Release [44.7kB]   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Get:5 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:6 http://theonemirror.eng.vmware.com lucid-security/main Packages [262kB]   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US
    .. and more ..

You will be asked for confirmation of chef-solo installation and the sudo
password. After that the installation will continue to install the software
and necessary components for a local vcap install. At the end of the script
execution, you should messages similar to below.
    
    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/devbox/config  
    Deployment name: devbox  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev start

If the installation stops due to an error, please be sure to review the **Known Issues** section at the end of this document.

### Starting VCAP

Let's find out the status of all the vcap components (should be stopped) and start them. Please
note that the vcap software is installed under `~/cloudfoundry/vcap`:
    
    $ cd ~/cloudfoundry/vcap  
    $ dev_setup/bin/vcap_dev status 
    Setting up cloud controller environment  
    Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/devbox/config  
    Executing /home/cfsupp/cloudfoundry/.deployments/devbox/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap status mysql_backup dea mongodb_gateway health_manager redis_gateway mysql_node router mongodb_backup mongodb_node redis_node mysql_gateway redis_backup cloud_controller -c /home/cfsupp/cloudfoundry/.deployments/devbox/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    dea : STOPPED  
    mongodb_gateway : STOPPED  
    health_manager : STOPPED  
    redis_gateway : STOPPED  
    mysql_node : STOPPED  
    router : STOPPED  
    mongodb_node : STOPPED  
    redis_node : STOPPED  
    mysql_gateway : STOPPED  
    cloud_controller : STOPPED
    
    $ dev_setup/bin/vcap_dev start 
    Setting up cloud controller environment  
    Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/devbox/config  
    Executing /home/cfsupp/cloudfoundry/.deployments/devbox/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start mysql_backup dea mongodb_gateway health_manager redis_gateway mysql_node router mongodb_backup mongodb_node redis_node mysql_gateway redis_backup cloud_controller -c /home/cfsupp/cloudfoundry/.deployments/devbox/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    dea : RUNNING  
    mongodb_gateway : RUNNING  
    health_manager : RUNNING  
    redis_gateway : RUNNING  
    mysql_node : RUNNING  
    router : RUNNING  
    mongodb_node : RUNNING  
    redis_node : RUNNING  
    mysql_gateway : RUNNING  
    cloud_controller : RUNNING

Voila!  We are up and running. We can verify with the vcap command-line client, `vmc`:

    $ vmc target
    
    [http://api.vcap.me]
    
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

## Multi Node Deployment

We will walk through the deployment of VCAP components in 4 nodes (example IP addresses included):

  1. DEA - `10.20.143.187`
  2. MySQL Node 0 - `10.20.143.188`
  3. MySQL Node 1 - `10.20.143.189`
  4. Remaining Components - `10.20.143.190`
 
This deployment is described in 
[deployments/sample/multihost_mysql](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments/sample/multihost_mysql) - please review the deployment configuration files.

 
### Copy over and Extract dev_setup scripts

First as specified in Common setup section, copy over the _dev_setup.tar.gz_
to the individual nodes and extract them.

### Install Rest of the Components (10.20.143.190)

There are no changes required for the deployment configuration 
[deployments/sample/multihost_mysql/rest.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/rest.yml)

    
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

### Install DEA (10.20.143.187)

Sample configuration is at
[dev_setup/deployments/sample/multihost_mysql/dea.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/dea.yml). Modified configuration is below (please note that the modified `nats_server` host):

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


### Install MySQL Node 0 (10.20.143.188)

The deployment configuration for MySQL Node 0 is in [dev_setup/deployments/sample/multihost_mysql/mysql0.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql0.yml)

Modified configuration is below; please note you need to fill in the correct
values for `nats_server`:

    
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


### Install MySQL Node 1 (10.20.143.189)

Deployment configuration for mysql node 0 is in [dev_setup/deployments/sample/multihost_mysql/mysql1.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql1.yml)

Modified configuration is below; again, note that you need to fill in the correct
values for `nats_server`:

    
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


### Start up all the components

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

### Installation Verification

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
envrionment variables available to the app in Cloud Foundry. Please review the source in
attached [env.rb](support/env.rb) file.

    
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
       

## Known Issues

1. During vcap_dev_setup, `rack` installation may fail with _ArgumentError_. If you
re-run the vcap_dev_setup script, the script continues successfully with
installing rack. You may get the same error more than once; if so, please try re-running vcap_dev_setup again.
   
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

