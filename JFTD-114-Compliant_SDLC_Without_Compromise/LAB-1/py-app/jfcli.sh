# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export RT_REPO_REMOTE="pypi-remote" 

echo "JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n RT_REPO_REMOTE: $RT_PY_REMOTE_REPO"

jf pipc --repo-resolve=${RT_REPO_REMOTE} 

jf ca --requirements-file=requirements.txt --format=table --threads=100

