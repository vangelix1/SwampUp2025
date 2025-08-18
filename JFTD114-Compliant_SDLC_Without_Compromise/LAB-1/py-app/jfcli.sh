# TOKEN SETUP
#jf config add academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
# jf config use academy

# read config.json file
if [ ! -f ../config.json ]; then
    echo "Error: config.json file not found. Please run the 'cd ../ && lab1.sh setup' first."
    exit 1
else
    json_data=$(cat ../config.json)
    echo "Config file loaded successfully."
fi

# Config - Artifactory info
JFROG_CLI_LOG_LEVEL="DEBUG" RT_REPO_REMOTE=$(echo "$json_data" | jq -r '.repos."remote-py"')  # "curation-blocked-py-remote" 

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_PY_REMOTE_REPO"

jf pipc --repo-resolve=${RT_REPO_REMOTE} 

jf ca --requirements-file=requirements.txt --format=table --threads=100
