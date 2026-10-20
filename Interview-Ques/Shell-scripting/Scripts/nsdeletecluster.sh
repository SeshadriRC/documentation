#!/bin/bash
# ==============================================================================
# Script Name   : nsdeletecluster.sh
# Purpose       : Automate decommission of OpenShift namespaces and their
#                 associated Custom Resources (CRs) across multiple clusters
#                 using CSV input.
# Author / Owner: Seshadri RC
#
# INTERVIEW TALKING POINTS & STEP-BY-STEP SUMMARY:
# ------------------------------------------------------------------------------
# 1. Why this script exists:
#    In enterprise OpenShift/Kubernetes environments, deleting a namespace directly
#    can cause the namespace to get stuck in "Terminating" state if Custom Resources
#    (like 'dfsapplication' managed by onboarding-operator) have active finalizers.
#    This script cleanly logs into each target cluster, deletes the custom resource
#    first (allowing operator finalizers to complete), and then terminates the namespace.
#
# 2. How it works (8 Sequential Steps):
#    Step 1: Strict Error Mode (`set -euo pipefail`) prevents silent errors.
#    Step 2: Associative Array (`declare -A`) maps cluster names to API URLs.
#    Step 3: Validates existence of the input CSV file.
#    Step 4: Skips header and reads CSV row-by-row using `IFS=',' read -r`.
#    Step 5: Trims spaces and carriage returns (`xargs`, `tr -d '\r'`).
#    Step 6: Authenticates to target OpenShift cluster (`oc login`, verifies via `oc whoami`).
#    Step 7: Switches to operator project and deletes Custom Resource `dfsapplication`.
#    Step 8: Deletes the target namespace and logs status.
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: Strict Error Handling Configuration
# -e          : Exit immediately if any command returns a non-zero exit status.
# -u          : Treat unset/undefined variables as errors.
# -o pipefail : Fail the entire pipeline if any command inside it fails.
# ------------------------------------------------------------------------------
set -euo pipefail

# ------------------------------------------------------------------------------
# STEP 2: Cluster API Endpoint Mapping (Associative Array)
# Key = Cluster identifier from CSV; Value = OpenShift API Server URL (port 6443)
# ------------------------------------------------------------------------------
declare -A CLUSTER_API_MAP
CLUSTER_API_MAP["aws-uswest2-apps-1ab-1"]="https://api.aws-uswest2-apps-1ab-1.ocpdev.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-apps-prod-1"]="https://api.aws-useast1-apps-prod-1.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-apps-prod-2"]="https://api.aws-useast1-apps-prod-2.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-uswest2-apps-prod-1"]="https://api.aws-uswest2-apps-prod-1.ocpprd.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-uswest2-apps-prod-2"]="https://api.aws-uswest2-apps-prod-2.ocpprd.us-west-2.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-ppp-apps-prod-1"]="https://api.aws-useast1-ppp-apps-prod-1.ocpprd.us-east-1.ac.discoverfinancial.com:6443"
CLUSTER_API_MAP["aws-useast1-ppp-apps-prod-2"]="https://api.aws-useast1-ppp-apps-prod-2.ocpprd.us-east-1.ac.discoverfinancial.com:6443"

# ------------------------------------------------------------------------------
# STEP 3: Input CSV Configuration & Validation
# Allows passing CSV path via argument 1, defaulting to the desktop location.
# CSV format expected: base,cluster,namespace
# ------------------------------------------------------------------------------
CSV_FILE="${1:-/c/Users/src00/Desktop/input.csv}"

echo "=========================================================="
echo "[+] Validating input CSV file: $CSV_FILE"
echo "=========================================================="

if [[ ! -f "$CSV_FILE" ]]; then
    echo "[-] ERROR: CSV file not found at path: $CSV_FILE"
    exit 1
fi

echo "[+] CSV file found. Commencing multi-cluster namespace deletion..."
echo "=========================================================="

# ------------------------------------------------------------------------------
# STEP 4: Process CSV Row by Row
# - `tail -n +2` skips the CSV header row.
# - `IFS=',' read -r` splits each line by comma into base, cluster, and ns variables.
# ------------------------------------------------------------------------------
tail -n +2 "$CSV_FILE" | while IFS=',' read -r base cluster ns; do

    # --------------------------------------------------------------------------
    # STEP 5: Sanitize Input Data & Resolve Cluster API
    # - `tr -d '\r'` removes Windows carriage returns.
    # - `xargs` trims leading and trailing whitespaces.
    # --------------------------------------------------------------------------
    cluster=$(echo "${cluster:-}" | tr -d '\r' | xargs)
    ns=$(echo "${ns:-}" | tr -d '\r' | xargs)

    # Validate that neither cluster nor namespace is empty
    if [[ -z "$cluster" || -z "$ns" ]]; then
        echo "[!] WARN: Skipping row due to missing cluster or namespace value."
        continue
    fi

    echo "----------------------------------------------------------"
    echo "[*] Processing Namespace: $ns on Cluster: $cluster"

    # Lookup API URL from associative map
    api_url="${CLUSTER_API_MAP[$cluster]:-}"
    if [[ -z "$api_url" ]]; then
        echo "[-] ERROR: No API URL mapping found for cluster '$cluster'. Skipping."
        continue
    fi

    # --------------------------------------------------------------------------
    # STEP 6: Authenticate to Target OpenShift Cluster
    # - Clears previous session (`oc logout`).
    # - Authenticates to API server (`oc login`).
    # - Loops until `oc whoami` confirms active authenticated session.
    # --------------------------------------------------------------------------
    echo "[+] Logging into cluster: $cluster ($api_url)"
    oc logout &>/dev/null || true
    oc login "$api_url" --web

    echo "[+] Awaiting authentication confirmation..."
    while ! oc whoami &>/dev/null; do
        sleep 5
    done
    echo "[+] Login successful as: $(oc whoami)"

    # --------------------------------------------------------------------------
    # STEP 7: Delete Custom Resource (CR) in Operator Project
    # Deleting the CR first ensures the operator reconciler cleans up underlying
    # finalizers, preventing the namespace from hanging in 'Terminating' state.
    # --------------------------------------------------------------------------
    echo "[+] Switching project to onboarding-operator..."
    oc project onboarding-operator
    sleep 2

    echo "[+] Deleting custom resource 'dfsapplication' for namespace: $ns"
    if oc delete dfsapplication "$ns" --ignore-not-found=true; then
        echo "[✓] Custom resource 'dfsapplication' deleted for $ns."
    else
        echo "[!] No dfsapplication found for $ns or deletion failed."
    fi

    sleep 4

    # --------------------------------------------------------------------------
    # STEP 8: Delete OpenShift Namespace
    # --------------------------------------------------------------------------
    echo "[+] Deleting OpenShift namespace: $ns"
    if oc delete ns "$ns" &>/dev/null; then
        echo "[✓] Namespace '$ns' successfully deleted."
    else
        echo "[!] Namespace '$ns' not found or deletion failed."
    fi

    echo "----------------------------------------------------------"
done

echo "=========================================================="
echo "[✓] All CSV entries processed successfully."
echo "=========================================================="
