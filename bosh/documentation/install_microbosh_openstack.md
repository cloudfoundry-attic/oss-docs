#Installing Micro BOSH on a VM

##Prerequisites:

 *	You should have OpenStack Installed on. Please refer to this [document](https://github.com/cloudfoundry/oss-docs/tree/master/bosh/documentation/install_openstack.md) for installation steps.
 *	Create a VM using horizon and you should be able to SSH into that VM- this is also called inception VM.


##Step 1: Create Inception VM

1. Login to dashboard as admin.
2. Select Project tab - > admin project.
3. Click on Access & Security - > Click on Create Keypair button.
4. Enter keypair name as admin-keypair and click on Create Keypair.
5. Save the keypair to some location like: /home/<username>/openstack/admin-keypair.pem
6. Copy the admin-keypair.pem to Inception VM.

	
scp -i /root/.ssh/admin-keypair.pem  /root/.ssh/admin-keypair.pem ubuntu@192.168.22.34:/home/ubuntu

**Note:** Remember the keypair location. we would use this pair many times later.

##Step 2: Login to vm

    sudo su
    (Enter password and hit Enter)

Check whether SSH Installed or not

    /etc/init.d/ssh status

If not installed install SSH

    apt-get install ssh

Create SSH Keys

    ssh-keygen -t rsa

Output

    Generating public/private rsa key pair.
    # Enter file in which to save the key (/home/you/.ssh/id_rsa): <Click Enter>
    # Enter passphrase (empty for no passphrase):  <Click Enter>
    # Enter same passphrase again: <Click Enter>
    Your identification has been saved in /home/you/.ssh/id_rsa.
    Your public key has been saved in /home/you/.ssh/id_rsa.pub.
    The key fingerprint is:
    01:0f:f4:3b:ca:85:d6:17:a1:7d:f0:68:9d:f0:a2:db

Copy admin-keypair to /root/.ssh

    cp /home/<username>/openstack/admin-keypair.pem /root/.ssh/.

Change permissions

	chmod -R 600 /root/.ssh/.

Login to vm

    ssh -i /root/.ssh/admin-keypair.pem ubuntu@192.168.22.34


**Note:** 192.168.22.34 is the Inception VM IP Address.


##Step 3 : Install Ruby

    sudo su

Install rvm and ruby.

    apt-get -y install build-essential libsqlite3-dev curl rsync git-core libmysqlclient-dev libxml2-dev libxslt-dev libpq-dev genisoimage

    curl -L https://get.rvm.io | sudo bash -s stable

    source /etc/profile.d/rvm.sh

    rvm install 1.9.2-p280

    rvm use 1.9.2

    apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config

Test RVM and Ruby

    rvm -v
    ruby -v

    Output:- It should show Ruby 1.9.2.

##Step 4 : Install BOSH CLI 

    gem install bosh_deployer --no-ri --no-rdoc

##Step 5 : Create Custom Micro Bosh Stemcell

Install the below dependencies before you run the below commands.
    root@inception-vm:/home/ubuntu/# apt-get install libpq-dev debootstrap kpartx qemu -y

Download the BOSH release and build it

    mkdir -p releases
    cd  releases
    git clone git://github.com/frodenas/bosh-release.git
    cd bosh-release
    git submodule update --init


####Build the BOSH release


    bosh create release --with-tarball

If this is the first time you run bosh create release in the release repo, it will ask you to name the release, e.g. "bosh".

    Output will be like this:
    Release version: x.y-dev
    Release manifest: /home/ubuntu/releases/bosh-release/dev_releases/bosh-x.y-dev.yml
    Release tarball (95.2M): /home/ubuntu/releases/bosh-release/dev_releases/bosh-x.y-dev.tgz

####Install BOSH Agent

    cd /home/ubuntu/
    git clone git://github.com/frodenas/bosh.git
    cd bosh/agent/
    bundle install --without=development test

    apt-get install libpq-dev

####Install OpenStack registry

    cd /home/ubuntu/bosh/openstack_registry
    bundle install --without=development test
    bundle exec rake install

####Build Custom Stemcell

    root@inception-vm:/home/ubuntu/bosh/openstack_registry/# cd /home/ubuntu/bosh/agent
    root@inception-vm:/home/ubuntu/bosh/agent/# rake stemcell2:micro["openstack",/home/ubuntu/releases/bosh-release/micro/openstack.yml,/home/ubuntu/releases/bosh-release/dev_releases/bosh-x.y-dev.tgz]

**Note:** Replace x.y with actual bosh version numbers. For example: bosh-0.6-dev.tgz


Output will be like this:

    Generated stemcell: 
    /var/tmp/bosh/agent-x.y.z-nnnnn/work/work/micro-bosh-stemcell-openstack-x.y.z.tgz

####Copy the generated stemcell to a safe location

    cd /home/ubuntu/
    mkdir -p stemcells
    cd stemcells
    cp /var/tmp/bosh/agent-x.y.z-nnnnn/work/work/micro-bosh-stemcell-openstack-x.y.z.tgz .


##Step 7 : Deploy Micro Bosh stemcell to Glance  ##

This creates the Micro Bosh VM and it shows up in Horizon 

    mkdir -p deployments/microbosh-openstack
    cd deployments/microbosh-openstack

####Create Manifest File

    vim micro-bosh.yml

Copy the below content and paste it in `micro-bosh.yml`


    name: microbosh-openstack

    env:
     bosh:
        password: $6$u/dxDdk4Z4Q3$MRHBPQRsU83i18FRB6CdLX0KdZtT2ZZV7BLXLFwa5tyVZbWp72v2wp.ytmY3KyBZzmdkPgx9D3j3oHaDZxe6F.


     level: DEBUG

    network:
     name: default
     type: dynamic
     label: private
     ip: 192.168.22.34


    resources:
     persistent_disk: 4096
     cloud_properties:
        instance_type: m1.small

    cloud:
      plugin: openstack
      properties:
       openstack:
           auth_url: http://10.0.0.2:5000/v2.0/tokens
           username: admin
           api_key: f00bar
           tenant: admin
           default_key_name: admin-keypair
           default_security_groups: ["default"]
           private_key: /root/.ssh/admin-keypair.pem



**Note:**

    1. Replace Only the red colored values with actual ones.
    2. Generate hashed password for f00bar
    3. Replace the password with hashed password.
 
----

    cd ..
    bosh micro deployment microbosh-openstack

**Output of the command is listed below:**

    $ WARNING! Your target has been changed to `http://microbosh-openstack:25555'!
    Deployment set to '/home/ubuntu/deployments/microbosh-openstack/micro_bosh.yml'


####Deploy the deployment using the custom stemcell image

    root@inception-vm:/home/ubuntu/deployments/# bosh micro deploy /home/ubuntu/stemcells/micro-bosh-stemcell-openstack-x.y.z.tgz

**Output of the command is listed below:**

    Deploying new micro BOSH instance `microbosh-openstack/micro_bosh.yml' to `http://microbosh-openstack:25555' (type 'yes' to continue): yes

    Verifying stemcell...
    File exists and readable                                     OK
    Manifest not found in cache, verifying tarball...
    Extract tarball                                              OK
    Manifest exists                                              OK
    Stemcell image file                                          OK
    Writing manifest to cache...
    Stemcell properties                                          OK

    Stemcell info
    -------------
    Name:    micro-bosh-stemcell
    Version: 0.6.4


    Deploy Micro BOSH
      unpacking stemcell (00:00:43)
      uploading stemcell (00:32:25)
      creating VM from 5aa08232-e53b-4efe-abee-385a7afb9421 (00:04:38)
      waiting for the agent (00:02:19)
      create disk (00:00:15)
      mount disk (00:00:07)
      stopping agent services (00:00:01)
      applying micro BOSH spec (00:01:20)
      starting agent services (00:00:00)
      waiting for the director (00:02:21)
    Done             11/11 00:44:30
    WARNING! Your target has been changed to `http://192.168.22.34:25555'!
    Deployment set to '/home/ubuntu/deployments/microbosh-openstack/micro_bosh.yml'
    Deployed `microbosh-openstack/micro_bosh.yml' to `http://microbosh-openstack:25555', took 00:44:30 to complete


####Test Micro BOSH deployment

    bosh target http://192.168.22.34

**Output of the command is listed below:**

    Target set to `microbosh-openstack (http://192.168.22.34:25555) Ver: 0.6 (release:ce0274ec bosh:0d9ac4d4)'
    Your username: admin
    Enter password: *****
    Logged in as `admin'

**Note:** It will ask for the username and password, enter admin for both.
