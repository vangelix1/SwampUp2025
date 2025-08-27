# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export BUILD_NAME="lab1-py-app" BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 
export RT_REPO_REMOTE="jftd114-pypi-remote" RT_REPO_VIRTUAL="jftd114-pypi-virtual"

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_PY_REMOTE_REPO"

jf pipc --repo-resolve ${RT_REPO_REMOTE}
jf pip install . --build-name=${BUILD_NAME} --build-number=${BUILD_ID}

jf ca --requirements-file=requirements.txt --format=table --threads=100

# jf pip install -r requirements.txt --trusted-host academy-artifactory


# https://academy-artifactory.nxw9dngsibrz.instruqt.io

