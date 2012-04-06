#PHP Support in Cloud Foundry

## **PHP Support**

PHP applications are supported through Apache and mod_php. **PHP support is only available from AppFog.com or in an OSS vcap setup from [https://github.com/cloudfoundry/vcap](https://github.com/cloudfoundry/vcap). It is not available yet in CloudFoundry.com or Micro Cloud Foundry.**


## **Example WordPress app**

Assuming your vcap target supports PHP, you can get started quickly with
wordpress like this:

    
    $ git clone git://github.com/phpfog/af-sample-wordpress.git  
    $ cd af-sample-wordpress   
    $ vmc push wp --url wp.vcap.me –n   
    $ vmc create-service mysql --bind wp

## **Accessing the database**

Cloud Foundry makes the service connection credentials available as JSON via the VCAP_SERVICES environment variable. Using this knowledge, you can use the following snippet in your own PHP code:

    
    $services = getenv("VCAP_SERVICES");  
    $services_json = json_decode($services,true);  
    $mysql_config = $services_json["mysql- 5.1"][0]["credentials"];  
    define('DB_NAME', $mysql_config["name"]);  
    define('DB_USER', $mysql_config["user"]);  
    define('DB_PASSWORD', $mysql_config["password"]);  
    define('DB_HOST', $mysql_config["hostname"]);  
    define('DB_PORT', $mysql_config["port"]);

## **Limitations**

  * Migration workflow, such as that of symfony are not supported.


## **VMC**

To discover and use PHP support, you need VMC version _0.3.14_ or higher:
    
    $ vmc -v
    vmc 0.3.16.beta.5
    
    # to upgrade to the latest version:
    $ gem update vmc

Or install the AppFog client gem `af`:

    $ gem install af

## **Sample Applications**

1. _WordPress PHP App _: [https://github.com/phpfog/af-sample-wordpress](https://github.com/phpfog/af-sample-wordpress)
