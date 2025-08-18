#!/bin/bash
arg=${1}

#jf config add  academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
jf rt ping
export JF_ACCESS_TOKEN=$(cat ~/.jfrog/jfrog-cli.conf* | jq -r ".servers[].accessToken")
export JF_URL=$(cat ~/.jfrog/jfrog-cli.conf* | jq -r ".servers[].url")

BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 
export RT_MVN_REMOTE_REPO="mvn-remote" 
export RT_PY_REMOTE_REPO="py-remote" 
export RT_NPM_REMOTE_REPO="npm-remote"


setup(){ 
    printf "\n ------------------------------------------------------------  "
    printf "\n ----------------------  LAB-1: Setup  ----------------------  "
    printf "\n ------------------------------------------------------------  \n"
    create-remote-repos
}
create-remote-repos(){
    # Create new repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 1. Creating 3 remote repositories: $RT_MVN_REMOTE_REPO, $RT_PY_REMOTE_REPO, $RT_NPM_REMOTE_REPO  \n"
    reposData="[ { \"key\": \"$RT_MVN_REMOTE_REPO\", \"packageType\": \"maven\", \"rclass\": \"remote\", \"url\": \"https://repo1.maven.org/maven2/\"} , { \"key\": \"$RT_PY_REMOTE_REPO\", \"packageType\": \"pypi\", \"rclass\": \"remote\", \"url\": \"https://files.pythonhosted.org\"}, { \"key\": \"${RT_NPM_REMOTE_REPO}\", \"packageType\": \"npm\", \"rclass\": \"remote\", \"url\": \"https://registry.npmjs.org/\"} ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "Remote Repositories created:\n $repoResponse \n\n"
}

verify(){
    printf "\n -------------------------------------------------------------  "
    printf "\n ----------------------  LAB-1: Verify  ----------------------  "
    printf "\n -------------------------------------------------------------  \n"
    load-config
    printf "\n\n 1. Verifying Remote Repositories \n"  # ref: https://jfrog.com/help/r/jfrog-rest-apis/get-repository-configuration-v2
    mvnStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_MVN_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_MVN_REMOTE_REPO Status: $mvnStatus \n"
    pyStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_PY_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_PY_REMOTE_REPO Status: $pyStatus \n"
    npmStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_NPM_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_NPM_REMOTE_REPO Status: $npmStatus \n"
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  printf "Error: This script requires exactly 1 arguments."
  printf "    ./repos-create.sh <setup | verify> "
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    printf "User action is NULL, setting to default setup"
    arg='SETUP'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(printf ${arg} | tr [a-z] [A-Z] | xargs)
    printf "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ ("SETUP" == "${arg}") || ("RUN" == "${arg}") ]] ; then   # start
       setup
    elif [[ "VERIFY" == "${arg}" ]] ; then   # Minikube
        verify 
    else
        printf "Error: Invalid argument. Use 'setup | verify"
        exit 1
    fi
fi
printf "\n ------------------------------------------------------------  "