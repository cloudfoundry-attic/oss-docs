# BOSH Troubleshooting #

## BOSH SSH ##

To ssh to a running Job, first find the name and index of it.  Use `bosh vms` to display a list of the VMs that are running and what Job is on each.  To ssh to it, run `bosh ssh <job_name> <index>`.  The password is whatever is set in the Stemcell.  For default Stemcells it is cloudc0w.

## BOSH Logs ##

When troubleshooting BOSH or BOSH deployments, it's important to read log files so that problems can be narrowed down.  There are three types of logs.

1. BOSH Director logs, via `bosh task <task_number>`

    This contains the output from the BOSH Director whenever a BOSH command is run on it.  If there is an issue when running a BOSH command, these logs are where you should start.  For instance, if you run `bosh deploy` and it fails, then the BOSH Director will have a log of where things went wrong.  To access these logs, find the task number of the failed command by running `bosh tasks recent`.  Then, run `bosh task <task_number>`.  The Director's logger writes to the logs.

1. Agent logs, in `/var/vcap/bosh/log` or via `bosh logs`

    These logs contain the output from the agents.  When an issue with VM setup is suspected, these logs are useful.  They will show the actions of the agent, such as setting up network, disks, and running the Job.  If a `bosh deploy` fails because one of the VMs is having a problem, you will want to use the BOSH Director logs to find which machine it was. Then, either ssh and access `/var/vcap/bosh/log` or use `bosh logs <job_name> <index> --agent`.

1. Service logs

    These are the logs produced by the actual jobs running on VMs.  These may be logs produced by Redis, or a webserver, etc….  These logs will vary because it is up to the Deployment to configure where they are output to.  Typically, the output path is defined in a config file in `release/jobs/<job_name>/templates/<config_file>`.  For Cloud Foundry, our Jobs are typically configured to log to `/var/vcap/sys/log/<job_name>/<job_name>.log`.  These logs can also be accessed via `bosh logs <job_name> <index>`.

## BOSH Cloud Check ##

BOSH cloud check is a BOSH command line utility that automatically checks for problems in VMs and Jobs that have been deployed.  It checks for things such as unresponsive/out-of-sync VMs, unbound disks, etc.  To use it, run `bosh cck` and it will prompt you for actions to take if there are any problems found.
