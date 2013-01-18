#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

# get keystone
apt-get install keystone python-keystone python-keystoneclient

read -p "Enter a token for the OpenStack services to auth with keystone: " token
read -p "Enter the password you used for the MySQL users (nova, glance, keystone): " password
read -p "Enter the email address for service accounts (nova, glance, keystone): " email

# set up env variables for testing
cat > stackrc <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$password
export OS_AUTH_URL="http://127.0.0.1:5000/v2.0/" 
export ADMIN_PASSWORD=$password
export SERVICE_PASSWORD=$password
export SERVICE_TOKEN=$token
export SERVICE_ENDPOINT="http://127.0.0.1:35357/v2.0"
export SERVICE_TENANT_NAME=service
EOF

. ./stackrc

# edit keystone conf file to use templates and mysql
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.orig
sed -e "
/^admin_token = ADMIN/s/^.*$/admin_token = $token/
/^driver = keystone.catalog.backends.sql.Catalog/d
/^\[catalog\]/a driver = keystone.catalog.backends.templated.TemplatedCatalog 
/^\[catalog\]/a template_file = /etc/keystone/default_catalog.templates
/^connection =.*$/s/^.*$/connection = mysql:\/\/keystone:$password@127.0.0.1\/keystone/
" -i /etc/keystone/keystone.conf

# create db tables and restart
keystone-manage db_sync
service keystone restart


# sleep a bit before we whack on it
sleep 5

ADMIN_PASSWORD=$password
SERVICE_PASSWORD=$password
export SERVICE_TOKEN=$token
export SERVICE_ENDPOINT="http://localhost:35357/v2.0"
SERVICE_TENANT_NAME="service"

function get_id () {
    echo `$@ | awk '/ id / { print $4 }'`
}

# Tenants
ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)
SERVICE_TENANT=$(get_id keystone tenant-create --name=$SERVICE_TENANT_NAME)
DEMO_TENANT=$(get_id keystone tenant-create --name=demo)
INVIS_TENANT=$(get_id keystone tenant-create --name=invisible_to_admin)


# Users
ADMIN_USER=$(get_id keystone user-create --name=admin \
                                         --pass="$ADMIN_PASSWORD" \
                                         --email=$email)
DEMO_USER=$(get_id keystone user-create --name=demo \
                                        --pass="$ADMIN_PASSWORD" \
                                        --email=$email)


# Roles
ADMIN_ROLE=$(get_id keystone role-create --name=admin)
KEYSTONEADMIN_ROLE=$(get_id keystone role-create --name=KeystoneAdmin)
KEYSTONESERVICE_ROLE=$(get_id keystone role-create --name=KeystoneServiceAdmin)
# ANOTHER_ROLE demonstrates that an arbitrary role may be created and used
# TODO(sleepsonthefloor): show how this can be used for rbac in the future!
ANOTHER_ROLE=$(get_id keystone role-create --name=anotherrole)


# Add Roles to Users in Tenants
keystone user-role-add --user $ADMIN_USER --role $ADMIN_ROLE --tenant_id $ADMIN_TENANT
keystone user-role-add --user $ADMIN_USER --role $ADMIN_ROLE --tenant_id $DEMO_TENANT
keystone user-role-add --user $DEMO_USER --role $ANOTHER_ROLE --tenant_id $DEMO_TENANT

# TODO(termie): these two might be dubious
keystone user-role-add --user $ADMIN_USER --role $KEYSTONEADMIN_ROLE --tenant_id $ADMIN_TENANT
keystone user-role-add --user $ADMIN_USER --role $KEYSTONESERVICE_ROLE --tenant_id $ADMIN_TENANT


# The Member role is used by Horizon and Swift so we need to keep it:
MEMBER_ROLE=$(get_id keystone role-create --name=Member)
keystone user-role-add --user $DEMO_USER --role $MEMBER_ROLE --tenant_id $DEMO_TENANT
keystone user-role-add --user $DEMO_USER --role $MEMBER_ROLE --tenant_id $INVIS_TENANT


# Configure service users/roles
NOVA_USER=$(get_id keystone user-create --name=nova \
                                        --pass="$SERVICE_PASSWORD" \
                                        --tenant_id $SERVICE_TENANT \
                                        --email=$email)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $NOVA_USER \
                       --role $ADMIN_ROLE

GLANCE_USER=$(get_id keystone user-create --name=glance \
                                          --pass="$SERVICE_PASSWORD" \
                                          --tenant_id $SERVICE_TENANT \
                                          --email=$email)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $GLANCE_USER \
                       --role $ADMIN_ROLE

if [[ "$ENABLED_SERVICES" =~ "swift" ]]; then
    SWIFT_USER=$(get_id keystone user-create --name=swift \
                                             --pass="$SERVICE_PASSWORD" \
                                             --tenant_id $SERVICE_TENANT \
                                             --email=$email)
    keystone user-role-add --tenant_id $SERVICE_TENANT \
                           --user $SWIFT_USER \
                           --role $ADMIN_ROLE
    # Nova needs ResellerAdmin role to download images when accessing
    # swift through the s3 api. The admin role in swift allows a user
    # to act as an admin for their tenant, but ResellerAdmin is needed
    # for a user to act as any tenant. The name of this role is also
    # configurable in swift-proxy.conf
    RESELLER_ROLE=$(get_id keystone role-create --name=ResellerAdmin)
    keystone user-role-add --tenant_id $SERVICE_TENANT \
                           --user $NOVA_USER \
                           --role $RESELLER_ROLE
fi

if [[ "$ENABLED_SERVICES" =~ "quantum" ]]; then
    QUANTUM_USER=$(get_id keystone user-create --name=quantum \
                                               --pass="$SERVICE_PASSWORD" \
                                               --tenant_id $SERVICE_TENANT \
                                               --email=$email)
    keystone user-role-add --tenant_id $SERVICE_TENANT \
                           --user $QUANTUM_USER \
                           --role $ADMIN_ROLE
fi

echo "######################################################################################"
echo "Time to test keystone.  Do a '. ./stackrc' then a 'keystone user-list'."
echo "Assuming you get a user list back, go on to install glance with './openstack_glance.sh'."
echo "######################################################################################"
