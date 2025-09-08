#!/bin/bash
set -euo pipefail

# ========== RLM: RBv2 Signing Key. ref https://jfrog.com/help/r/jfrog-artifactory-documentation/create-signing-keys-for-release-bundles-v2
printf "\n ========== Generating GPG key pair for RBv2 signing ========== \n" 
GPG_HOMEDIR=$(mktemp -d)
JSON_FILE_PATH=$(mktemp)
mkdir -p "$GPG_HOMEDIR"
chmod 700 "$GPG_HOMEDIR"

KEY_NAME_RBv2="jftd114-rbv2_key"
EMAIL="${KEY_NAME_RBv2}@yourdomain.com"
ALIAS="$KEY_NAME_RBv2"
COMMENT="$KEY_NAME_RBv2"
KEY_LENGTH=4096
EXPIRE_DATE=0
PASSPHRASE="${PASSPHRASE:-}"  # Optional: set via env var if needed

cat > keydetails <<EOF
  %echo Generating a GPG key
  Key-Type: RSA
  Key-Length: $KEY_LENGTH
  Subkey-Type: RSA
  Subkey-Length: $KEY_LENGTH
  Name-Real: $ALIAS
  Name-Comment: $COMMENT
  Name-Email: $EMAIL
  Expire-Date: $EXPIRE_DATE
EOF

echo "  %no-ask-passphrase" >> keydetails
echo "  %no-protection" >> keydetails

cat >> keydetails <<EOF
  %commit
  %echo done
EOF

gpg --homedir "$GPG_HOMEDIR" --batch --gen-key keydetails

KEY_ID=$(gpg --homedir "$GPG_HOMEDIR" --list-keys --with-colons "$EMAIL" | grep '^pub' | cut -d':' -f5 | head -n1)
echo "GPG Key ID: $KEY_ID"

PRIV_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export-secret-keys "$KEY_ID")
PRIV_KEY_ESC=$(printf "%s" "$PRIV_KEY" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

PUB_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export "$KEY_ID")
PUB_KEY_ESC=$(printf "%s" "$PUB_KEY" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

cat >"$JSON_FILE_PATH" <<EOF
{
  "pairName": "$KEY_NAME_RBv2",
  "pairType": "GPG",
  "alias": "$ALIAS",
  "privateKey": "$PRIV_KEY_ESC",
  "publicKey": "$PUB_KEY_ESC",
  "passphrase": ""
}
EOF

# DELETE RBv2 key if already exists 
# jf rt curl -s -XDELETE "/api/security/keypair/jftd114-rbv2_key" -H 'Content-Type: application/json'
jf rt curl -XDELETE "/api/security/keypair/$KEY_NAME_RBv2" -H 'Content-Type: application/json'

# Upload Key via API https://jfrog.com/help/r/jfrog-rest-apis/create-key-pair 
echo "Uploading GPG key pair to Artifactory..."
jf rt curl -v -XPOST "/api/security/keypair" -H 'Content-Type: application/json' --data-binary @"$JSON_FILE_PATH"
echo "Key $KEY_NAME_RBv2 uploaded successfully."
# GET Key to verify https://jfrog.com/help/r/jfrog-rest-apis/get-key-pair
jf rt curl -XGET "/api/security/keypair/$KEY_NAME_RBv2" -H 'Content-Type: application/json'

# Evidence Signing Key. ref https://jfrog.com/help/r/jfrog-artifactory-documentation/evidence-setup
printf "\n ========== Generating GPG key pair for Evidence signing ========== \n" 
openssl genrsa -out evd_private.pem 2048
openssl rsa -in evd_private.pem -pubout -out evd_public.pem
chmod 700 *.pem

EVD_KEY_PRIVATE="$(cat evd_private.pem)" EVD_KEY_PUBLIC="$(cat evd_public.pem)" KEY_NAME_EVD="jftd114-evd_key" 

cat >"$JSON_FILE_PATH" <<EOF
{
  "pairName": "$KEY_NAME_EVD",
  "pairType": "RSA",
  "alias": "$KEY_NAME_EVD",
  "privateKey": "$EVD_KEY_PRIVATE",
  "publicKey": "$EVD_KEY_PUBLIC",
  "passphrase": ""
}
EOF

# DELETE Evidence key if already exists 
# jf rt curl -s -XDELETE "/api/security/keypair/jftd114-evd_key" -H 'Content-Type: application/json'
jf rt curl -XDELETE "/api/security/keypair/$KEY_NAME_EVD" -H 'Content-Type: application/json'

# Upload Key via API https://jfrog.com/help/r/jfrog-rest-apis/create-key-pair 
echo "Uploading RSA key pair to Artifactory..."
jf rt curl -XPOST "/api/security/keypair" -H 'Content-Type: application/json' --data-binary @"$JSON_FILE_PATH"
echo "Key $KEY_NAME_EVD uploaded successfully."
# GET Key to verify https://jfrog.com/help/r/jfrog-rest-apis/get-key-pair
jf rt curl -XGET "/api/security/keypair/$KEY_NAME_EVD" -H 'Content-Type: application/json'

# cleanup files
rm -f ./keydetails
# rm -f *.pem

printf "\n\n**** Verify .Pem & list ****\n\n"
# Verify private key
openssl rsa -inform PEM -in ./evd_private.pem -check
openssl rsa -in ./evd_private.pem -text -noout
ls -lrt *.pem