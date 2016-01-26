#!/bin/bash

set -e
set -x

# Create the password hash and set it to a variable
DEFAULTPW="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
PWHASH="$(doveadm pw -s SHA512-CRYPT -p $DEFAULTPW)"

echo ${PWHASH:14}


