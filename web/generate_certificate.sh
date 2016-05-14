#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage: $0 <name>" >&2
    exit 1
fi

NAME=$1

SSL_KEY="$NAME".key
SSL_CERTIFICATE="$NAME".crt
SSL_CSR="$NAME".csr
SSL_PEM="$NAME".pem


SSL_SUBJ="/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX"

if [[ ! -f "$SSL_KEY" ]]; then
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "$SSL_KEY"
    chmod 400 "$SSL_KEY"
fi


if [[ ! -e "$SSL_CERTIFICATE" ]]; then
    openssl req -new -sha256 -key "$SSL_KEY" -subj "$SSL_SUBJ" -out "$SSL_CSR"
    openssl x509 -req -days 1095 -in "$SSL_CSR" -signkey "$SSL_KEY" -out "$SSL_CERTIFICATE"
fi

cat "$SSL_CERTIFICATE" "$SSL_KEY" > "$SSL_PEM"
