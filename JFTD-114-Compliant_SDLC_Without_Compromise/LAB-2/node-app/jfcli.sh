# TOKEN SETUP
#jf config add academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export RT_NPM_REMOTE_REPO="npm-remote"

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_NPM_REMOTE_REPO"

jf npmc --repo-resolve=${RT_NPM_REMOTE_REPO}
