# Deploy BOSH as an application using micro BOSH. #

1. Deploy micro BOSH. See the steps in the previous section.

1. Once your micro BOSH instance is deployed, you can target its Director:

		$ bosh micro status
		...
		Target         micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)

		$ bosh target http://11.23.194.100:25555
		Target set to 'micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)'

		$ bosh status
		Updating director data... done

		Target         micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)
		UUID           b599c640-7351-4717-b23c-532bb35593f0
		User           admin
		Deployment     not set

### Download a BOSH stemcell

1. List public stemcells with bosh public stemcells

		% mkdir -p ~/stemcells
		% cd stemcells
		% bosh public stemcells
		+-------------------------------+----------------------------------------------------+
		| Name                          | Url                                                |
		+-------------------------------+----------------------------------------------------+
		| bosh-stemcell-0.4.7.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...h120= |
		| micro-bosh-stemcell-0.1.0.tgz | https://blob.cfblob.com/rest/objects/4e4e7...5Mms= |
		| bosh-stemcell-0.3.0.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...mw1w= |
		| bosh-stemcell-0.4.4.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...r144= |
		+-------------------------------+----------------------------------------------------+
		To download use 'bosh download public stemcell <stemcell_name>'.


1. Download a public stemcell. *NOTE, in this case you do not use the micro bosh stemcell.*

		bosh download public stemcell bosh-stemcell-0.1.0.tgz

1. Upload the downloaded stemcell to micro BOSH.

		bosh upload stemcell bosh-stemcell-0.1.0.tgz

### Upload a BOSH release ###

1. You can create a BOSH release or use one of the public releases. The following steps show the use of a public release.

		cd /home/bosh_user
		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/bosh-release.git

1. Upload a public release from bosh-release

		cd /home/bosh_user/bosh-release/releases/
		bosh upload release bosh-1.yml


### Setup a BOSH deployment manifest and deploy ###

1. Create and setup a BOSH deployment manifest. Look at the sample BOSH manifest in (https://github.com/cloudfoundry/oss-docs/bosh/samples/bosh.yml). Assuming you have created a `bosh.yml` in `/home/bosh_user`.

		cd /home/bosh_user
		bosh deployment ./bosh.yml

1. Deploy BOSH

		bosh deploy.

1. Target the newly deployed bosh director. In the sample `bosh.yml`, the bosh director has the ip address 192.0.2.36. So if you target this director with `bosh target http://192.0.2.36:25555` where 25555 is the default BOSH director port.  Your newly installed BOSH instance is now ready for use.