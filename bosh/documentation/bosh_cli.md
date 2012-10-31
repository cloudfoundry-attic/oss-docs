# BOSH CLI #

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


