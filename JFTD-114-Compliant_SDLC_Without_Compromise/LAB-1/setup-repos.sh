#!/bin/bash
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
jf rt ping

export JFROG_CLI_LOG_LEVEL="DEBUG" 

setup(){ 
    printf "\n ------------------------------------------------------------  "
    printf "\n  ----------------    REPO Setup for LAB-1  ----------------  "
    printf "\n ------------------------------------------------------------  \n"
    create-remote-repos
    create-local-repos
    create-virtual-repos
}
create-remote-repos(){
    # Create new REMOTE repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 1. Creating REMOTE repositories \n"
    reposData="[ { \"key\": \"jftd114-lab1-mvn-remote\", \"packageType\": \"maven\", \"rclass\": \"remote\", \"url\": \"https://repo1.maven.org/maven2/\", \"xrayIndex\": true} ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "Remote Repositories created:\n $repoResponse \n\n"
}
create-local-repos(){
    # Create new LOCAL repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 2. Creating LOCAL repositories \n"
    reposData="[ {\"key\": \"jftd114-lab1-mvn-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"xrayIndex\": true }  ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "LOCAL Repositories created:\n $repoResponse \n\n"
}

create-virtual-repos(){
    # Create new virtual repos
    printf "\n\n 3. Creating VIRTUAL repositories \n"

    reposData="[ { \"key\": \"jftd114-lab1-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-lab1-mvn-local\", \"repositories\": [ \"jftd114-lab1-mvn-local\", \"jftd114-lab1-mvn-remote\"], \"xrayIndex\": true }  ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    
    printf "VIRTUAL Repository created:\n $repoResponse \n\n"
}


verify(){
    printf "\n -------------------------------------------------------------  "
    printf "\n ----------------------  LAB-1: Verify  ----------------------  "
    printf "\n -------------------------------------------------------------  \n"
    load-config
    printf "\n\n 1. Verifying Remote Repositories \n"  # ref: https://jfrog.com/help/r/jfrog-rest-apis/get-repository-configuration-v2
    mvnStatus=$(jf rt curl -XGET /api/v2/repositories/jftd114-lab1-mvn-virtual --head --silent -o /dev/null -w "%{http_code}")

    if [[ "$mvnStatus" -ne 200 ]]; then
        printf "Error: Remote Repository jftd114-lab1-mvn-virtual not found or inaccessible. Status: $mvnStatus \n"
        exit 1
    else
        printf "Success: Remote Repository jftd114-lab1-mvn-virtual is accessible. Status: $mvnStatus \n"
    fi
}


# Check for 1 argument
if [ $# -ne 1 ]; then
  printf "    ./setup-repos.sh <setup | verify> "
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