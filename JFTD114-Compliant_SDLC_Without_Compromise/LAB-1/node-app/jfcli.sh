# TOKEN SETUP
# jf config add --user=admin --password=Admin1234! --url=http://academy-artifactory:80 --xray-url=http://academy-artifactory/xray --interactive=false --overwrite=true 

# read config.json file
if [ ! -f ../config.json ]; then
    echo "Error: config.json file not found. Please run the 'cd ../ && lab1.sh setup' first."
    exit 1
else
    json_data=$(cat ../config.json)
    echo "Config file loaded successfully."
fi

# Config - Artifactory info
JFROG_CLI_LOG_LEVEL="DEBUG" RT_REPO_REMOTE=$(echo "$json_data" | jq -r '.repos."remote-npm"') 
export JFROG_CLI_LOG_LEVEL="DEBUG" RT_REPO_REMOTE=${RT_NPM_REMOTE_REPO}.  # "curation-blocked-mvn-remote" 

echo " JF_RT_URL: $JF_RT_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

jf npmc --repo-resolve {RT_REPO_REMOTE}

jf ca --format=table --threads=100
