#!/bin/bash
# Prints the proof for each acceptance test. Run from infra/.
DB=$(terraform output -raw db_fqdn)
DBN=$(terraform output -raw db_name)
KV=$(terraform output -raw kv_name)
LB=$(terraform output -raw lb_public_ip)

echo "=== TEST 1: internet -> load balancer -> app VM ==="
curl -s --max-time 10 http://$LB; echo

echo "=== TEST 2: app VM has no public IP ==="
az vm list-ip-addresses --resource-group rg-azsecure-dev --name vm-azsecure-dev-app --query "[].virtualMachine.network.{private:privateIpAddresses, public:publicIpAddresses}" -o json

echo "=== TEST 3: bastion firewall rules (SSH from admin IP only) ==="
az network nsg rule list --resource-group rg-azsecure-dev --nsg-name nsg-azsecure-dev-public --query "[].{rule:name, priority:priority, access:access, port:destinationPortRange, source:sourceAddressPrefix}" -o table

echo "=== TEST 4a: database public access ==="
az postgres flexible-server show --resource-group rg-azsecure-dev --name $DBN --query "network.{public:publicNetworkAccess}" -o json
echo "--- database name looked up from this laptop (expect no address) ---"
nslookup $DB

echo "=== TEST 4b: port 5432 from the app VM vs the bastion ==="
echo -n "app VM:  "; ssh azsecure-app "timeout 6 bash -c '</dev/tcp/$DB/5432' && echo PORT-OPEN || echo PORT-CLOSED"
echo -n "bastion: "; ssh azsecure-bastion "timeout 6 bash -c '</dev/tcp/$DB/5432' && echo PORT-OPEN || echo PORT-CLOSED"

echo "=== TEST 5a: Key Vault firewall ==="
az keyvault show --name $KV --query "properties.networkAcls.{default:defaultAction, ips:ipRules[].value, subnets:virtualNetworkRules[].id}" -o json

echo "=== TEST 7: remote state ==="
az storage blob list --account-name sttfstateumjapl --container-name tfstate --output table
