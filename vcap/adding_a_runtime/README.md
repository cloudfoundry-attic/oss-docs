# Adding a Runtime to OSS Cloud Foundry

_Author: **Jennifer Hickey**_

This document explains how to add a runtime for use by an existing framework in a [dev_setup installation](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup) of Cloud
Foundry.  Please look [here](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_framework) for instructions on adding a framework.

This document will illustrate the steps required to add a new runtime by using the example of adding Ruby 1.9.3.

All modifications described below should be made in the [vcap repo](https://github.com/cloudfoundry/vcap).

## Add or Modify a Cookbook to Install the Runtime
Since we are adding a new version of an existing runtime, we need to modify the Ruby cookbook found in dev_setup/cookbooks/ruby.

1. Add a recipe

   In reality, you would likely install additional tools such as Rubygems, Bundler, and Rake.  For this example, we will install only Ruby 1.9.3.

   The existing recipes in the ruby cookbook use binaries stored in the Cloud Foundry blobstore.  As the public cannot upload to this blobstore, we recommend writing your recipes to download binaries from URLs using Chef's [Remote File](http://wiki.opscode.com/display/chef/Resources#Resources-RemoteFile) provider.  When you contribute your code to Cloud Foundry, we will modify the code to use the blobstore as necessary.

   dev_setup/cookbooks/ruby/recipes/ruby193.rb:
   ```
   ruby_path = node[:ruby193][:path]
   ruby_version = node[:ruby193][:version]
   ruby_tarball_path = File.join(node[:deployment][:setup_cache], "ruby-#{ruby_version}.tar.gz")

   remote_file ruby_tarball_path do
     owner node[:deployment][:user]
     source node[:ruby193][:source]
     checksum node[:ruby193][:checksums][node[:ruby193][:version]]
   end

   directory ruby_path do
     owner node[:deployment][:user]
     group node[:deployment][:group]
     mode "0755"
     recursive true
     action :create
   end

   bash "Install Ruby #{ruby_path}" do
     cwd File.join("", "tmp")
     user node[:deployment][:user]
     code <<-EOH
     # work around chef's decompression of source tarball before a more elegant
     # solution is found
     tar xzf #{ruby_tarball_path}

     cd ruby-#{ruby_version}
     # See http://deadmemes.net/2011/10/28/rvm-install-fails-on-ubuntu-11-10/
     sed -i 's/\\(OSSL_SSL_METHOD_ENTRY(SSLv2[^3]\\)/\\/\\/\\1/g' ./ext/openssl/ossl_ssl.c
     ./configure --disable-pthread --prefix=#{ruby_path}
     make
     make install
     EOH
   end
   ```
   The above recipe refers to attributes that should be defined in dev_setup/cookbooks/ruby/attributes/ruby193.rb:
   ```
   include_attribute "deployment"

   default[:ruby193][:version] = "1.9.3-p194"
   default[:ruby193][:source]  = "http://ftp.ruby-lang.org//pub/ruby/1.9/ruby-#{ruby193[:version]}.tar.gz"
   default[:ruby193][:path]    = File.join(node[:deployment][:home], "deploy", "rubies", "ruby-#{ruby193[:version]}")
   default[:ruby193][:checksums]["1.9.3-p194"] = "46e2fa80be7efed51bd9cdc529d1fe22ebc7567ee0f91db4ab855438cf4bd8bb"
   ```
   The checksum of the binary can be calculated using the "sha256sum" command.

## Add Runtime Metadata


1. Add an entry to dev_setup/cookbooks/cloud_controller/templates/default/runtimes.yml.erb

   ```
   ruby193:
     version: "1.9.3p194"
     description: "Ruby 1.9.3"
     executable: "<%= File.join(node[:ruby193][:path], "bin", "ruby") %>"
     version_flag: "-e 'puts RUBY_VERSION'"
     additional_checks: "-e 'puts RUBY_PATCHLEVEL >= 194'"
     version_output: 1.9.3
     environment:
       PATH: <%= File.join(node[:ruby193][:path], "bin") %>:$PATH
   ```
   Required attributes: version, description, executable, version_output

   Optional attributes: version_flag (default is -v), additional_checks, environment

   The key we choose ("ruby193") will be the name that users must specify when selecting the runtime.  This name, along with version and description, are used for display by "vmc   runtimes".

   The remaining attributes are used by the DEA and may also be used by the Stager.  The DEA will run the specified executable with the specified version_flag to verify that it has the expected version of the runtime (output should contain the specified version_output).  Here, the optional additional_checks field is used to perform additional validation.  Finally, the environment specified will be passed as environment variables to an application using this runtime.

   If you are writing or modifying a plugin for [framework support](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_framework), you may choose to add additional attributes for use by the Stager.

2. Add runtimes to frameworks

   Runtimes must be added to a framework's staging manifest in order to be used.  In this case, we will make Ruby 1.9.3 available to standalone apps by modifying dev_setup/cookbooks/cloud_controller/templates/default/standalone.yml.erb:
   ```
   runtimes:
  - "ruby193"
     default: false

## Add the Runtime to the DEA

1. Add the runtime to DEA attributes

   In dev_setup/cookbooks/dea/attributes/default.rb:
   ```
   default[:dea][:runtimes] = ["ruby18", "ruby19", "ruby193", "node04", "node06", "node08", "java", "java7", "erlang", "php", "python2"]
   ```

2. Enable the recipe

   Add the new recipe to dev_setup/cookbooks/dea/recipes/default.rb
   ```
   node[:dea][:runtimes].each do |runtime|
     case runtime
     when "ruby193"
       include_recipe "ruby::ruby193"
   ```

3. Add the runtime to DEA config

   The DEA only allows apps to be deployed with runtimes listed in dea.yml.

   Modify dev_setup/cookbooks/dea/templates/default/dea.yml.erb:
   ```
   runtimes:
   <% if node[:dea][:runtimes].include?("ruby193") %>
     - ruby193
   <% end %>
   ```

## Try it out
Once we have successfully run dev_setup, we can use vmc to verify that the runtime has been added. "vmc runtimes" should list the runtime info.  Note that the current stable version of vmc requires a runtime to be added to at least one framework in order to be listed.

We should be able to push a simple standalone Ruby application using vmc.  Here is an application that simply outputs the Ruby version and then sleeps indefinitely:

```
$ more simple.rb
puts "Running Ruby #{RUBY_VERSION}"
sleep

$ vmc push
Would you like to deploy from the current directory? [Yn]:
Application Name: simple
Detected a Standalone Application, is this correct? [Yn]:
...
11: ruby193
Select Runtime [ruby18]: 11
Selected ruby193
Start Command: ruby simple.rb
Application Deployed URL [None]:
Memory reservation (128M, 256M, 512M, 1G, 2G) [128M]:
How many instances? [1]:
Bind existing services to 'simple'? [yN]:
Create services to bind to 'simple'? [yN]:
Would you like to save this configuration? [yN]:
Creating Application: OK
Uploading Application:
  Checking for available resources: OK
  Packing application: OK
  Uploading (0K): OK
Push Status: OK
Staging Application 'simple': OK
Starting Application 'simple': OK

$ vmc logs simple
====> /logs/stdout.log <====

Running Ruby 1.9.3
```