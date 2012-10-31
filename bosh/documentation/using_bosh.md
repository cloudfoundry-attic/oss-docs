# Using BOSH #

Before we can use BOSH we need to install the [BOSH CLI](#bosh-cli). To continue with this section, you will need a running development environment with an uploaded Stemcell. If this is not the case, you can  [BOSH installation](#bosh-installation) section.

## Installing BOSH Command Line Interface ##

The following steps install BOSH CLI on Ubuntu 10.04 LTS. You can install on either a physical or Virtual Machine.

### Install Ruby via rbenv ###

1. Bosh is written in Ruby. Let's install Ruby's dependencies

		sudo apt-get install git-core build-essential libsqlite3-dev curl \
	    libmysqlclient-dev libxml2-dev libxslt-dev libpq-dev

1. Get the latest version of rbenv

		cd
		git clone git://github.com/sstephenson/rbenv.git .rbenv

1. Add `~/.rbenv/bin` to your `$PATH` for access to the `rbenv` command-line utility

		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile

1. Add rbenv init to your shell to enable shims and autocompletion

		echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

1. Download Ruby 1.9.2

_Note: You can also build ruby using ruby-build plugin for rbenv. See https://github.com/sstephenson/ruby-build_

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

_Note: The rake 0.8.7 gem may need to be reinstalled when using this method_

		gem pristine rake

1. Update rubygems and install bundler.

_Note: After installing gems (`gem install` or `bundle install`) run `rbenv rehash` to add new shims_

		rbenv rehash
		gem update --system
		gem install bundler
		rbenv rehash

### Install Local BOSH and BOSH Releases ###

1. Sign up for the Cloud Foundry Gerrit server at [http://reviews.cloudfoundry.org](http://reviews.cloudfoundry.org)

1. Set up your ssh public key (accept all defaults)

		ssh-keygen -t rsa

1. Copy your key from `~/.ssh/id_rsa.pub` into your Gerrit account

1. Create and upload your public SSH key in your Gerrit account profile

1. Set your name and email

		git config --global user.name "Firstname Lastname"
		git config --global user.email "your_email@youremail.com"

1. Install out gerrit-cli gem

		gem install gerrit-cli

1. Clone BOSH repositories from Gerrit

		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/cf-release.git
		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/bosh.git

1. Run some rake tasks to install the BOSH CLI

		gem install bosh_cli
		rbenv rehash
		bosh --version


### Deploy to your BOSH Environment ###

With a fully configured environment, we can begin deploying a Cloud Foundry Release to our environment. As listed in the prerequisites, you should already have an environment running, as well as the IP address of the BOSH Director. To set this up, skip to the [BOSH installation](#bosh-installation) section.

### Point BOSH at a Target and Clean your Environment ###

1. Target your Director (this IP is an example.)

		bosh target 11.23.128.219:25555

1. Check the state of your BOSH settings.

		bosh status

1. The result of your status will be akin to:

		Target         dev48 (http://11.23.128.219:25555) Ver: 0.3.12 (01169817)
		UUID           4a8a029c-f0ae-49a2-b016-c8f47aa1ac85
		User           admin
		Deployment     not set

1. List any previous Deployments (we will remove them in a moment). If this is your first Deployment, there will be none listed.

		bosh deployments

1. The result of `bosh deployments` should be akin to:

		+-------+
		| Name  |
		+-------+
		| dev48 |
		+-------+

1. Delete the existing Deployments (ex: dev48.)

		bosh delete deployment dev48

1. Answer `yes` to the prompt and wait for the deletion to complete.

1. List previous Releases (we will remove them in a moment). If this is your first Deployment, there will be none listed.

		bosh releases

1. The result of `bosh releases` should be akin to:

		+---------------+---------------+
		| Name          | Versions      |
		+---------------+---------------+
		| cloudfoundry	| 47, 55, 58    |
		+---------------+---------------+

1. Delete the existing Releases (ex: cloudfoundry)

		bosh delete release cloudfoundry

1. Answer `yes` to the prompt and wait for the deletion to complete.

### Create a Release ###

1. Change directories into the release directory.

		cd ~/cf-release
	
	This directory contains the Cloud Foundry deployment and release files.

1. Update submodules and pull down blobs (also used to update the repository).

		./update

1. Reset your environment

		bosh reset release

1. Answer `yes` to the prompt and wait for the environment to be reset

1. Create a Release

		bosh create release --force

1. Answer `cloudfoundry` to the `release name` prompt

1. Your terminal will display information about the release including the Release Manifest, Packages, Jobs, and tarball location.

1. Create or locate a manifest file.  For instance copy
`bosh/samples/cloudfoundry.yml` from the `oss-docs` documentation
repository.

1. Open the manifest file in your favorite text editor and confirm that `name` and `version` matches the version that was displayed in your terminal at the end of the release creation (if this is your first release, it will be version 1.)

### Deploy the Release ###

1. Set the deployment to point to your manifest file

        bosh deployment path/to/my-manifest.yml

1. Upload the cloudfoundry Release to your Environment.

		bosh upload release

1. Your terminal will display information about the upload, and an upload progress bar will reach 100% after a few minutes.

1. Open the manifest and make sure that your network settings match the environment that you were given.

1. Deploy the Release.

		bosh deploy

1. Your deployment will take a few minutes. If it fails then possibly the manifest does not match the release directory.  If your target platform has a template manifest provided by the adminitrator (e.g. `template.erb`), you can use `bosh diff template.erb` to compare your manifest to the most up  to data target and fix common problems like missing properties or jobs.

1. You may now target the Cloud Foundry deployment using VMC, as described in the Cloud Foundry documentation.

