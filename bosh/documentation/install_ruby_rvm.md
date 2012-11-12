## Install Ruby via rvm ##

This document describes how to install Ruby using rvm.

_Note : Assuming you are starting with a pristine Ubuntu 12.10 VM or a Physical Machine_

1. Install `curl` using `apt-get`

		sudo apt-get install curl
1. Install rvm using curl

		\curl -L https://get.rvm.io | bash -s
		
1. Reload the `.bash_profile` in the current terminal
		
		source ~/.bash_profile
_Note :  To make sure bash is run as a login shell and rvm is loaded, please follow the steps in the doc [Integrating RVM with gnome-terminal] (https://rvm.io/integration/gnome-terminal/)_

2. Check the required dependencies for installing ruby

		rvm requirements

2. Install the required pre-reqs for installing ruby

		sudo /usr/bin/apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g \
		  zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \ 
		  libc6-dev ncurses-dev

1. Install ruby 1.9.2 using `rvm`
		
		rvm install 1.9.2
1. Set the ruby version to 1.9.2

		rvm use 1.9.2

1. Check that the correct version of ruby has been set

		ruby -v

3.  Install bundler gem

		gem install bundler
 
1. Install rake gem

		gem install rake


