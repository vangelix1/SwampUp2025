# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export RT_NPM_REPO="jftd114-npm-virtual" # jftd114-npm-remote

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_NPM_REPO"

jf npmc --repo-resolve=${RT_NPM_REPO}

jf audit --npm --dep-type=all --threads=100 --licenses=true --sast=true --sbom=true --sca=true --secrets=true --vuln=true --validate-secrets=true --format=table --extended-table=true