#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

host_ip=$(/sbin/ifconfig eth0| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')
echo "#############################################################################################################"
echo "The IP address for eth0 is probably $host_ip".  Keep in mind you need an eth1 for this to work.
echo "#############################################################################################################"
read -p "Enter the primary ethernet interface IP: " host_ip_entry
read -p "Enter the fixed network (eg. 10.0.2.32/27): " fixed_range
read -p "Enter the fixed starting IP (eg. 10.0.2.33): " fixed_start
echo "#######################################################################################"
echo "The floating range can be a subset of your current network.  Configure your DHCP server"
echo "to block out the range before you choose it here.  An example would be 10.0.1.224-255"
echo "#######################################################################################"
read -p "Enter the floating network (eg. 10.0.1.224/27): " floating_range
read -p "Enter the floating netowrk size (eg. 32): " floating_size

# get nova
apt-get install nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-vncproxy nova-volume python-nova python-novaclient

. ./stackrc
password=$SERVICE_PASSWORD

# hack up the nova paste file
sed -e "
s,%SERVICE_TENANT_NAME%,admin,g;
s,%SERVICE_USER%,admin,g;
s,%SERVICE_PASSWORD%,$password,g;
" -i /etc/nova/api-paste.ini
 
# write out a new nova file
echo "
--dhcpbridge_flagfile=/etc/nova/nova.conf
--dhcpbridge=/usr/bin/nova-dhcpbridge
--logdir=/var/log/nova
--state_path=/var/lib/nova
--lock_path=/var/lock/nova
--allow_admin_api=true
--use_deprecated_auth=false
--auth_strategy=keystone
--scheduler_driver=nova.scheduler.simple.SimpleScheduler
--s3_host=$host_ip_entry
--ec2_host=$host_ip_entry
--rabbit_host=$host_ip_entry
--cc_host=$host_ip_entry
--nova_url=http://$host_ip_entry:8774/v1.1/
--routing_source_ip=$host_ip_entry
--glance_api_servers=$host_ip_entry:9292
--image_service=nova.image.glance.GlanceImageService
--iscsi_ip_prefix=192.168.22
--sql_connection=mysql://nova:$password@127.0.0.1/nova
--ec2_url=http://$host_ip_entry:8773/services/Cloud
--keystone_ec2_url=http://$host_ip_entry:5000/v2.0/ec2tokens
--api_paste_config=/etc/nova/api-paste.ini
--libvirt_type=kvm
--libvirt_use_virtio_for_bridges=true
--start_guests_on_host_boot=true
--resume_guests_state_on_host_boot=true
--vnc_enabled=true
--vncproxy_url=http://$host_ip_entry:6080
--vnc_console_proxy_url=http://$host_ip_entry:6080
# network specific settings
--network_manager=nova.network.manager.FlatDHCPManager
--public_interface=eth0
--flat_interface=eth1
--flat_network_bridge=br100
--fixed_range=$fixed_range
--floating_range=$floating_range
--network_size=$floating_size
--flat_network_dhcp_start=$fixed_start
--flat_injected=False
--force_dhcp_release
--iscsi_helper=tgtadm
--connection_type=libvirt
--root_helper=sudo nova-rootwrap
--verbose
" > /etc/nova/nova.conf

# sync db
nova-manage db sync

# restart nova
./openstack_restart_nova.sh

# no clue why we have to do this when it's in the config?
nova-manage network create private --fixed_range_v4=$fixed_range --num_networks=1 --bridge=br100 --bridge_interface=eth1 --network_size=$fixed_size
nova-manage floating create --ip_range=$floating_range

# do we need this?
chown -R nova:nova /etc/nova/

echo "#######################################################################################"
echo "'nova list' and a 'nova image-list' to test.  Do './openstack_horizon.sh' next."
echo "#######################################################################################"

