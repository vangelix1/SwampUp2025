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
    reposData="[ { \"key\": \"jftd114-mvn-remote\", \"packageType\": \"maven\", \"rclass\": \"remote\", \"url\": \"https://repo1.maven.org/maven2/\"} , { \"key\": \"jftd114-pypi-remote\", \"packageType\": \"pypi\", \"rclass\": \"remote\", \"url\": \"https://files.pythonhosted.org\"}, { \"key\": \"jftd114-npm-remote\", \"packageType\": \"npm\", \"rclass\": \"remote\", \"url\": \"https://registry.npmjs.org/\"} ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "Remote Repositories created:\n $repoResponse \n\n"
}
create-local-repos(){
    # Create new LOCAL repo and refer https://jfrog.com/help/r/jfrog-rest-apis/create-multiple-repositories
    printf "\n\n 2. Creating LOCAL repositories \n"
    reposData="[ {\"key\": \"jftd114-mvn-snapshot-local\", \"packageType\": \"maven\", \"rclass\": \"local\" }, { \"key\": \"jftd114-mvn-dev-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"DEV\" ] }, { \"key\": \"jftd114-mvn-prod-local\", \"packageType\": \"maven\", \"rclass\": \"local\", \"environments\": [ \"PROD\" ] }, {\"key\": \"jftd114-pypi-snapshot-local\", \"packageType\": \"pypi\", \"rclass\": \"local\" }, { \"key\": \"jftd114-pypi-dev-local\", \"packageType\": \"pypi\", \"rclass\": \"local\", \"environments\": [ \"DEV\" ] }, { \"key\": \"jftd114-pypi-prod-local\", \"packageType\": \"pypi\", \"rclass\": \"local\", \"environments\": [ \"PROD\" ] }, {\"key\": \"jftd114-npm-snapshot-local\", \"packageType\": \"npm\", \"rclass\": \"local\" }, { \"key\": \"jftd114-npm-dev-local\", \"packageType\": \"npm\", \"rclass\": \"local\", \"environments\": [ \"DEV\" ] }, { \"key\": \"jftd114-npm-prod-local\", \"packageType\": \"npm\", \"rclass\": \"local\", \"environments\": [ \"PROD\" ] }  ]"

    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    printf "LOCAL Repositories created:\n $repoResponse \n\n"
}

create-virtual-repos(){
    # Create new virtual repos
    printf "\n\n 3. Creating VIRTUAL repositories \n"
    # reposData="{ \"key\": \"jftd114-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-mvn-snapshot-local\", \"repositories\": [ \"jftd114-mvn-snapshot-local\", \"jftd114-mvn-dev-local\", \"jftd114-mvn-prod-local\", \"jftd114-mvn-remote\"] }"

    reposData="[ { \"key\": \"jftd114-mvn-virtual\", \"packageType\": \"maven\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-mvn-snapshot-local\", \"repositories\": [ \"jftd114-mvn-snapshot-local\", \"jftd114-mvn-dev-local\", \"jftd114-mvn-prod-local\", \"jftd114-mvn-remote\"] }, { \"key\": \"jftd114-pypi-virtual\", \"packageType\": \"pypi\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-pypi-snapshot-local\", \"repositories\": [ \"jftd114-pypi-snapshot-local\", \"jftd114-pypi-dev-local\", \"jftd114-pypi-prod-local\", \"jftd114-pypi-remote\"] }, { \"key\": \"jftd114-npm-virtual\", \"packageType\": \"npm\", \"rclass\": \"virtual\", \"description\": \"The virtual repository public description\", \"defaultDeploymentRepo\": \"jftd114-npm-snapshot-local\", \"repositories\": [ \"jftd114-npm-snapshot-local\", \"jftd114-npm-dev-local\", \"jftd114-npm-prod-local\", \"jftd114-npm-remote\"] } ]"

    # refer 1 virtual repo: https://jfrog.com/help/r/jfrog-rest-apis/create-repository
    # repoResponse=$(jf rt curl -XPUT /api/repositories/jftd114-mvn-virtual --header 'Content-Type: application/json' --data "$reposData")
    repoResponse=$(jf rt curl -XPUT /api/v2/repositories/batch --header 'Content-Type: application/json' --data "$reposData")
    
    printf "VIRTUAL Repository created:\n $repoResponse \n\n"
}

setup


printf "\n ------------------------------------------------------------  "