#!/bin/bash
set -e

openssl genrsa -out my_ca.key 4096
openssl req -x509 -new -nodes -key my_ca.key -sha256 -subj '/C=NL/CN=My CA' -addext "keyUsage=critical,keyCertSign,cRLSign" -days 1826 -out my_ca.crt
