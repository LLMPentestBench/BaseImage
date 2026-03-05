#!/bin/bash
set -e

openssl req -new -nodes -out website.csr -newkey rsa:4096 -keyout website.key \
  -subj '/C=NL/CN=api.openai.com'
openssl x509 -req -in website.csr -CA my_ca.crt -CAkey my_ca.key -CAcreateserial -out website.crt -days 730 -sha256 \
  -extfile <(printf "subjectAltName=DNS:api.openai.com\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=serverAuth")

rm website.csr