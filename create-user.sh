#!/bin/bash

set -e
# set -x

source /etc/mail-tools/mail-tools.conf

# Create variables
EMAIL="$1"
DOMAIN="1"
USER_NAME=$(echo "$EMAIL" | cut -f1 -d"@")

# Exit paths
if ! grep -q "@" <<< "$EMAIL"; then
  echo "Must enter a valid email address!"
  exit 1
fi

if [ "$(id -u)" != "0" ]; then
  echo "Must be ran by root/sudo"
  exit 1
fi

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

# Output details
echo "Complete!"
echo "User: $1"
echo "Password: $DEFAULTPW"
echo Sending user an introductory email.

# Send an email to the newly created email account
cat << EOF | mailx -v \
-r "$POSTMASTER" \
-s "Your new account" \
-S smtp="$AUTHSMTP:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$AUTHEMAIL" -S smtp-auth-password="$AUTHPW" "$EMAIL" &> /dev/null
Welcome, $USER_NAME!

This is your brand spaking new, secure, unsniffable email account! It should always use TLS.
If you find you are able to send or receive with this account over an insecure protocol, please mail $POSTMASTER!

Happy mailing.
EOF

# Complete
echo "Intro email sent succesfully"
