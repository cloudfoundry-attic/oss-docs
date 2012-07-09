# Step-by-Step: Adding a System Service to OSS Cloud Foundry

_Author: **Georgi Sabev**_

## Overview

This guide will walk you through the process of adding a new service to your
Cloud Foundry landscape and will show you how to consume it from a web
application. This tutorial is for a [dev_setup installation](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup) of Cloud
Foundry. For the purpose of this guide we have provided a simple echo service
and a simple consumer web application that sends messages to be echoed. Both
are written in java, but you can write your own services in any language you
want and the consuming applications in any language supported by Cloud
Foundry. Each service has a service node, a provisioner and a service gateway.
The service node is the Cloud Foundry service implementation. The provisioner
is the agent that does domain specific actions when the service is being
provisioned or unprovisioned. For example the standard MySQL service creates a
new user and schema when it is provisioned. The service gateway is a REST
interface to the service provisioner. Here is a small picture illustrating
these basic components:

![service_provisioning.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/service_provisioning.png)

## Services in Cloud Foundry

In Cloud Foundry you have two basic states of the services - System services
and Provisioned services. System services are all types of services available
to the system. Services of these types can be provisioned and bound to
applications. When you provision a service you give it a name. This name is
later used by applications to lookup metadata about the provisioned services.
You can list both system and provisioned services by logging in to vmc and
typing `vmc services`:

![services.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/services.png)

## We have included a boilerplate sample service "echo" that you can copy and update for your own use case.

After making echo service out of "excluded components"(see `https://github.com/cloudfoundry/vcap/blob/master/dev_setup/README`) then re-run `.../cloudfoundry/vcap/dev_setup/bin/vcap_dev start`
our echo service will appear as a system service
in the table printed by `vmc services`. This guide can be used for both
single-machine and distributed setup of Cloud Foundry. **Note that by ellipsis
(...) we mean the directory where your Cloud Foundry installation resides.**
Here are the places you need to pay attention to if you would like to build your own service:

1. On the file
	`.../cloudfoundry/.deployments/devbox/config/vcap_components.json`, echo_node and echo_gateway were put in the list:

        {"components":["router","cloud_controller","health_manager","dea","uaa","vcap_redis","serialization_data_server","redis_node","mysql_node","mongodb_node","neo4j_node","rabbitmq_node","postgresql_node","vblob_node","memcached_node","elasticsearch_node","couchdb_node","redis_gateway","mysql_gateway","mongodb_gateway","neo4j_gateway","rabbitmq_gateway","postgresql_gateway","vblob_gateway","memcached_gateway","elasticsearch_gateway","couchdb_gateway","filesystem_gateway","service_broker","backup_manager","snapshot_manager","redis_worker","mysql_worker","mongodb_worker","postgresql_worker", "echo_node", "echo_gateway"]}

2. Service token configuration was put at `.../cloudfoundry/.deployments/devbox/config/cloud_controller.yml`
        
        # Services we provide, and their tokens. Avoids bootstrapping DB.
         builtin_services:
           redis:
             token: changeredistoken
           mongodb:
             token: changemongodbtoken
           mysql:
             token: changemysqltoken
           neo4j:
             token: changeneo4jtoken
           rabbitmq:
             token: changerabbitmqtoken
           postgresql:
             token: changepostgresqltoken
           vblob:
             token: changevblobtoken
           memcached:
             token: changememcachedtoken
           filesystem:
             token: changefilesystemtoken
           elasticsearch:
             token: changeelasticsearchtoken
           couchdb:
             token: changecouchdbtoken
           echo:
             token: changeechotoken

3. On the services host go to
`.../cloudfoundry/vcap/services/tools/misc/bin/nuke_service.rb` 
and you can see the path to the echo service configuration is there:

        default_configs = {
          :mongodb => File.expand_path("../../mongodb/config/mongodb_gateway.yml", __FILE__),
          :redis => File.expand_path("../../redis/config/redis_gateway.yml", __FILE__),
          :mysql => File.expand_path("../../mysql/config/mysql_gateway.yml", __FILE__),
          :neo4j => File.expand_path("../../neo4j/config/neo4j_gateway.yml", __FILE__),
          :vblob => File.expand_path("../../vblob/config/vblob_gateway.yml", __FILE__),
          :echo => File.expand_path("../../echo/config/echo_gateway.yml", __FILE__),
        }

