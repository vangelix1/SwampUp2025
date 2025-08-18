#!/bin/bash
arg=${1}

#jf config add academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
# jf config use academy
jf rt ping

BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 
export RT_PY_REPO_VIRTUAL="lab3app-py-virtual-$BUILD_ID" RT_PY_REPO_REMOTE="lab3app-py-remote-$BUILD_ID" RT_PY_REPO_DEFAULT_LOCAL="lab3app-py-default-local-$BUILD_ID" RT_PY_REPO_DEV_LOCAL="lab3app-py-dev-local-$BUILD_ID" RT_PY_REPO_PROD_LOCAL="lab3app-py-prod-local-$BUILD_ID"

setup(){ 
    printf "\n ------------------------------------------------------------  "
    printf "\n ----------------------  LAB-3: Setup  ----------------------  "
    printf "\n ------------------------------------------------------------  \n"
    create-repos
    create-config
}
create-repos(){
    # Create new repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    echo "\n\n 1. Creating repositories: $RT_PY_REPO_VIRTUAL, $RT_PY_REPO_REMOTE, $RT_PY_REPO_DEV_LOCAL, $RT_PY_REPO_PROD_LOCAL  \n"
    reposData="[ { \"key\": \"$RT_PY_REPO_REMOTE\", \"packageType\": \"pypi\", \"rclass\": \"remote\", \"url\": \"https://files.pythonhosted.org\"}, { \"key\": \"${RT_PY_REPO_DEFAULT_LOCAL}\", \"packageType\": \"pypi\", \"rclass\": \"local\"}, { \"key\": \"${RT_PY_REPO_DEV_LOCAL}\", \"packageType\": \"pypi\", \"rclass\": \"local\", \"environments\": [\"DEV\"]}, { \"key\": \"${RT_PY_REPO_PROD_LOCAL}\", \"packageType\": \"pypi\", \"rclass\": \"local\", \"environments\": [\"PROD\"]} ]"

    echo "$reposData"

    reposResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    echo "Remote and LOCAL Repositories created: \n $reposResponse \n\n"

    # virtual repo: https://jfrog.com/help/r/jfrog-rest-apis/create-repository
    virtualRepo="{ \"key\": \"$RT_PY_REPO_VIRTUAL\", \"packageType\": \"pypi\", \"rclass\": \"virtual\", \"repositories\": [\"$RT_PY_REPO_REMOTE\", \"$RT_PY_REPO_DEFAULT_LOCAL\", \"$RT_PY_REPO_DEV_LOCAL\", \"$RT_PY_REPO_PROD_LOCAL\"], \"defaultDeploymentRepo\": \"$RT_PY_REPO_DEFAULT_LOCAL\" }"
    echo "$virtualRepo"

    virtualRepoResponse=$(jf rt curl -XPUT /api/repositories/${RT_PY_REPO_VIRTUAL} --header 'Content-Type: application/json' --data "$virtualRepo")
    echo "Virtual Repositories created: \n $reposResponse \n\n"
}

