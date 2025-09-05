#!/bin/bash

jf rt ping

REPO_JSON=$(jf rt curl "/api/repositories/jftd114-lab1-mvn-virtual" --header 'Content-Type: application/json')

# Validate JSON
if ! echo "$REPO_JSON" | jq . > /dev/null; then
  echo "Error: Failed to fetch or parse repository configuration for '$REPO_NAME'"
  exit 1
fi