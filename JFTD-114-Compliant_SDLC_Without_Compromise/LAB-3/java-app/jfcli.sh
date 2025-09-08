# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64" # "usr/lib/jvm/java-21-openjdk-amd64"
export M2_HOME="/usr/share/maven"
export GRADLE_HOME="/usr/share/gradle"
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$GRADLE_HOME/bin:$PATH

# Config - Artifactory info
export JF_HOST="academy-artifactory" JFROG_RT_USER="admin" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="http://${JF_HOST}"

export BUILD_NAME="jftd114-lab3" BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 

export RT_REPO_VIRTUAL="jftd114-mvn-virtual" RT_REPO_DEV_LOCAL="jftd114-mvn-dev-local" RT_REPO_PROD_LOCAL="jftd114-mvn-prod-local"
export VAR_RBv2_SPEC_JSON="RBv2-SPEC.json" RBv2_SIGNING_KEY="jftd114-rbv2_key"
export VAR_EVD_SPEC_JSON="EVD-SPEC.json" EVD_KEY_PRIVATE="$(cat ../evd_private.pem)" EVD_KEY_ALIAS="jftd114-evd_key" # EVD_KEY_PUBLIC="$(cat ../evd_public.pem)"  
## openssl rsa -inform PEM -in ../evd_private.pem -check

printf "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

# MVN 
# set -x # activate debugging from here
jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}

jf ca --format=table --threads=100

jf audit --mvn --sast=true --sca=true --secrets=true --licenses=true --validate-secrets=true --vuln=true --format=table --extended-table=true --threads=100 --fail=false


## Create Build
printf "\n\n**** MVN: Package ****\n\n" 
jf mvn clean install --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## bp:build-publish - Publish build info
printf "\n\n**** Build Info: Publish ****\n\n"
jf rt bce ${BUILD_NAME} ${BUILD_ID}
jf rt bag ${BUILD_NAME} ${BUILD_ID}
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary

# Xray indexing - Build ref: https://jfrog.com/help/r/xray-rest-apis/get-builds-indexing-configuration
jf xr curl "/api/v1/binMgr/builds" -H 'Content-Type: application/json' -d "{\"names\": [\"${BUILD_NAME}\"] }"

# Evidence: Build Publish
printf "\n\n**** Evidence: Build Publish ****\n\n"
echo "{ \"session\": \"SwampUp JFTD114\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\": \"Evidence-BuildPublish\" }" > ./${VAR_EVD_SPEC_JSON}
jf evd create --build-name ${BUILD_NAME} --build-number ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}" --key-alias ${EVD_KEY_ALIAS}

sleep 20
jf bs ${BUILD_NAME} ${BUILD_ID} --format=table --extended-table=true --insecure-tls=true --vuln=true --fail=false

# Build Scan V2"  # https://jfrog.com/help/r/xray-rest-apis/scan-build-v2
jf xr curl /api/v2/ci/build -H 'Content-Type: application/json' -d '{"build_name": "${BUILD_NAME}", "build_number": "${BUILD_ID}","rescan":false  }'

## RBv2: release bundle - create   ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/release-lifecycle-management
printf "\n\n**** RBv2: Create ****\n\n"
  # create spec ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/using-file-specs
echo "{ \"files\": [ {\"build\": \"${BUILD_NAME}/${BUILD_ID}\", \"includeDeps\": \"true\", \"props\": \"\" } ] }"  > $VAR_RBv2_SPEC_JSON
jf rbc ${BUILD_NAME} ${BUILD_ID} --signing-key="${RBv2_SIGNING_KEY}" --spec="${VAR_RBv2_SPEC_JSON}" 

# Xray indexing - RBv2 ref: https://jfrog.com/help/r/xray-rest-apis/add-release-bundles-v2-indexing-configuration
jf xr curl "/api/v1/binMgr/release_bundle_v2" -H 'Content-Type: application/json' -d "{\"names\": [\"${BUILD_NAME}\"] }"

sleep 20

## RBv2: release bundle - DEV promote
printf "\n\n**** RBv2: Promoted to NEW --> DEV ****\n\n"
jf rbp ${BUILD_NAME} ${BUILD_ID} DEV --include-repos="${RT_REPO_DEV_LOCAL}" --sync=true --signing-key=${RBV2_SIGNING_KEY} --promotion-type='move'

sleep 20
# EVD: Release Bundle stage DEV
printf "\n\n**** Evidence: RBv2 stage DEV ****\n\n"
echo "{ \"session\": \"SwampUp JFTD114\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\": \"Evidence-RBv2\", \"rbv2_stage\": \"DEV\", \"unittests\": \"100/100\" }" > ./${VAR_EVD_SPEC_JSON}
jf evd create --release-bundle ${BUILD_NAME} --release-bundle-version ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}" --key-alias ${EVD_KEY_ALIAS}

sleep 20
## RBv2: release bundle - PROD promote
printf "\n\n**** RBv2: Promoted to DEV --> PROD ****\n\n"
jf rbp ${BUILD_NAME} ${BUILD_ID} PROD --include-repos="${RT_REPO_PROD_LOCAL}" --sync=true --signing-key=${RBV2_SIGNING_KEY} --promotion-type='move'

# EVD: Release Bundle stage PROD
printf "\n\n**** Evidence: RBv2 stage PROD ****\n\n"
echo "{ \"session\": \"SwampUp JFTD114\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\": \"Evidence-RBv2\", \"rbv2_stage\": \"PROD\", \"prodtests\": \"100/100\" }"\ > ./${VAR_EVD_SPEC_JSON}
jf evd create --release-bundle ${BUILD_NAME} --release-bundle-version ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}" --key-alias ${EVD_KEY_ALIAS}

sleep 10
sleep 3
printf "\n\n**** CLEAN UP ****\n\n"
rm -rf $VAR_RBv2_SPEC_JSON
rm -rf $VAR_EVD_SPEC_JSON


# set +x # stop debugging from here