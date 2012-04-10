# Cloud Foundry OSS Resources #

_Cloud Foundry Open Source Platform as a Service_

* [Learn](learn)
* [Ask Questions](ask)
* [File a bug](file)
* [OSS Contributions](oss)


## Learn [learn] ## 

Cloud Foundry documentation is found in two places - one for open source developers, and one for cloudfoundry.com users:

* Open Source Developers - visit [https://github.com/cloudfoundry/oss-docs](https://github.com/cloudfoundry/oss-docs)
* Developers using CloudFoundry.com visit [http://docs.cloudfoundry.com](http://docs.cloudfoundry.com)

To make changes to our documentation, follow the [OSS Contribution](oss) steps and make contribute to the oss-docs repository.

## Ask Questions [ask] ##

Questions about the Cloud Foundry Open Source Project can be directed to our Google Groups: [http://groups.google.com/a/cloudfoundry.org/groups/dir](http://groups.google.com/a/cloudfoundry.org/groups/dir)

Questions about CloudFoundry.com can be directed to: [http://support.cloudfoundry.com](http://support.cloudfoundry.com)

## File a Bug [file] ##

To file a bug against Cloud Foundry Open Source and its components sign up and use our bug tracking system: [http://cloudfoundry.atlassian.net](http://cloudfoundry.atlassian.net)

## OSS Contributions [oss] ##

The Cloud Foundry team uses Gerrit, a code review tool that originated in the Android Open Source Project. We also use GitHub as an official mirror, though all pull requests are accepted via Gerrit. 

Follow these steps to make a contribution to any of our open source repositories:
  
1. Sign up for an account on our public Gerrit server at http://reviews.cloudfoundry.org/ 
1. Create and upload your public SSH key in your Gerrit account profile
1. Set your name and email

		git config --global user.name "Firstname Lastname"
		git config --global user.email "your_email@youremail.com"

Install our gerrit-cli gem:

		gem install gerrit-cli

Clone the Cloud Foundry repo. 

_Note: to clone the BOSH repo, or the Documentation repo, replace `vcap` with `bosh` or `oss-docs`_

		gerrit clone ssh://reviews.cloudfoundry.org:29418/vcap
		cd vcap

Adopt your preferred Git workflow. For example, you may want to create a feature branch for your change based on your cloned master branch:

		git checkout -b my-feature master		

Make a change and enter a commit message, repeating as many times as necessary:

		git commit -a
        # Enter your commit message when prompted

To make all your commits appear like a single change, you may want to perform an interactive rebase in your cloned repository and squash your commits into a single change:

        # This rebases all your my-feature branch commits since you forked your my-feature branch from master.
        git rebase -i master

This will open an editor which will allow you to squash all of your changes into a single commit. Change every **pick** except the first one to **squash**.
	
		pick 846cb1a modifying resources.md
		squash 7937440 some change
		squash 53a9f26 another change

		# Rebase d6ec913..53a9f26 onto d6ec913
		#
		# Commands:
		#  p, pick = use commit
		#  r, reword = use commit, but edit the commit message
		#  e, edit = use commit, but stop for amending
		#  s, squash = use commit, but meld into previous commit
		#  f, fixup = like "squash", but discard this commit's log message
		#  x, exec = run command (the rest of the line) using shell
		#
		# If you remove a line here THAT COMMIT WILL BE LOST.
		# However, if you remove everything, the rebase will be aborted.         

If you chose to rebase, another screen will appear where you can write a more detailed commit message. After you are satisfied with the message, you are ready to send your changes to gerrit for code review.

Push to gerrit:

		gerrit push 

Note: It is highly possible that you may want to periodically refresh your **master** branch clone of the gerrit code repository. The following commands will automatically fetch and merge changes from gerrit into your cloned master branch. You can use this master as a clean basis upon which to create new feature branches and develop further changes:

        git checkout master
        git pull

Once your commits are approved, you should see your revisions go from OPEN to MERGED at [http://reviews.cloudfoundry.org/](http://reviews.cloudfoundry.org/) and be replicated to GitHub. 

Every Gerrit repository is mirrored at: [http://github.com/cloudfoundry/](https://github.com/cloudfoundry/)

The above workflow is abbreviated. The [official Gerrit documentation](http://gerrit.googlecode.com/svn/documentation/2.0/index.html) contains more information about the [Gerrit workflow](http://source.android.com/source/life-of-a-patch.html)

