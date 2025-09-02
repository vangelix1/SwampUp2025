clear
# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64" 
export GRADLE_HOME="/usr/share/gradle"
export PATH=$JAVA_HOME/bin:$GRADLE_HOME/bin:$PATH

# Config - Artifactory info
export JF_HOST="academy-artifactory" JFROG_RT_USER="admin" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="http://${JF_HOST}"

export BUILD_NAME="jftd114-lab1" BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 

export RT_REPO_VIRTUAL="jftd114-lab1-virtual" 

printf "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

# Gradle config
jf gradlec --repo-deploy ${RT_REPO_VIRTUAL} --repo-resolve ${RT_REPO_VIRTUAL} --repo-deploy ${RT_REPO_VIRTUAL}

# Curation waiver request
printf "\n\n**** Curation Waiver Request ****\n\n"
jf ca --format=table --threads=100