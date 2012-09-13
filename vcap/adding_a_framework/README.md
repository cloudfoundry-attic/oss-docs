# Adding a Framework to OSS Cloud Foundry

_Author: **Jennifer Hickey**_

This document explains how to add a framework in a [dev_setup installation](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup) of Cloud
Foundry.

## Create a Staging Plugin
Each framework should have a staging plugin.  Staging plugins should extend the [StagingPlugin](https://github.com/cloudfoundry/vcap-staging/blob/master/lib/vcap/staging/plugin/common.rb) class and should be named FrameworknamePlugin.  Take a look at the [Sinatra plugin](https://github.com/cloudfoundry/vcap-staging/blob/master/lib/vcap/staging/plugin/sinatra/plugin.rb) for an example.

1. Implement required methods

   The new staging plugin must implement the stage_application method.  The stage_application method should include all functionality needed to copy the application to the staged area and create start and stop scripts.  This is typically accomplished by calling methods such as create_app_directories, copy_source_files, create_startup_script, and create_stop_script.

   Most plugins also implement the start_command method, which is called by create_startup_script.  The Sinatra plugin also overrides the startup_script method in order to add extra environment variables to the app startup script.  Again, the main goal of the staging plugin is to create a directory that contains the application and its start and stop scripts.  Along the way, the plugin may add some helper functionality such as installing the user's gems, running database migrations, or automatically configuring database connections.

2. Test and build the staging plugin

   You can include your staging plugin in the vcap-staging gem if you wish to keep your own branch (or contribute your plugin back to Cloud Foundry), or you can create your own gem to house your staging plugin.  The vcap-staging repo contains a test harness that makes it easy to unit test your new plugins.  See the [Sinatra spec](https://github.com/cloudfoundry/vcap-staging/blob/master/spec/unit/sinatra_spec.rb) for an example.

   Run "bundle exec rake build" to build the vcap-staging gem.

3. Install the staging plugin

   Staging plugins are loaded by the [Stager](https://github.com/cloudfoundry/stager).  Add your custom gem or update the vcap-staging gem version in the Stager's Gemfile to make the plugin available.

## Create a Staging Manifest
Each framework should have a manifest defined in the [dev_setup Cloud Controller cookbook](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/cookbooks/cloud_controller/templates/default).  Here are the contents of sinatra.yml.erb:
```
name: "sinatra"
runtimes:
  - "ruby18":
      default: true
  - "ruby19":
     default: false
detection:
  - "*.rb": "\\s*require[\\s\\(]*['\"]sinatra['\"(/base['\"])]" # .rb files in the root dir containing a require?
  - "config/environment.rb": false # and config/environment.rb must not exist
```
The framework name is the name that users must specify when selecting the framework.  It must also match the name of the StagingPlugin class.  A framework must support at least one runtime.  If the framework has a default runtime, users are not required to select a runtime when pushing an app of that framework type.  Lastly, a framework can define detection rules. New versions of vmc use these detection rules to automatically select a default framework for an application.  Staging plugins may use these detection rules as well.  The Sinatra plugin uses the first detection rule to choose the main file to run.

Ensure the manifest is copied to the appropriate location by modifying dev_setup/cookbooks/cloud_controller/attributes/default.rb.

```
default[:cloud_controller][:staging][:sinatra] = "sinatra.yml"
```

## Try it Out
Once you have successfully run [dev_setup](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup), use vmc to verify that the framework has been added. "vmc frameworks" should list the framework info. If you are using a beta version of vmc (installed by gem install vmc --pre), the framework should be automatically available for selection, and the detection rules should be applied.  Older versions of vmc require modification of [frameworks.rb](https://github.com/cloudfoundry/vmc/blob/master/lib/cli/frameworks.rb)