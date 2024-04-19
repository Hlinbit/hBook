
# SSL config file
```
# Note: LibreSSL 2.2.7 does not correctly support environment variables
# here and that is the version that ships with OS X High Sierra. So, we
# replace text using Python and generate a temporary cnf file

common_name = @COMMON_NAME@
client_alt_name = @CLIENT_ALT_NAME@
server_alt_name = @SERVER_ALT_NAME@

[ ca ]
default_ca = test_root_ca

[ test_root_ca ]
root_ca_dir = /tmp/testca

certificate   = $root_ca_dir/cacert.pem
database      = $root_ca_dir/index.txt
new_certs_dir = $root_ca_dir/certs
private_key   = $root_ca_dir/private/cakey.pem
serial        = $root_ca_dir/serial

default_crl_days = 7
default_days     = 1825
default_md       = sha256

policy          = test_root_ca_policy
x509_extensions = certificate_extensions

[ test_root_ca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional
domainComponent = optional

[ certificate_extensions ]
basicConstraints = CA:false

[ req ]
default_bits       = 4096
default_md         = sha256
prompt             = yes
distinguished_name = root_ca_distinguished_name
x509_extensions    = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = hostname

[ root_ca_extensions ]
basicConstraints       = critical,CA:true
keyUsage               = keyCertSign, cRLSign
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer

[ client_extensions ]
basicConstraints       = CA:false
keyUsage               = digitalSignature,keyEncipherment
extendedKeyUsage       = clientAuth
subjectAltName         = @client_alt_names
crlDistributionPoints  = URI:http://crl-server:8000/basic.crl

[ server_extensions ]
basicConstraints       = CA:false
keyUsage               = digitalSignature,keyEncipherment
extendedKeyUsage       = serverAuth
subjectAltName         = @server_alt_names
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
crlDistributionPoints  = URI:http://crl-server:8000/basic.crl

[ client_alt_names ]
DNS.1 = $common_name
DNS.2 = $client_alt_name
DNS.3 = localhost
# examples of more Subject Alternative Names
# DNS.4 = guest
# email = guest@warp10.local
# URI   = amqps://123.client.warp10.local
# otherName = 1.3.6.1.4.1.54392.5.436;FORMAT:UTF8,UTF8String:other-username

[ server_alt_names ]
DNS.1 = $common_name
DNS.2 = $server_alt_name
DNS.3 = localhost
```




```bash
sudo mkdir -p /etc/rabbitmq/ssl
sudo chown -R gpadmin /etc/rabbitmq

# Prepare the SSL directory tree
mkdir /tmp/testca/
mkdir /tmp/testca/certs
mkdir /tmp/testca/private/
mkdir /tmp/server_gpadmin
mkdir /tmp/client_gpadmin

# Prepare the SSL configuration file
touch /tmp/testca/index.txt
touch /tmp/testca/index.txt.attr
touch /tmp/testca/certs/01.pem
touch /tmp/testca/certs/02.pem
touch /tmp/testca/serial
echo '01' > /tmp/testca/serial

export GODEBUG=x509sha1=1
export GPSS_SRC_PATH=/home/gpadmin/workspace/gp-stream-server

# Generate a root CA and two certificate/key pairs (server and client)
openssl req -config ${GPSS_SRC_PATH}/docker/cfg/openssl.cnf -x509 -days 365 -newkey rsa:2048 -keyout /tmp/testca/private/cakey.pem -out /tmp/testca/cacert.pem -outform PEM -subj /CN=TLSGenSelfSignedtRootCA/L=$$$$/ -nodes

# The specified certificate file is converted to CER format and output to the specified file
openssl x509 -in /tmp/testca/cacert.pem -out /tmp/testca/cacert.cer -outform DER

# Generate leaf certificate and key pair for server
openssl genpkey -algorithm RSA -outform PEM -out /tmp/server_gpadmin/key.pem -pkeyopt rsa_keygen_bits:2048

# Generate a new certificate request file, and use the private key file to sign the certificate request, and finally generate a certificate file in PEM format, which contains a new self-signed certificate.
openssl req -config ${GPSS_SRC_PATH}/docker/cfg/openssl.cnf -new -key /tmp/server_gpadmin/key.pem -keyout /tmp/server_gpadmin/cert.pem -out /tmp/server_gpadmin/req.pem -outform PEM -subj /CN=gpadmin/O=server/L=$$$$/ -nodes

# Generate a server-side certificate according to the specified OpenSSL configuration file, certificate signing request, certificate authority's private key and certificate and other parameters.
openssl ca -config ${GPSS_SRC_PATH}/docker/cfg/openssl.cnf -days 3650 -cert /tmp/testca/cacert.pem -keyfile /tmp/testca/private/cakey.pem -in /tmp/server_gpadmin/req.pem -out /tmp/server_gpadmin/cert.pem -outdir /tmp/testca/certs -notext -batch -extensions server_extensions

# Write out database with new entries
# Package the specified server certificate, private key, and root certificate of the issuing authority into PKCS#12 format, and generate a keystore file with an empty password.
openssl pkcs12 -export -out /tmp/server_gpadmin/keycert.p12 -in /tmp/server_gpadmin/cert.pem -inkey /tmp/server_gpadmin/key.pem -certfile /tmp/testca/cacert.pem -passout pass:

# Will generate leaf certificate and key pair for client
openssl genpkey -algorithm RSA -outform PEM -out /tmp/client_gpadmin/key.pem -pkeyopt rsa_keygen_bits:2048

# Generate a new certificate request file, and use the private key file to sign the certificate request, and finally generate a certificate file in PEM format, which contains a new self-signed certificate.
openssl req -config ${GPSS_SRC_PATH}/docker/cfg/openssl.cnf -new -key /tmp/client_gpadmin/key.pem -keyout /tmp/client_gpadmin/cert.pem -out /tmp/client_gpadmin/req.pem -outform PEM -subj /CN=gpadmin/O=client/L=$$$$/ -nodes

# Generate a client certificate based on the specified OpenSSL configuration file, certificate signing request, certificate authority's private key and certificate, and other parameters.
openssl ca -config ${GPSS_SRC_PATH}/docker/cfg/openssl.cnf -days 3650 -cert /tmp/testca/cacert.pem -keyfile /tmp/testca/private/cakey.pem -in /tmp/client_gpadmin/req.pem -out /tmp/client_gpadmin/cert.pem -outdir /tmp/testca/certs -notext -batch -extensions client_extensions

# Write out database with new entries
# Pack the specified client certificate, private key, and authority root certificate into PKCS#12 format, and generate a keystore file with an empty password.
openssl pkcs12 -export -out /tmp/client_gpadmin/keycert.p12 -in /tmp/client_gpadmin/cert.pem -inkey /tmp/client_gpadmin/key.pem -certfile /tmp/testca/cacert.pem -passout pass:

sudo cp /tmp/server_gpadmin/cert.pem /etc/rabbitmq/ssl/
sudo chmod 777 /etc/rabbitmq/ssl/cert.pem

sudo cp /tmp/server_gpadmin/key.pem /etc/rabbitmq/ssl/
sudo chmod 777 /etc/rabbitmq/ssl/key.pem

sudo cp /tmp/testca/cacert.pem /etc/rabbitmq/ssl/
sudo chmod 777 /etc/rabbitmq/ssl/cacert.pem
```