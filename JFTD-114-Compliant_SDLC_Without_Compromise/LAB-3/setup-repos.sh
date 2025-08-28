#!/bin/bash
#jf config add swampup --url='https://swampupsaasnew.jfrog.io' --user='jftd114-user-01' --password=Admin1234! --interactive=false --overwrite=true 
# jf config show
jf rt ping

export JFROG_CLI_LOG_LEVEL="DEBUG" 


setup(){ 
    printf "\n ------------------------------------------------------------  "
    printf "\n  ----------------    REPO Setup for LAB-3  ----------------  "
    printf "\n ------------------------------------------------------------  \n"
    create-remote-repos
    create-local-repos
    create-virtual-repos
}
create-remote-repos(){
    # Create new REMOTE repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 1. Creating REMOTE repositories \n"
    reposData="[ { \"key\": \"jftd114-mvn-remote\", \"packageType\": \"maven\", \"rclass\": \"remote\", \"url\": \"https://repo1.maven.org/maven2/\"}  ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "Remote Repositories created:\n $repoResponse \n\n"
}
create-local-repos(){
    # Create new LOCAL repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 2. Creating LOCAL repositories \n"
    reposData="[ {\"key\": \"jftd114-mvn-snapshot-local\", \"packageType\": \"maven\", \"rclass\": \"local\" }, { \"key\": \"jftd114-mvn-dev-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"DEV\" ] }, { \"key\": \"jftd114-mvn-prod-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"PROD\" ] }  ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "LOCAL Repositories created:\n $repoResponse \n\n"
}

create-virtual-repos(){
    # Create new virtual repos
    printf "\n\n 3. Creating VIRTUAL repositories \n"
    # reposData="{ \"key\": \"jftd114-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-mvn-snapshot-local\", \"repositories\": [ \"jftd114-mvn-snapshot-local\", \"jftd114-mvn-dev-local\", \"jftd114-mvn-prod-local\", \"jftd114-mvn-remote\"] }"

    reposData="[ { \"key\": \"jftd114-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-mvn-snapshot-local\", \"repositories\": [ \"jftd114-mvn-snapshot-local\", \"jftd114-mvn-dev-local\", \"jftd114-mvn-prod-local\", \"jftd114-mvn-remote\"] }  ]"

    # refer 1 virtual repo: https://jfrog.com/help/r/jfrog-rest-apis/create-repository
    # repoResponse=$(jf rt curl -XPUT /api/repositories/jftd114-mvn-virtual --header 'Content-Type: application/json' --data "$reposData")
    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    
    printf "VIRTUAL Repository created:\n $repoResponse \n\n"
}

setup


printf "\n ------------------------------------------------------------  "