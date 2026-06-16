#!/bin/bash
set -euo pipefail

# --- Cluster API mapping ---
declare -A CLUSTER_API_MAP
CLUSTER_API_MAP["aws-uswest2-apps-1ab-1"]="https://api.aws-uswest2-apps-1ab-1.ocpdev.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-apps-prod-1"]="https://api.aws-useast1-apps-prod-1.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-apps-prod-2"]="https://api.aws-useast1-apps-prod-2.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-uswest2-apps-prod-1"]="https://api.aws-uswest2-apps-prod-1.ocpprd.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-uswest2-apps-prod-2"]="https://api.aws-uswest2-apps-prod-2.ocpprd.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-ppp-apps-prod-1"]="https://api.aws-useast1-ppp-apps-prod-1.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-ppp-apps-prod-2"]="https://api.aws-useast1-ppp-apps-prod-2.ocpprd.us-east-1.ac.discoverfinancial.com:6443"


# Add other cluster and server here

# Input CSV (can be passed as first argument)
CSV_FILE="/c/Users/src00/Desktop/input.csv"

# Checking if CSV file exists
echo " Checking if CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then
echo "x CSV file not found: SCSV_FILE"
exit 1

echo " ******
echo "CSV file found: $CSV_FILE"
" *******
echo

tail -n +2 "$CSV_FILE" | while IFS=',' read -r base cluster ns; do
    cluster=$(echo "$cluster" | xargs)
    ns=$(echo "$ns" | xargs)

if [[ -z "$cluster" || -z "$ns" ]]; then
echo "Skipping row with missing cluster or namespace."
continue
fi

api_url="${CLUSTER_API_MAP[$cluster] :- }"
if [[ -z "Sapi_url" ]]; then
echo "No API URL mapping for cluster 'Scluster'. Skipping."
continue
fi

echo "Logging into cluster: Scluster (Sapi_ur1)"
oc logout &>/dev/null || true
oc login "$api_url" -- web
while ! oc whoami &>/dev/null; do sleep 5; done
echo "Login successful."

echo "Deleting dfsapplications in namespace: $ns"
oc project onboarding-operator
sleep 2
if oc delete dfsapplication "$ns" ; then
echo "dfsapplications deleted for $ns."
else
echo "No dfsapplications found for $ns or deletion failed."
fi

sleep 4

echo "Deleting namespace: Sns"
if oc delete ns "$ns" &/dev/null; then
echo "Namespace $ns deleted."
else
echo "Namespace $ns not found or deletion failed."

echo
done
