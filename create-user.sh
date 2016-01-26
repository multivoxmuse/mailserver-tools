#!/bin/bash

set -e
# set -x

# Create variables
EMAIL="$1"
DOMAIN="1"

# Verify email against domain ID
get_domain_sql="SELECT name FROM virtual_domains WHERE id = $DOMAIN"
DOMAIN_ID=1

# Create the password hash and set it to a variable
echo Creating user "$1" password ...
DEFAULTPW="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
PWHASH="$(doveadm pw -s SHA512-CRYPT -p $DEFAULTPW)"
HASH_TRUNC=${PWHASH:14}

# Create the user in the db
echo Creating user in db
SQL="INSERT INTO virtual_users (domain_id, email, password) VALUES ('$DOMAIN', '$EMAIL', '$HASH_TRUNC')"
mysql mailserver -e "$SQL"

echo "Complete!"
echo "User: $1"
echo "Password: $DEFAULTPW"