4. On the services host go to 
`.../cloudfoundry/vcap/services/echo` 
and you can see the echo service implementation including codes and config files

    Ensure the echo_gateway and echo_node config files look like the following, with the appropriate IP address and port substitutions:

    `.../cloudfoundry/.deployments/devbox/config/echo_gateway.yml`

        ---  
         cloud_controller_uri: api.vcap.me  
         service:  
           name: echo  
           version: "1.0"  
           description: 'Echo key-value store service'  
           plans: ['free']  
           tags: ['echo', 'echo-1.0', 'echobased', 'demo']
         index: 0  
         token: changeechotoken
         logging:  
           level: debug
         mbus: nats://nats:nats@<nats_host>:<nats_port>/
         pid: /var/vcap/sys/run/echo_service.pid   
         node_timeout: 2 


    `.../cloudfoundry/.deployments/devbox/config/echo_node.yml`

        ---  
        capacity: 100
        plan: free
        local_db: sqlite3:/var/vcap/services/echo/echo_node.db  
        mbus: nats://nats:nats@<nats_host>:<nats_port>/
        index: 0
        base_dir: /var/vcap/services/echo/  
        ip_route: <services_host_ip>  
        logging:  
          level: debug  
        pid: /var/vcap/sys/run/echo_node.pid  
        node_id: echo_node_0
        port: <echo_service_port> # port where echo service listens  
        host: <echo_service_host> # host where echo service resides. May be different from services host

    **Prefer using real IP addresses over localhost as some of these variables may become part of environment on other hosts!**

5. On the services host go to
`.../cloudfoundry/vcap/dev_setup/lib/vcap_components.rb`
and you can see echo was registered as valid component

    https://github.com/cloudfoundry/vcap/blob/master/dev_setup/lib/vcap_components.rb#L399-L406

        ## services: gateways & nodes
        %w(redis mysql mongodb rabbitmq postgresql vblob neo4j memcached couchdb elasticsearch filesystem echo).each do |service|
          ServiceComponent.register("#{service}_gateway")
        end

        %w(redis mysql mongodb rabbitmq postgresql vblob neo4j memcached couchdb elasticsearch echo).each do |service|
          ServiceComponent.register("#{service}_node")
        end

6. Bundle the necessary dependencies for the node and gateway for the new service:

    Take echo service as example:

        $ cd .../cloudfoundry/vcap/services/echo
        $ source $HOME/.cloudfoundry_deployment_profile && bundle package

7. To modify the default exclusion components list, update the component names in `.../cloudfoundry/vcap/dev_setup/lib/vcap_components.rb` then you do not have to use environment variable

        DEFAULT_CLOUD_FOUNDRY_EXCLUDED_COMPONENT = 'neo4j|memcached|couchdb|service_broker|elasticsearch|backup_manager|vcap_redis|worker|snapshot_manager|serialization_data_server|echo'

8. Restart cloud controller, service gateway and node:

        $ .../cloudfoundry/vcap/dev_setup/bin/vcap_dev restart
   
    This should reveal _echo_node_ and _echo_gateway_ running. To review their logs:
   
        $ cd .../cloudfoundry/.deployments/devbox/log && tail -f *.log

    Now execute the command `vmc services`. Our new echo service should be
available in the upper table. Congratulations! You have just provided your
first Cloud Foundry service! Now, let's do something with it!

## Consuming the echo service

1. Provision an echo service by running `vmc create-service echo myecho`.

    This will provision an echo service with the name of 'myecho'. This name will
be used by the test application later on to look up the host and port we
configured fot the echo service. After you provision myecho execute `vmc
services`. This will output something like this:

    ![echo_service.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/echo_service.png)

    Now we have our service provisioned!

  
2. Push a test application and bind the provisioned echo service.

    Download the test application's [.war file](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/testapp.war), or compile from the [source code](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/testapp_src.zip). Place it in an empty folder and deploy with `vmc push`:

        Would you like to deploy from the current directory? [Yn]:  
         Application Name: echotest  
         Application Deployed URL: 'echotest.vcap.me'?  
         Detected a Java Web Application, is this correct? [Yn]:  
         Memory Reservation [Default:512M] (64M, 128M, 256M, 512M or 1G) 64M  
         Creating Application: OK  
         Would you like to bind any services to 'echotest'? [yN]: y  
         Would you like to use an existing provisioned service [yN]? y  
         The following provisioned services are available:  
         1. db 2. myecho  
         Please select one you wish to provision: 2  
         Binding Service: OK  
         Uploading Application:  
           Checking for available resources: OK  
           Processing resources: OK  
           Packing application: OK  
           Uploading (1K): OK  
         Push Status: OK  
         Staging Application: OK  
         Starting Application: OK

    **Note:** if you have other applications in the same directory vmc will sort them in lexicographical order and will opt for the first one. You can use `vmc push <app_name> --path <path_to_app>` instead.

  
3. Start the echo service and access the application.

    So far we have provided the echo service metadata to users and applications in Cloud Foundry, but we haven't started the program which provides the functionality of an echo service itself. The test application obtains the service IP and port from the environment variable `VCAP_SERVICES` &mdash; but it's our responsibility to ensure that there
really is a listening service. Without doing so the application will return an error when attemting to access the echo service. So let's start the service: download the [echo service jar](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/echo_service.jar) to the `host` listed in `echo_node.yml`, or compile it from the [source code](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/echo_service_src.zip). Then execute the following:
  
        $ java -jar echo_service.jar -port <echo_service_port>

    The port you pass as a parameter should be the same as the one you configured in `echo_node.yml` (port 5002 unless the parameter was modified).

    After you have started the service open your favorite web browser and go to
http://echotest.vcap.me or the URI you have chosen when pushing. Enter
some message in the text area and click on the _Echo message_ button. The echo
service will echo your message:

    ![helloworld.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/helloworld.png)
