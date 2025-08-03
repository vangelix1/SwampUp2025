#!/bin/bash

jf_api_request() {
    # Make authenticated API request to JFrog services
    # Usage: jf_api_request <server_id> <method> <endpoint> [data] [debug]
    # Returns: HTTP_CODE:RESPONSE_BODY

    local server_id="$1"
    local method="${2:-GET}"
    local endpoint="$3"
    local data="${4:-}"
    local debug="${5:-false}"

    if [ -z "$server_id" ] || [ -z "$endpoint" ]; then
        echo "Usage: jf_api_request <server_id> <method> <endpoint> [data] [debug]" >&2
        return 1
    fi

    local access_token artifactory_url
    access_token=$(jf_config_load "$server_id" "accessToken")
    artifactory_url=$(jf_config_load "$server_id" "artifactoryUrl")

    if [ -z "$access_token" ] || [ "$access_token" = "null" ]; then
        echo "Error: Access token not found for server '$server_id'" >&2
        return 1
    fi

    if [ -z "$artifactory_url" ] || [ "$artifactory_url" = "null" ]; then
        echo "Error: Artifactory URL not found for server '$server_id'" >&2
        return 1
    fi

    local base_url full_url
    # Handle Access API endpoints (environments, projects, OIDC providers)
    # Check if endpoint starts with api/v1/ (without leading slash)
    if echo "$endpoint" | grep -q "^api/v1/environments\|^api/v1/projects/\|^api/v1/oidc"; then
        if [[ "$artifactory_url" =~ /artifactory/?$ ]]; then
            base_url="${artifactory_url%/artifactory*}/access"
        else
            base_url="${artifactory_url%/}/access"
        fi
    else
        base_url="$artifactory_url"
    fi

    base_url="${base_url%/}"
    endpoint="${endpoint#/}"
    full_url="${base_url}/${endpoint}"

    # Execute curl with status capture
    local http_status response_body
    http_status=$(curl -s -w "%{http_code}" -o /tmp/jf_api_response \
        -X "$method" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        ${data:+-d "$data"} \
        "$full_url")

    response_body=$(cat /tmp/jf_api_response)

    if [ "$debug" = "true" ]; then
        echo "Debug: HTTP Status: $http_status" >&2
        echo "Debug: Response Body: $response_body" >&2
        echo "Debug: Full URL: $full_url" >&2
        echo "Debug: Base URL: $base_url" >&2
        echo "Debug: Endpoint: $endpoint" >&2
    fi

    echo "$http_status:$response_body"
}

jf_config_load() {
    local server_id="$1"
    local config_var="${2:-}"

    if ! command -v jf >/dev/null 2>&1; then
        echo "Error: jfrog CLI not found" >&2
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required but not installed" >&2
        return 1
    fi

    local encoded
    encoded=$(jf c export "$server_id" 2>/dev/null)

    if [ -z "$encoded" ] || [ "$encoded" = "null" ]; then
        echo "Error: Could not export config for server '$server_id'" >&2
        return 1
    fi

    local decoded
    decoded=$(echo "$encoded" | base64 -d 2>/dev/null)

    if [ -z "$decoded" ]; then
        echo "Error: Failed to decode config from jfrog CLI" >&2
        return 1
    fi

    if [ -n "$config_var" ]; then
        echo "$decoded" | jq -r ".$config_var"
    else
        echo "$decoded"
    fi
}




jf_repository_check() {
    # Check if a JFrog repository exists
    # Usage: jf_repository_check <server_id> <repo_key> [debug]
    # Returns: 0 if exists, 1 if not found, 2 on error

    local server_id="$1"
    local repo_key="$2"
    local debug="${3:-false}"

    if [ -z "$server_id" ] || [ -z "$repo_key" ]; then
        echo "Usage: jf_repository_check <server_id> <repo_key> [debug]" >&2
        return 2
    fi

    local response_combined
    response_combined=$(jf_api_request "$server_id" "GET" "api/repositories/$repo_key" "" "$debug")

    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"

    if [ "$http_code" = "200" ]; then
        if echo "$response" | jq -e '.key' >/dev/null 2>&1; then
            echo "Repository '$repo_key' exists"
            return 0
        else
            echo "Error: Unexpected response format (200 but no .key)" >&2
            return 2
        fi
    elif [ "$http_code" = "404" ]; then
        echo "Repository '$repo_key' does not exist"
        return 1
    else
        echo "Error: HTTP $http_code from JFrog API while checking '$repo_key'" >&2
        echo "$response" >&2
        return 2
    fi
}

