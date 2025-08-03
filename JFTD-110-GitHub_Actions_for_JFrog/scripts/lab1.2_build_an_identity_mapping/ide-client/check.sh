#!/bin/bash

# Source the check.sh script from lab1.1 to get access to the OIDC functions
source "$(dirname "$0")/../../jf_api_wrapper_utils.sh"

echo "🔍 Lab 1.2 - Checking OIDC Identity Mapping"
echo "================================================"

# Configuration
SERVER_ID="academy1"
PROVIDER_NAME="svk-githuboidc"
MAPPING_NAME="jfrog-repos"

echo "🔧 Configuration:"
echo "   Server ID: $SERVER_ID"
echo "   Provider Name: $PROVIDER_NAME"
echo "   Mapping Name: $MAPPING_NAME"
echo ""

# Check if the OIDC identity mapping exists
if jf_check_oidc_identity_mapping "$SERVER_ID" "$PROVIDER_NAME" "$MAPPING_NAME" true; then
    echo ""
    echo "✅ Lab 1.2 check passed - OIDC identity mapping exists"
    exit 0
else
    echo ""
    echo "❌ Lab 1.2 check failed - OIDC identity mapping does not exist"
    exit 1
fi
