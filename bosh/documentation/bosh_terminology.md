# Releases #

A release is a collection of source code, configuration files and startup scripts used to run services, along with a version number that uniquely identifies the components. When creating a new release, you should use a source code manager (like [git](http://git-scm.com/)) to manage new versions of the contained files.

## Release Repository ##

A BOSH Release is built from a directory tree with the contents described in this section. A typical release repository has the following sub-directories:

| Directory 	| Contents 	|
| ------------	| ----------	|
| `jobs` 	| job definitions 	|
| `packages` 	| package definitions 	|
| `config` 	| release configuration files 	|
| `releases` 	| final releases 	|
| `src` 	| source code for packages 	|
| `blobs` 	| large source code bundles 	|

## Jobs ##

Jobs are realization of packages, i.e. running one or more processes from a package. A job contains the configuration files and startup scripts to run the binaries from a package.

There is a *one to many* mapping between jobs and VMs - only one job can run in any given VM, but many VMs can run the same job. E.g. there can be four VMs running the Cloud Controller job, but the Cloud Controller job and the DEA job can not run on the same VM. If you need to run two different processes (from two different packages) on the same VM, you need to create a job which starts both processes.

### Prepare script ###

If a job needs to assemble itself from other jobs (like a super-job) a `prepare` script can be used, which is run before the job is packaged up, and can create, copy or modify files.

### Job templates ###

The job templates are generalized configuration files and scripts for a job, which uses [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html) files to generate the final configuration files and scripts used when a Stemcell is turned into a job.

When a configuration file is turned into a template, instance specific information is abstracted into a property which later is provided when the [director][director] starts the job on a VM. E.g. which port the webserver should run on, or which username and password a databse should use.

The files are located in the `templates` directory and the mapping between template file and its final location is provided in the job `spec` file in the templates section. E.g.

    templates:
      foo_ctl.erb: bin/foo_ctl
      foo.yml.erb: config/foo.yml
      foo.txt: config/foo.txt

### Use of properties ###

The properties used for a job comes from the deployment manifest, which passes the instance specific information to the VM via the [agent][agent].

### "the job of a vm" ###

When a VM is first started, is a Stemcell, which can become any kind of job. It is first when the director instructs the VM to run a job as it will gets its *personality*.

### Monitrc ###

BOSH uses [monit](http://mmonit.com/monit/) to manage and monitor the process(es) for a job. The `monit` file describes how the BOSH [agent][agent] will stop and start the job, and it contains at least three sections:

`with pidfile`
: Where the process keeps its pid file

`start program`
: How monit should start the process

`stop program`
: How monit should stop the process

Usually the `monit` file contain a script to invoke to start/stop the process, but it can invoke the binary directly.

### DNS support ###

TBW

## Packages ###

A package is a collection of source code along with a script that contains instruction how to compile it to binary format and install it, with optional dependencies on other pre-requisite packages.

### Package Compilation ###

Packages are compiled on demand during the deployment. The [director](#bosh-director) first checks to see if there already is a compiled version of the package for the stemcell version it is being deployed to, and if it doesn't already exist a compiled version, the director will instantiate a compile VM (using the same stemcell version it is going to be deployed to) which will get the package source from the blobstore, compile it, and then package the resulting binaries and store it in the blobstore.

To turn source code into binaries, each package has a `packaging` script that is responsible for the compilation, and is run on the compile VM. The script gets two environment variables set from the BOSH agent:

`BOSH_INSTALL_TARGET`
: Tells where to install the files the package generates. It is set to `/var/vcap/data/packages/<package name>/<package version>`.

`BOSH_COMPILE_TARGET`
: Tells the the directory containing the source (it is the current directory when the `packaging` script is invoked).

When the package is installed a symlink is created from `/var/vcap/packages/<package name>` which points to the latest version of the package. This link should be used when refering to another package in the `packaging` script.

There is an optional `pre_packaging` script, which is run when the source of the package is assembled during the `bosh create release`. It can for instance be used to limit which parts of the source that get packages up and stored in the blobstore. It gets the environment variable `BUILD_DIR` set by the [BOSH CLI](#bosh-cli), which is the directory containing the source to be packaged.

### Package specs ###

The package contents are specified in the `spec` file, which has three sections:

`name`
: The name of the package.

`dependencies`
: An optional list of other packages this package depends on, [see below][Dependencies].

`files`
: A list of files this package contains, which can contain globs. A `*` matches any file and can be restricted by other values in the glob, e.g. `*.rb` only matches files ending with `.rb`. A `**` matches directories recursively.

### Dependencies ###

The package `spec` file contains a section which lists other packages the current package depends on. These dependencies are compile time dependencies, as opposed to the job dependencies which are runtime dependencies.

When the [director](#bosh-director) plans the compilation of a package during a deployment, it first makes sure all dependencies are compiled before it proceeds to compile the current package, and prior to commencing the compilation all dependent packages are installed on the compilation VM.

## Sources ##

The `src` directory contains the source code for the packages.

If you are using a source code repository to manage your release, you should avoid storing large objects in it (like source code tar-balls in the `src` directory), and instead use the [blobs](#blobs) described below.

## Blobs ##

To create final releases you need to configure your release repository with a blobstore. This is where BOSH will upload the final releases to, so that the release can later be retreived from another computer.

To prevent the release repository from becoming bloated with large binary files (source tar-balls), large files can be placed in the `blobs` directory, and then uploaded to the blobstore.

For production releases you should use either the Atmos or S3 blobstore and configure them as described below.

### Atmos ###

Atmos is a shared storage solution from EMC. To use Atmos, edit `config/final.tml` and `config/private.yml`, and add the following (replacing the `url`, `uid` and `secret` with your account information):

File `config/final.yml`

    ---
    blobstore:
      provider: atmos
      options:
        tag: BOSH
        url: https://blob.cfblob.com
        uid: 1876876dba98981ccd091981731deab2/user1

File `config/private.yml`

    ---
    blobstore_secret: ahye7dAS93kjWOIpqla9as8GBu1=

### S3 ###

To use S3, a shared storage solution from Amazon, edit `config/final.tml` and `config/private.yml`, and add the following (replacing the `access_key_id`, `bucket_name`, `encryption_key` and `secret_access_key` with your account information):

File `config/final.yml`

    ---
    blobstore:
      provider: s3
      options:
        access_key_id: KIAK876234KJASDIUH32
        bucket_name: 87623bdc
        encryption_key: sp$abcd123$foobar1234

File `config/private.yml`

    ---
    blobstore_secret: kjhasdUIHIkjas765/kjahsIUH54asd/kjasdUSf

### Local ###

If you are trying out BOSH and don't have an Atmos or S3 account, you can use the local blobstore provider (which stored the files on disk instead of a remote server).

File `config/final.yml`

    ---
    blobstore:
      provider: local
      options:
        blobstore_path: /path/to/blobstore/directory

Note that local should **only** be used for testing purposes as it can't be shared with others (unless they run on the same system).

## Configuring Releases ##

Initial release configuration can be performed using `bosh init release command` in an empty git repo. This will create a number of directories that can be used to keep jobs, packages and sources.

## Building Releases ##

To create a new release use the `bosh create release` command. This will attempt to create a new release from the contents of the release repo. Here's what happens:

* BOSH CLI identifies it's in a release repo directory and tries to find all jobs and packages in that repo. Then, for each artifact (package/job):
	1. The fingerprint is built using artifact contents, file permissions and some other trackable data.
	2. BOSH CLI tries to find the 'final' version of the artifact matching that fingerprint. All 'final' versions are supposed to be shared through a blobstore, with blobstore id being tracked in release repo. Once required blobstore id is found, CLI tries to either find the actual artifact in a local cache, and if it's missing or has a checksum mismatch, it fetches it from the blobstore (saving in a local cache afterwards).
	3. If no final version is found, CLI tries to find dev version in a local cache. Dev versions are specific to a local copy of a release repo on a developer box, so no downloads are attempted, it's either available locally or not.
	4. If the artifact (either dev or final) has been found, CLI uses the version associated with that artifact. The whole process in steps 1-4 is then essentially a lookup of the tarball and its version by a calculated fingerprint. Any change in package/job is supposed to change its fingerprint and this triggers step 5 (generating a new version).
	5. If new artifact version needs to be generated, CLI uses its spec file to understand what needs to be included into the resulting tarball. For packages it resolves dependencies, copies matched files and runs `pre_packaging` script if available. For jobs it checks that all included packages and configurations templates are present. If all checks have passed, CLI generates and packs a new artifact tarball and assigns it a new version (see release versioning below).
* At this point all packages and jobs have been generated and CLI has references to them. The only remaining step is to generate a release manifest, binding all these jobs and packages together. The resulting YAML file is saved and path is provided to CLI user. This path can be used with `bosh upload release`  command to upload release to BOSH Director.

## Final Releases & release versioning ##

The final release can be created once all the changes are tested and it's time to actually deploy a release to production. The are there main criteria differentiating final releases from dev releases:

1. *Versioning scheme*: final releases are version independently. Every time new final release is generated its version is a simple increment of the previous final release version, no matter how many dev releases have been created in between. Same is true for individual release artifacts, their final versions are independent from dev versions.
2. *Blobs sharing*: package and job tarballs included into the final release are also being uploaded to a blobstore, so any person who attempts create release in the same release repo in the future will be using same actual bits instead of generating them locally. This is important for consistency and for being able to generate old versions of final releases if needed.
3. *Only reusing components, not generating new ones*: final release is supposed to include only previously generated artifacts. If the fingerprint calculated from the current state of the repo didn't match previously generated dev or final version, the error will be raised, telling CLI user to make sure to generate and test dev release first.

Final release can be created by running `bosh create release --final`. Usually only people involved in updating production system should be generating final releases. There's also a `--dry-run` option to test out release creation without actually generating and uploading artifacts.

By default all artifacts are stored in `.final_builds` directory inside the release repo, while release manifests are kept in `releases` directory. If the actual release tarball is required `bosh create release --with tarball` can be used. Also, `bosh create release /path/to/release_manifest.yml` can be used to recreate previously created release from its manifest. In both cases the output is a self-contained, ready-to-upload release tarball.

Dev release artifacts versioning is slightly different from final: the latest generated final version of the artifact is used as major version of dev build, while the actual build revision is used as minor version.

An example is as follows:

1. There is a cloud_controller package in release repo: no dev version, no final version yet.
2. `bosh create release` runs for the first time
3. Now there is dev release 1, cloud_controller now has dev version 0.1, no final version yet
4. `bosh create release` is a no-op now, unless we make some repo changes. 
5. Someone edits one or more files matched by cloud_controller package.
6. `bosh create release` now generates dev release 2, cloud_controller has dev version 0.2, no final version yet.
7. `bosh create release --final` will now create final release 1, cloud_controller has dev version 0.2, which also gets rebranded as final version 1.
8. Next edits to cloud_controller will subsequently generate dev version 1.1, 1.2 etc., until new final version is created

The main point of this versioning scheme is to partition release engineering process between two audiences:

1. Developers who are quickly iterating on their changes and don't really care about keeping consistent versioning of Bosh Release, BOSH CLI takes care of all versioning details for them and prevents others from seeing all the work-in-progress releases.
2. SREs who are actually building releases for production use and want them to be consistently versioned and source controlled.

## Setting up a new release repository using S3 ##

The following instructions require that you use BOSH cli version 0.19.6 or later.

To publish a BOSH release repository you need to do two things:
1. make the repository available using git
   e.g. on [github](https://github.com/)
2. make the final jobs and packages available
   e.g. using [S3](http://aws.amazon.com/s3/)

In this blog post the [bosh-sample-release](https://github.com/cloudfoundry/bosh-sample-release) is used as an example of how you setup a BOSH release repository with publicly available final jobs and packages. The text in <span style="color: red;">red</span> needs to be replaced with your specific information, e.g. Amazon access key id and bucket name.

First you need to create a new user in Amazon IAM that will be able to upload data to S3, then create a S3 bucket where the final objects are going to be stored.

Then set a bucket policy that allows anonymous users (anyone) to get objects from the bucket:

```{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<code style="color: red;">bosh-sample-release</code>/*"
    }
  ]
}```

Initialize a new release repository:

    bosh init release <code style="color: red;">bosh-sample-release</code> --git

In your release repository, create the file `config/final.yml` with the contents:

```---
final_name: wordpress
min_cli_version: 0.19.6
blobstore:
  provider: s3
  options:
    bucket_name: <code style="color: red;">bosh-sample-release</code>```

Next create the file `private.yml` somewhere **outside** of the repository and create a soft link to it in the `config` directory. This is to prevent you from accidentally committing the S3 credentials to the repository and thus exposing secret information.

```---
blobstore:
  s3:
    secret_access_key: <code style="color: red;"> EVGFswlmOvA33ZrU1ViFEtXC5Sugc19yPzokeWRf</code>
    access_key_id: <code style="color: red;"> AKIAIYJWVDUP4KRWBESQ</code>```

Now you need to commit the changes to the repository

    git add .
    git commit -m 'initial commit'

Create some jobs and packages

    bosh generate package foo
    bosh generate job bar

Create a dev release. The `--force` option is needed as you have uncommitted changes in the repository.

    bosh create release --force

Once you are satisfied with your changes, commit them and build the final release.

    git add .
    git commit -m 'added package foo and job bar'
    bosh create release --final

This uploads the final packages and jobs to S3, and stores references to them in your release repository. These references need to be committed too.

    git add .
    git commit -m 'release #1'