jf_check_all_repos() {
    local server_id="$1"
    shift
    local repos=("$@")
    local all_exist=true

    for repo in "${repos[@]}"; do
        echo "🔍 Checking repository: $repo"
        if ! jf_repository_check "$server_id" "$repo" true; then
            echo "❌ Missing or error in repository: $repo"
            all_exist=false
        fi
    done

    if $all_exist; then
        echo "✅ All repositories exist."
        return 0
    else
        echo "❌ One or more repositories are missing or errored."
        return 1
    fi
}

jf_oidc_provider_check() {
    # Check if a JFrog OIDC provider exists
    # Usage: jf_oidc_provider_check <server_id> <provider_name> [debug]
    # Returns: 0 if exists, 1 if not found, 2 on error

    local server_id="$1"
    local provider_name="$2"
    local debug="${3:-false}"

    if [ -z "$server_id" ] || [ -z "$provider_name" ]; then
        echo "Usage: jf_oidc_provider_check <server_id> <provider_name> [debug]" >&2
        return 2
    fi

    local response_combined
    response_combined=$(jf_api_request "$server_id" "GET" "api/v1/oidc/$provider_name" "" "$debug")

    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"

    if [ "$http_code" = "200" ]; then
        if echo "$response" | jq -e '.name' >/dev/null 2>&1; then
            echo "OIDC provider '$provider_name' exists"
            echo "$response"
            return 0
        else
            echo "Error: Unexpected response format (200 but no .name)" >&2
            return 2
        fi
    elif [ "$http_code" = "404" ]; then
        echo "OIDC provider '$provider_name' does not exist"
        return 1
    else
        echo "Error: HTTP $http_code from JFrog API while checking OIDC provider '$provider_name'" >&2
        echo "$response" >&2
        return 2
    fi
}



jf_test_connectivity() {
    # Test basic connectivity and configuration for a server
    # Usage: jf_test_connectivity <server_id>
    
    local server_id="$1"
    
    if [ -z "$server_id" ]; then
        echo "Usage: jf_test_connectivity <server_id>" >&2
        return 1
    fi
    
    echo "🔧 Testing connectivity for server '$server_id':"
    echo "================================================"
    
    # Test 1: Check if jf CLI is configured
    echo "1. Checking JFrog CLI configuration..."
    if ! jf c show "$server_id" >/dev/null 2>&1; then
        echo "❌ Server '$server_id' not found in JFrog CLI configuration"
        return 1
    else
        echo "✅ Server '$server_id' found in JFrog CLI configuration"
    fi
    
    # Test 2: Get configuration details
    echo "2. Getting server configuration..."
    local artifactory_url access_token
    artifactory_url=$(jf_config_load "$server_id" "artifactoryUrl")
    access_token=$(jf_config_load "$server_id" "accessToken")
    
    echo "   Artifactory URL: $artifactory_url"
    echo "   Access Token: ${access_token:0:20}..."
    
    # Test 3: Test basic API connectivity
    echo "3. Testing basic API connectivity..."
    local response_combined
    response_combined=$(jf_api_request "$server_id" "GET" "api/system/version" "" "true")
    
    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ Basic API connectivity successful"
        echo "   Response: $response"
    else
        echo "❌ Basic API connectivity failed (HTTP $http_code)"
        echo "   Response: $response"
    fi
    
    echo ""
}

jf_list_oidc_providers() {
    # List all OIDC providers on a server
    # Usage: jf_list_oidc_providers <server_id> [debug]
    
    local server_id="$1"
    local debug="${2:-false}"
    
    if [ -z "$server_id" ]; then
        echo "Usage: jf_list_oidc_providers <server_id> [debug]" >&2
        return 1
    fi
    
    echo "📋 Listing OIDC providers on server '$server_id':"
    echo "================================================"
    
    local response_combined
    response_combined=$(jf_api_request "$server_id" "GET" "api/v1/oidc" "" "$debug")
    
    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"
    
    if [ "$http_code" = "200" ]; then
        if echo "$response" | jq -e '.providers' >/dev/null 2>&1; then
            echo "✅ Found OIDC providers:"
            echo "$response" | jq -r '.providers[]?.name // empty'
        elif echo "$response" | jq -e '.[]' >/dev/null 2>&1; then
            echo "✅ Found OIDC providers:"
            echo "$response" | jq -r '.[]?.name // empty'
        else
            echo "✅ Response received but no providers found:"
            echo "$response"
        fi
        return 0
    elif [ "$http_code" = "404" ]; then
        echo "❌ OIDC endpoint not found (HTTP 404)"
        return 1
    else
        echo "❌ Error listing OIDC providers (HTTP $http_code):"
        echo "$response"
        return 2
    fi
}

