# BOSH Command Line Interface #

The BOSH command line interface is used to interact with the BOSH director to perform actions on the cloud.  For the most recent documentation on its functions, install BOSH and simply type `bosh`.  Usage:

    bosh [--verbose] [--config|-c <FILE>] [--cache-dir <DIR]
         [--force] [--no-color] [--skip-director-checks] [--quiet]
         [--non-interactive]
         command [<args>]

Currently available bosh commands are:

    Deployment
      deployment [<name>]       Choose deployment to work with (it also updates
                                current target)
      delete deployment <name>  Delete deployment
                                --force    ignore all errors while deleting
                                           parts of the deployment
      deployments               Show the list of available deployments
      deploy                    Deploy according to the currently selected
                                deployment manifest
                                --recreate recreate all VMs in deployment
      diff [<template_file>]    Diffs your current BOSH deployment
                                configuration against the specified BOSH
                                deployment configuration template so that you
                                can keep your deployment configuration file up to
                                date. A dev template can be found in deployments
                                repos.

    Release management
      create release            Create release (assumes current directory to be a
                                release repository)
                                --force    bypass git dirty state check
                                --final    create production-ready release
                                           (stores artefacts in blobstore,
                                           bumps final version)
                                --with-tarball
                                           create full release tarball(by
                                           default only manifest is created)
                                --dry-run  stop before writing release manifest
                                           (for diagnostics)
      delete release <name> [<version>]
                                Delete release (or a particular release version)
                                --force    ignore errors during deletion
      verify release <path>     Verify release
      upload release [<path>]   Upload release (<path> can point to tarball or
                                manifest, defaults to the most recently created
                                release)
      releases                  Show the list of available releases
      reset release             Reset release development environment (deletes
                                all dev artifacts)

      init release [<path>]     Initialize release directory
      generate package <name>   Generate package template
      generate job <name>       Generate job template

    Stemcells
      upload stemcell <path>    Upload the stemcell
      verify stemcell <path>    Verify stemcell
      stemcells                 Show the list of available stemcells
      delete stemcell <name> <version>
                                Delete the stemcell
      public stemcells          Show the list of publicly available stemcells for
                                download.
      download public stemcell <stemcell_name>
                                Downloads a stemcell from the public blobstore.

    User management
      create user [<name>] [<password>]
                                Create user

    Job management
      start <job> [<index>]     Start job/instance
      stop <job> [<index>]      Stop job/instance
                                --soft     stop process only
                                --hard     power off VM
      restart <job> [<index>]   Restart job/instance (soft stop + start)
      recreate <job> [<index>]  Recreate job/instance (hard stop + start)

    Log management
      logs <job> <index>        Fetch job (default) or agent (if option provided)
                                logs
                                --agent    fetch agent logs
                                --only <filter1>[...]
                                           only fetch logs that satisfy given
                                           filters (defined in job spec)
                                --all      fetch all files in the job or agent log
                                           directory

    Task management
      tasks                     Show the list of running tasks
      tasks recent [<number>]   Show <number> recent tasks
      task [<task_id>|last]     Show task status and start tracking its output
                                --no-cache don't cache output locally
                                --event|--soap|--debug
                                           different log types to track
                                --raw      don't beautify log
      cancel task <id>          Cancel task once it reaches the next cancel
                                checkpoint

    Property management
      set property <name> <value>
                                Set deployment property
      get property <name>       Get deployment property
      unset property <name>     Unset deployment property
      properties                List current deployment properties
                                --terse    easy to parse output

    Maintenance
      cleanup                   Remove all but several recent stemcells and
                                releases from current director (stemcells and
                                releases currently in use are NOT deleted)
      cloudcheck                Cloud consistency check and interactive repair
                                --auto     resolve problems automatically (not
                                           recommended for production)
                                --report   generate report only, don't attempt
                                           to resolve problems

    Misc
      status                    Show current status (current target, user,
                                deployment info etc.)
      vms [<deployment>]        List all VMs that supposed to be in a deployment
      target [<name>] [<alias>] Choose director to talk to (optionally creating
                                an alias). If no arguments given, show currently
                                targeted director
      login [<name>] [<password>]
                                Provide credentials for the subsequent
                                interactions with targeted director
      logout                    Forget saved credentials for targeted director
      purge                     Purge local manifest cache

    Remote access
      ssh <job> [index] [<options>] [command]
                                Given a job, execute the given command or start an
                                interactive session
                                --public_key <file>
                                --gateway_host <host>
                                --gateway_user <user>
                                --default_password
                                           Use default ssh password. Not
                                           recommended.
      scp <job> <--upload | --download> [options] /path/to/source /path/to/destination
                                upload/download the source file to the given job.
                                Note: for dowload /path/to/destination is a
                                directory
                                --index <job_index>
                                --public_key <file>
                                --gateway_host <host>
                                --gateway_user <user>
      ssh_cleanup <job> [index] Cleanup SSH artifacts

    Blob
      upload blob <blobs>       Upload given blob to the blobstore
                                --force    bypass duplicate checking
      sync blobs                Sync blob with the blobstore
                                --force    overwrite all local copies with the
                                           remote blob
      blobs                     Print blob status