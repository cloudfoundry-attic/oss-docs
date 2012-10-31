### Deploy to your BOSH Environment ###

With a fully configured environment - having installed BOSH CLI and environment with a BOSH Director, we can begin deploying a Cloud Foundry Release to our environment. 

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