jf_create_oidc_provider() {
    # Create a new OIDC provider
    # Usage: jf_create_oidc_provider <server_id> <provider_name> <issuer_url> <provider_type> [description] [audience] [debug]
    # Returns: 0 if created successfully, 1 if already exists, 2 on error
    
    local server_id="$1"
    local provider_name="$2"
    local issuer_url="$3"
    local provider_type="$4"
    local description="${5:-}"
    local audience="${6:-}"
    local debug="${7:-false}"
    
    if [ -z "$server_id" ] || [ -z "$provider_name" ] || [ -z "$issuer_url" ] || [ -z "$provider_type" ]; then
        echo "Usage: jf_create_oidc_provider <server_id> <provider_name> <issuer_url> <provider_type> [description] [audience] [debug]" >&2
        return 2
    fi
    
    echo "🔧 Creating OIDC provider '$provider_name' on server '$server_id':"
    echo "================================================"
    
    # First check if provider already exists
    if jf_oidc_provider_check "$server_id" "$provider_name" >/dev/null 2>&1; then
        echo "⚠️  OIDC provider '$provider_name' already exists"
        return 1
    fi
    
    # Prepare the JSON payload using jq for proper JSON construction
    # Based on existing providers, we don't need oidc_setting for GitHub providers
    local json_payload
    json_payload=$(jq -n \
        --arg name "$provider_name" \
        --arg issuer_url "$issuer_url" \
        --arg provider_type "$provider_type" \
        --arg description "${description:-}" \
        --arg audience "${audience:-}" \
        '{
            name: $name,
            issuer_url: $issuer_url,
            provider_type: $provider_type,
            enable_permissive_configuration: true,
            use_default_proxy: false
        } + (if $description != "" then {description: $description} else {} end) + (if $audience != "" then {audience: $audience} else {} end)')
    
    echo "📝 Creating provider with payload:"
    echo "$json_payload" | jq '.'
    echo ""
    
    # Make the API call
    local response_combined
    response_combined=$(jf_api_request "$server_id" "POST" "api/v1/oidc" "$json_payload" "$debug")
    
    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo "✅ OIDC provider '$provider_name' created successfully"
        echo "Response: $response"
        return 0
    elif [ "$http_code" = "409" ]; then
        echo "⚠️  OIDC provider '$provider_name' already exists (HTTP 409)"
        return 1
    else
        echo "❌ Failed to create OIDC provider '$provider_name' (HTTP $http_code)"
        echo "Response: $response"
        return 2
    fi
}

jf_check_oidc_identity_mapping() {
    # Check if an OIDC identity mapping exists for a provider
    # Usage: jf_check_oidc_identity_mapping <server_id> <provider_name> <mapping_name> [debug]
    # Returns: 0 if exists, 1 if not found, 2 on error
    
    local server_id="$1"
    local provider_name="$2"
    local mapping_name="$3"
    local debug="${4:-false}"
    
    if [ -z "$server_id" ] || [ -z "$provider_name" ] || [ -z "$mapping_name" ]; then
        echo "Usage: jf_check_oidc_identity_mapping <server_id> <provider_name> <mapping_name> [debug]" >&2
        return 2
    fi
    
    echo "🔍 Checking OIDC identity mapping '$mapping_name' for provider '$provider_name' on server '$server_id':"
    echo "================================================"
    
    local response_combined
    response_combined=$(jf_api_request "$server_id" "GET" "api/v1/oidc/$provider_name/identity_mappings" "" "$debug")
    
    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"
    
    if [ "$http_code" = "200" ]; then
        if echo "$response" | jq -e ".[] | select(.name == \"$mapping_name\")" >/dev/null 2>&1; then
            echo "✅ OIDC identity mapping '$mapping_name' exists for provider '$provider_name'"
            echo "Mapping details:"
            echo "$response" | jq -r ".[] | select(.name == \"$mapping_name\")"
            return 0
        else
            echo "❌ OIDC identity mapping '$mapping_name' does not exist for provider '$provider_name'"
            echo "Available mappings:"
            echo "$response" | jq -r '.[]?.name // empty'
            return 1
        fi
    elif [ "$http_code" = "404" ]; then
        echo "❌ OIDC provider '$provider_name' not found (HTTP 404)"
        return 1
    else
        echo "❌ Error checking OIDC identity mappings (HTTP $http_code):"
        echo "$response"
        return 2
    fi
}

