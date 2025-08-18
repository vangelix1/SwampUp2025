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
JFROG_CLI_LOG_LEVEL="DEBUG" RT_REPO_REMOTE=$(echo "$json_data" | jq -r '.repos."remote-mvn"')   # "curation-blocked-mvn-remote" 
BUILD_NAME="mvn-cli-req" BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" 

echo " JF_RT_URL: $JF_RT_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

jf mvnc  --repo-resolve-releases {RT_REPO_REMOTE} --repo-resolve-snapshots {RT_REPO_REMOTE}

jf ca --format=table --threads=100
