# Deploying to AWS using BOSH

The BOSH cloud provider interface for AWS allows BOSH to deploy to AWS.

## AWS cloud properties

The cloud properties specific to AWS are

### Resource pools

1. `key_name`

1. `availability_zone`

1. `instance_type`

### Networks

1. `type`

1. `ip`

## Security concern deploying Cloud Foundry to AWS

If you deploy [Cloud Foundry](https://github.com/cloudfoundry/cf-release) to AWS using BOSH, 
the deployment property `nfs_server.network` needs to be set to `*` (or `10/8`) as we don't 
have a way to limit the list of IPs belonging to the deployment. To limit access, create and use a security group.

