# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export RT_MVN_REMOTE_REPO="mvn-remote" 
export RT_MVN_VIRTUAL_REPO="jftd114-mvn-virtual"   # jftd114-mvn-snapshot-local, jftd114-mvn-dev-local, jftd114-mvn-prod-local


export BUILD_NAME="lab-3" BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_REPO_MVN_VIRTUAL"


jf mvnc --global --repo-resolve-releases ${RT_REPO_MVN_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_MVN_VIRTUAL} 
