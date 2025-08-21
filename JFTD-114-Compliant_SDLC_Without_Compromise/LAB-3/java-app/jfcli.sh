# TOKEN SETUP
# jf config add academy --url='http://academy-artifactory' --user='admin' --password='Admin1234!' --interactive=false --overwrite=true 
# jf config show
# jf config use academy


# Config - Artifactory info
export JFROG_CLI_LOG_LEVEL="DEBUG" 
export RT_MVN_VIRTUAL_REPO="jftd114-mvn-virtual"   # jftd114-mvn-snapshot-local, jftd114-mvn-dev-local, jftd114-mvn-prod-local

# Create RBv2 key
export VAR_RBv2_SIGNING_KEY=""

# Create Evidence key
export VAR_EVD_PRIVATEKEY=
export VAR_EVD_KEY_ALIAS=""



export JF_RT_URL="http://academy-artifactory:80"
export SERVER_ID="academy"
export BUILD_NAME="lab-3" BUILD_ID="$(date '+%Y-%m-%d-%H-%M')" 

# maven Config
jf mvnc --global --repo-resolve-releases ${RT_REPO_MVN_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_MVN_VIRTUAL} 

jf mvn clean install --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

# Build Info
echo "\n**** Build Info ****\n"
jf rt bce ${BUILD_NAME} ${BUILD_ID}
jf rt bag ${BUILD_NAME} ${BUILD_ID}
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true


# Evidence to build publish
echo "\n **** Evidence: Build Publish **** \n"
export SPEC_EVIDENCE="evd-package.json"
echo "{ \"actor\": \"swampup-user\", \"date\": \"$(date '+%Y-%m-%dT%H:%M:%SZ')\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\":\"Evidence-BuildPublish\" }" > ./${SPEC_EVIDENCE}
jf evd create --build-name ${BUILD_NAME} --build-number ${BUILD_ID} --predicate ./${SPEC_EVIDENCE} --predicate-type https://jfrog.com/evidence/build-signature/v1 --key "${VAR_EVD_PRIVATEKEY}" --key-alias ${VAR_EVD_KEY_ALIAS}
         

# RBv2
## RBv2: release bundle - create   ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/release-lifecycle-management
echo "\n**** RBv2: Create ****\n"
export SPEC_RBv2="RBv2-SPEC.json"  # ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/using-file-specs
echo "{ \"files\": [ {\"build\": \"${BUILD_NAME}/${BUILD_ID}\", \"includeDeps\": \"true\", \"props\": \"\" } ] }"  > $SPEC_RBv2
jf rbc ${BUILD_NAME} ${BUILD_ID} --sync --url="${JF_RT_URL}" --signing-key="${VAR_RBv2_SIGNING_KEY}" --spec="${SPEC_RBv2}" 


## RBv2: release bundle - DEV promote
echo "\n\n**** RBv2: Promoted to NEW --> DEV ****\n\n"
jf rbp --sync --url="${JF_RT_URL}" --signing-key="${VAR_RBv2_SIGNING_KEY}" --server-id="${SERVER_ID}" ${BUILD_NAME} ${BUILD_ID} DEV  --promotion-type='move'

echo "{ \"actor\": \"swampup-user\", \"date\": \"$(date '+%Y-%m-%dT%H:%M:%SZ')\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\":\"Evidence-RBv2\", \"rbv2_stage\":\"DEV\", "mock-unittests": "100/100" }" > ./${SPEC_EVIDENCE}
jf evd create --release-bundle ${BUILD_NAME} --release-bundle-version ${BUILD_ID} --predicate ./${SPEC_EVIDENCE} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${VAR_EVD_PRIVATEKEY}" --key-alias ${VAR_EVD_KEY_ALIAS}