create-keys(){
    echo "\n Creating RBV2 and Evidence keys \n"
    # apt install expect -y
    create-rbv2-keys
}
create-rbv2-keys(){
    # Create RBV2 keys https://jfrog.com/help/r/jfrog-artifactory-documentation/create-signing-keys-for-release-bundles-v2
    # sudo apt-get install expect jq -y
    spawn gpg --full-generate-key
    expect Your selection? 
    send "1\r"
    expect "What keysize do you want? (3072)"
    send "2048\r"
}
# create-evidence-keys(){
#     # Create Evidence keys https://jfrog.com/help/r/jfrog-artifactory-documentation/evidence-setup
# }
checkout-sourcecode(){
    git clone https://github.com/spring 
}
create-config(){
    configJson="{ \"repos\": { \"remote-py\": \"$RT_PY_REPO_REMOTE\", \"local-py-default\": \"$RT_PY_REPO_DEFAULT_LOCAL\", \"local-py-dev\": \"$RT_PY_REPO_DEV_LOCAL\", \"local-py-prod\": \"$RT_PY_REPO_PROD_LOCAL\", \"virtual-py\": \"$RT_PY_REPO_VIRTUAL\" }, \"buildTimeStamp\": \"$BUILD_ID\" } }"
    echo "\n\n 4. Creating config.json file with the following data: \n $configJson \n"
    echo "$configJson" > config.json
    echo "Config file created successfully."
}
load-config(){
    # read config.json file
    if [ ! -f config.json ]; then
        echo "Error: config.json file not found. Please run the setup first."
        exit 1
    else
        json_data=$(cat config.json)
        echo "Config file loaded successfully."
    fi

    RT_MVN_REMOTE_REPO=$(echo "$json_data" | jq -r '.repos."remote-mvn"')
    RT_PY_REMOTE_REPO=$(echo "$json_data" | jq -r '.repos."remote-py"')
    RT_NPM_REMOTE_REPO=$(echo "$json_data" | jq -r '.repos."remote-npm"')
    cConditionId=$(echo "$json_data" | jq -r '.curation."conditionId"')
    policyId=$(echo "$json_data" | jq -r '.curation."policyId"')
    
    echo "REMOTE_REPOS: $RT_MVN_REMOTE_REPO, $RT_PY_REMOTE_REPO, $RT_NPM_REMOTE_REPO"
    echo "Curation conditionId: $cConditionId    policyId: $policyId"
}

verify(){
    printf "\n -------------------------------------------------------------  "
    printf "\n ----------------------  LAB-3: Verify  ----------------------  "
    printf "\n -------------------------------------------------------------  \n"
    load-config
    printf "\n\n 1. Verifying Remote Repositories \n"  # ref: https://jfrog.com/help/r/jfrog-rest-apis/get-repository-configuration-v2
    mvnStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_MVN_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_MVN_REMOTE_REPO Status: $mvnStatus \n"
    pyStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_PY_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_PY_REMOTE_REPO Status: $pyStatus \n"
    npmStatus=$(jf rt curl -XGET /api/v2/repositories/$RT_NPM_REMOTE_REPO --head --silent -o /dev/null -w "%{http_code}")
    printf "   Remote Repo $RT_NPM_REMOTE_REPO Status: $npmStatus \n"

    printf "\n\n 2. Verifying Curation Condition & Policy \n"  # ref: https://jfrog.com/help/r/jfrog-rest-apis/get-curation-condition-by-id
    conditionStatus=$(jf xr curl -XGET /api/v1/curation/conditions/$cConditionId --head --silent -o /dev/null -w "%{http_code}")
    printf "   Curation Condition id $cConditionId Status: $conditionStatus \n"
             # ref: https://jfrog.com/help/r/jfrog-rest-apis/get-curation-policy-by-id
    policyStatus=$(jf xr curl -XGET /api/v1/curation/policies/$policyId --head --silent -o /dev/null -w "%{http_code}")
    printf "   Curation Policy id $policyId Status: $policyStatus \n"


    # curl -XGET https://psazuse.jfrog.io/ui/api/v1/xray/ui/curation/waiver_requests -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" -H "Content-Type: application/json" -H "X-Xss-Protection: 1; mode=block" -H "X-Content-Type-Options: nosniff" -H "X-Frame-Options: SAMEORIGIN" -H "Cache-Control: no-cache, no-store, must-revalidate" -H "Pragma: no-cache" -H "Expires: 0"


}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./lab1.sh <setup | verify> "
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default setup"
    arg='SETUP'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ ("SETUP" == "${arg}") || ("RUN" == "${arg}") ]] ; then   # start
       setup
    elif [[ "INFO" == "${arg}" ]] ; then   
        cat ./config.json
    elif [[ ("KEYS" == "${arg}") || ("GENKEYS" == "${arg}") ]] ; then  
        # create-keys
        create-rbv2-keys
    elif [[ "VERIFY" == "${arg}" ]] ; then   
        verify 
    else
        echo "Error: Invalid argument. Use 'setup | verify"
        exit 1
    fi
fi
printf "\n ------------------------------------------------------------  "