jf_create_oidc_identity_mapping() {
    # Create an OIDC identity mapping for a provider
    # Usage: jf_create_oidc_identity_mapping <server_id> <provider_name> <mapping_name> <git_org> <git_repo> [debug]
    # Returns: 0 if created successfully, 1 if already exists, 2 on error
    
    local server_id="$1"
    local provider_name="$2"
    local mapping_name="$3"
    local git_org="$4"
    local git_repo="$5"
    local debug="${6:-false}"
    
    if [ -z "$server_id" ] || [ -z "$provider_name" ] || [ -z "$mapping_name" ] || [ -z "$git_org" ] || [ -z "$git_repo" ]; then
        echo "Usage: jf_create_oidc_identity_mapping <server_id> <provider_name> <mapping_name> <git_org> <git_repo> [debug]" >&2
        return 2
    fi
    
    echo "🔧 Creating OIDC identity mapping '$mapping_name' for provider '$provider_name' on server '$server_id':"
    echo "================================================"
    
    # First check if mapping already exists
    if jf_check_oidc_identity_mapping "$server_id" "$provider_name" "$mapping_name" >/dev/null 2>&1; then
        echo "⚠️  OIDC identity mapping '$mapping_name' already exists for provider '$provider_name'"
        return 1
    fi
    
    # Prepare the JSON payload - using the correct format from prompts.txt
    local json_payload
    json_payload=$(jq -n \
  --arg name "$mapping_name" \
  --arg priority "1" \
  --arg description "$git_org/**" \
  --arg repo "$git_org/$git_repo" \
  '{
    name: $name,
    priority: $priority,
    description: $description,
    claims: {repository: $repo},
    token_spec: {
      username: "admin",
      expiry: 600,
      services: [],
      scope: "applied-permissions/user"
    }
  }')
    
    echo "📝 Creating identity mapping with payload:"
    echo "$json_payload" | jq '.'
    echo ""
    
    # Make the API call
    local response_combined
    response_combined=$(jf_api_request "$server_id" "POST" "api/v1/oidc/$provider_name/identity_mappings/" "$json_payload" "$debug")
    
    local http_code="${response_combined%%:*}"
    local response="${response_combined#*:}"
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo "✅ OIDC identity mapping '$mapping_name' created successfully"
        echo "Response: $response"
        return 0
    elif [ "$http_code" = "409" ]; then
        echo "⚠️  OIDC identity mapping '$mapping_name' already exists (HTTP 409)"
        return 1
    else
        echo "❌ Failed to create OIDC identity mapping '$mapping_name' (HTTP $http_code)"
        echo "Response: $response"
        return 2
    fi
}



jf_check_all_oidc_providers() {
    # Check multiple OIDC providers
    # Usage: jf_check_all_oidc_providers <server_id> <provider_name1> <provider_name2> ...
    # Returns: 0 if all exist, 1 if any not found, 2 on error

    local server_id="$1"
    shift
    local providers=("$@")
    local all_exist=true

    if [ -z "$server_id" ] || [ ${#providers[@]} -eq 0 ]; then
        echo "Usage: jf_check_all_oidc_providers <server_id> <provider_name1> <provider_name2> ..." >&2
        return 2
    fi

    echo "Checking OIDC providers on server '$server_id':"
    echo "================================================"

    for provider in "${providers[@]}"; do
        if jf_oidc_provider_check "$server_id" "$provider"; then
            echo "✅ Provider '$provider' exists"
        else
            local exit_code=$?
            if [ $exit_code -eq 1 ]; then
                echo "❌ Provider '$provider' does not exist"
                all_exist=false
            else
                echo "❌ Error checking provider '$provider'"
                return 2
            fi
        fi
        echo ""
    done

    if [ "$all_exist" = true ]; then
        echo "All OIDC providers exist"
        return 0
    else
        echo "Some OIDC providers are missing"
        return 1
    fi
}

# === Script Entry Point ===
# Check repositories
# jf_check_all_repos academy1 lab110-npm-sandbox-local lab110-npm-remote lab110-npm-virtual


# Check OIDC providers (example usage)
# echo "🔍 Debugging OIDC provider check..."
# echo "================================================"

# First, let's test connectivity for both servers
# echo "1. Testing connectivity for psazuse server..."
# jf_test_connectivity psazuse

# echo ""
# echo "3. Listing available OIDC providers on psazuse..."
# jf_list_oidc_providers psazuse true


# echo ""
# echo "5. Testing OIDC provider check with debug..."
# jf_oidc_provider_check psazuse sureshv-github-actions-jfcli true


# echo ""
# echo "7. Running the full check..."
# jf_check_all_oidc_providers psazuse sureshv-github-actions-jfcli

echo ""
echo "================================================"
echo ""

