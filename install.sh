#!/usr/bin/env bash

check_os () {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo 
    else
        echo "Systems other than linux are not supported. Exiting now."
        exit 1
    fi
}

test_sudo () {
    if [[ $(sudo id -u) -ne 0 ]]; then
        echo "sudo did not set us to uid 0; you must run this script with a user that has sudo privileges."
        exit 1
    fi
}


echo " "

echo "Welcome to AccessAudit Installer"
echo "==================================="
echo " "
echo "This installer will do the following: "
echo " 1. Check for required dependencies"
echo " 2. Add to rsyslog.conf an additional logging of all logins to the immudb Vault"
echo " IMPORTANT: AccessAudit will use default collection and default ledger"

echo " "
    read -p "Continue with installation (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
echo ""

test_sudo
check_os

read -p "Enter immudb Vault Write API Key: " vaultKey

echo "Testing your key with simple request..."

vault_status_code=$(curl -w "%{http_code}" -X POST https://vault.immudb.io/ics/api/v1/ledger/default/collection/default/documents/count -H "X-API-KEY: $vaultKey" -d '{}' -H 'Content-Type: application/json' --silent --output /dev/null)

if [ "$vault_status_code" = "200" ] || [ "$vault_status_code" = "404" ]; then
    echo "API key works. Proceed with installation"
else   
    echo "Vault status code was $vault_status_code"
    echo "Standard API key check failed. Aborting installation."
    exit 1
fi

# check if we have wget or curl installed
foundtool="true"
type curl &> /dev/null || foundtool="false"
if [[ $foundtool != "true" ]]; then
    echo "curl is not available! Please install it now and restart the install script."
    exit 1
fi



sudo mkdir -p /etc/accessaudit/
cat <<EOF | sudo tee  /etc/accessaudit/env >/dev/null 
VAULT_API_KEY=$vaultKey
VAULT_URL=https://vault.immudb.io/ics/api/v1/ledger/default/collection/default/document
EOF

cat <<EOF | sudo tee  /usr/bin/forward-logs-to-vault.sh >/dev/null
#!/bin/bash
source /etc/accessaudit/env
while read line; do
  curl -X 'PUT' "\$VAULT_URL"  -H 'accept: application/json' -H "X-API-Key: \$VAULT_API_KEY"   -H 'Content-Type: application/json'   -d "\$line"
done
EOF


sudo chmod +x /usr/bin/forward-logs-to-vault.sh

cat <<EOF | sudo tee /etc/rsyslog.d/99-immudb-vault.conf >/dev/null
module(load="omprog")
    
template(name="json-template" type="list" option.jsonf="on") {
    property(outname="@timestamp" name="timereported" dateFormat="rfc3339" format="jsonf")
    property(outname="host" name="hostname" format="jsonf")
    property(outname="severity" name="syslogseverity" caseConversion="upper" format="jsonf" datatype="number")
    property(outname="facility" name="syslogfacility" format="jsonf" datatype="number")
    property(outname="syslog-tag" name="syslogtag" format="jsonf")
    property(outname="source" name="app-name" format="jsonf" onEmpty="null")
    property(outname="message" name="msg" format="jsonf")
}


authpriv.* action(type="omprog"
            binary="/usr/bin/forward-logs-to-vault.sh"
            template="json-template")
EOF

sudo systemctl restart rsyslog


echo "Installation completed!"
