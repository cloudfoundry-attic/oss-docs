# Workflow

To contribute to Cloud Foundry you should follow this process.

## Pre-work

These steps only need to be done once.

### Complete CLA

* [individuals](http://www.cloudfoundry.org/individualcontribution.pdf)
* [corporations](http://www.cloudfoundry.org/corpcontribution.pdf)

### Sign up for an account on gerrit

[http://reviews.cloudfoundry.org/](http://reviews.cloudfoundry.org/)

### Setup ssh

If you don't alrady have a ssh pbulic/private key pair, you need to create one up with:

    ssh-keygen -t rsa

Remember to set a passphrase - the world is insecure enough as it is! Use `ssh-add` if you want non-interactive logins.

Then optionally edit `~/.ssh/config` and add

    Host reviews.cloudfoundry.org
    Port 29418

This lets you skip the port number when referring to the host.

If your local username differs from the remote, you also need to add the line

    User menglund

### Setup git

The email address in the commit must be in gerrit.

    git config --global user.name "Firstname Lastname"
    git config --global user.email "your_email@youremail.com"

You can add multiple email addresses in [gerrit](http://reviews.cloudfoundry.org/#/settings/contact) if you need to.

### Clone the repository

Install our gerrit helper Ruby gem

    gem install gerrit-cli

The last one-time step is to clone the gerrit repository.

Note! Don't clone the **github** repository, we don't accept pull requests.

    gerrit clone ssh://reviews.cloudfoundry.org/bosh

Make sure to use this instead of cloning by hand (with `git clone`) as this installs a pre-commit hook that adds the required `Change-Id`.

## Normal workflow

Now you are ready to start working on your change

### Create a branch

You don't have to use a branch, but it makes things much easier, so we recommend using one.

    git checkout -b agent/needs_foo

If you have a number of changes you want to submit, using one branch per change makes things easier, as gerrit see changes in the same branch as dependent.

### Make your changes

Follow the [github ruby style guide](https://github.com/styleguide/ruby). We prefer readable over clever!

Run the test suites! Gerrit will do it for you, but it speeds up your development cycle doing it locally before you push the change.

### Commit your changes

Add your change and your test cases, and commit them.

    git add agent/lib/agen/foo.rb agent/spec/unit/foo_spec.rb
    git commit

Your commit message should have a first line which contains a description of the change, and then list the details of the change in a paragraph below. Make sure to include how you have tested your change.

### Final checks

Pull down any changes that may have been committed

    git pull --rebase

Resolve any conflicts that may occur and finally push the change to gerrit

    gerrit push

Once your change passes the ci, you can add reviewers or you can just wait for us to go and look at the change.