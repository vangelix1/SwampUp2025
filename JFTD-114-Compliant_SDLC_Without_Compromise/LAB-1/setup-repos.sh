#!/bin/bash
#jf config add  academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
jf rt ping

export JFROG_CLI_LOG_LEVEL="DEBUG"


setup(){ 
    printf "\n ------------------------------------------------------------  "
    printf "\n ----------------   REPO Setup for all LABs  ----------------  "
    printf "\n ------------------------------------------------------------  \n"
    create-remote-repos
    create-local-repos
    create-virtual-repos
}
create-remote-repos(){
    # Create new REMOTE repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 1. Creating REMOTE repositories \n"
    reposData="[ { \"key\": \"mvn-remote\", \"packageType\": \"maven\", \"rclass\": \"remote\", \"url\": \"https://repo1.maven.org/maven2/\"} , { \"key\": \"pypi-remote\", \"packageType\": \"pypi\", \"rclass\": \"remote\", \"url\": \"https://files.pythonhosted.org\"}, { \"key\": \"npm-remote\", \"packageType\": \"npm\", \"rclass\": \"remote\", \"url\": \"https://registry.npmjs.org/\"} ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "Remote Repositories created:\n $repoResponse \n\n"
}
create-local-repos(){
    # Create new LOCAL repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 2. Creating LOCAL repositories \n"
    reposData="[ {\"key\": \"lab3-mvn-snapshot-local\", \"packageType\": \"maven\", \"rclass\": \"local\" }, { \"key\": \"lab3-mvn-dev-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"DEV\" ] }, { \"key\": \"lab3-mvn-prod-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"PROD\" ] } ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "LOCAL Repositories created:\n $repoResponse \n\n"
}

create-virtual-repos(){
    # Create new repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-repository
    printf "\n\n 3. Creating VIRTUAL repositories \n"
    reposData="{ \"key\": \"lab3-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"lab3-mvn-snapshot-local\", \"repositories\": [ \"lab3-mvn-snapshot-local\", \"lab3-mvn-dev-local\", \"lab3-mvn-prod-local\", \"mvn-remote\"] }"

    # refer 1 virtual repo: 
    repoResponse=$(jf rt curl -XPUT /artifactory/api/repositories/lab3-mvn-virtual --header 'Content-Type: application/json' --data "$reposData")
    printf "VIRTUAL Repository created:\n $repoResponse \n\n"
}

setup


printf "\n ------------------------------------------------------------  "