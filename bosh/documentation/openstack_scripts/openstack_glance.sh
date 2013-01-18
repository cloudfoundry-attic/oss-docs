#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

# get glance
apt-get install glance glance-api glance-client glance-common glance-registry python-glance

. ./stackrc
password=$SERVICE_PASSWORD

# edit glance api conf files 
if [ -f /etc/glance/glance-api-paste.ini.orig ]
then
   echo "#################################################################################################"
   echo "Not changing config files.  If you want to edit, they are in /etc/glance/" 
   echo "#################################################################################################"
else 
   # copy before editing
   cp /etc/glance/glance-api-paste.ini /etc/glance/glance-api-paste.ini.orig
   cp /etc/glance/glance-registry-paste.ini /etc/glance/glance-registry-paste.ini.orig
   cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.orig
   sed -e "
   /^sql_connection =.*$/s/^.*$/sql_connection = mysql:\/\/glance:$password@127.0.0.1\/glance/
   " -i /etc/glance/glance-registry.conf
   
   sed -e "
   s,%SERVICE_TENANT_NAME%,admin,g;
   s,%SERVICE_USER%,admin,g;
   s,%SERVICE_PASSWORD%,$password,g;
   " -i /etc/glance/glance-registry-paste.ini
   
   sed -e "
   s,%SERVICE_TENANT_NAME%,admin,g;
   s,%SERVICE_USER%,admin,g;
   s,%SERVICE_PASSWORD%,$password,g;
   " -i /etc/glance/glance-api-paste.ini
   
# do not unindent!
echo "
[paste_deploy]
flavor = keystone
" >> /etc/glance/glance-api.conf
   
# do not unindent!
echo "
[paste_deploy]
flavor = keystone
" >> /etc/glance/glance-registry.conf

   echo "#################################################################################################"
   echo "Backups of configs for glance are in /etc/glance/" 
   echo "#################################################################################################"
fi

# create db tables and restart
glance-manage version_control 0
glance-manage db_sync
sleep 4
service glance-api restart
service glance-registry restart
sleep 4

# add ubuntu image
if [ -f images/ubuntu-12.04-server-cloudimg-amd64-disk1.img ]
then
  glance add name="Ubuntu 12.04 LTS" is_public=true container_format=ovf disk_format=qcow2 < images/ubuntu-12.04-server-cloudimg-amd64-disk1.img
else
  wget http://stackgeek.s3.amazonaws.com/ubuntu-12.04-server-cloudimg-amd64-disk1.img
  mv ubuntu-12.04-server-cloudimg-amd64-disk1.img images
  glance add name="Ubuntu 12.04 LTS" is_public=true container_format=ovf disk_format=qcow2 < images/ubuntu-12.04-server-cloudimg-amd64-disk1.img
fi

sleep 4
glance index

echo "#################################################################################################"
echo "You can now run './openstack_nova.sh' to set up Nova." 
echo "#################################################################################################"
