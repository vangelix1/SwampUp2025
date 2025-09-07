# Lab 3: JFrog RLM & Evidence
This lab demonstrates an end-to-end workflow for building a Maven project, creating a secure and auditable Release Bundle, and promoting it through an environment while attaching signed evidence at each stage.

You will perform the following actions using the JFrog CLI:
- Build a Maven project and publish the build information to Artifactory.
- Generate a Software Bill of Materials (SBOM).
- Create and sign a Release Bundle v2.
- Promote the release bundle through DEV and PROD environments.
- Capture signed evidence at each critical stage of the pipeline.

## Prerequisites
Before you begin, ensure you have the following:
- Access to a JFrog Platform environment.
- JFrog CLI installed and configured in your terminal.
- A Java Development Kit (JDK) and Maven installed.
- The lab project files, including the spring-petclinic source code and the provided scripts.

## Setup Instructions
First, you need to prepare your JFrog environment by setting up repositories and signing keys.

### Configure Repositories
This script will create the necessary local, remote, and virtual Maven repositories in your Artifactory instance.
```
./setup-repos.sh
```
This will create the following repositories:
- jftd114-mvn-remote (a remote proxy for Maven Central)
- jftd114-mvn-snapshot-local
- jftd114-mvn-dev-local
- jftd114-mvn-prod-local
- jftd114-mvn-virtual (an aggregation of all the above)

<img src="./images/lab3-repo-0.png" /> <br/>
<img src="./images/lab3-repo-1.png" /> <br/>
<img src="./images/lab3-repo-2.png" /> <br/>

### Create RBv2 GPG and Evidence Signing Keys
Next, you need to generate GPG keys for signing your release bundles (RBv2) and key pairs for creating signed evidence.

Run the ```create-keys.sh``` script with a unique key name. This name will be used for both the GPG key and the evidence signing key alias.

<img src="./images/lab3-keys-0.png" /> <br/>
<img src="./images/lab3-keys-1.png" /> <br/>

## Lab Execution
Now you are ready to execute the full software supply chain pipeline. The jfcli.sh script automates this entire process.

### Run the Pipeline Script
Execute the ```jfcli.sh``` script from your terminal:
```
./jfcli.sh

```
This script will perform the following sequence of actions:

- Maven Build: It compiles the spring-petclinic application, resolves dependencies from the virtual repository, and collects build information.
```
jf mvn clean install ...
```

<img src="./images/lab3-mvn-0.png" /> <br/>

<img src="./images/lab3-mvn-1.png" /> <br/>

- Publish Build Info: The collected build information, which includes the SBOM, is published to Artifactory.
```
jf rt bp ${BUILD_NAME} ${BUILD_ID}
```

<img src="./images/lab3-bp-0.png" /> <br/>

<img src="./images/lab3-bp-1.png" /> <br/>

<img src="./images/lab3-bp-2.png" /> <br/>

<img src="./images/lab3-bp-3.png" /> <br/>

<img src="./images/lab3-bp-4.png" /> <br/>

- Capture Evidence for Build Publish: A signed piece of evidence is created and attached to the buiild publish.
```
jf evd create --release-bundle ${BUILD_NAME} ...
```

<img src="./images/lab3-bp-evd.png" /> <br/>

- Create Release Bundle v2: A secure, immutable release bundle is created from the build and signed with your GPG key.
```
jf rbc ${BUILD_NAME} ${BUILD_ID} --signing-key="${RBv2_SIGNING_KEY}"
```
<img src="./images/lab3-rbc-0.png" /> <br/>


- Promote to DEV: The release bundle is promoted to the "DEV" environment, moving the artifacts to the jftd114-mvn-dev-local repository.
```
jf rbp ${BUILD_NAME} ${BUILD_ID} DEV ...
```

<img src="./images/lab3-rbp-dev-0.png" /> <br/>

<img src="./images/lab3-rbp-dev-1.png" /> <br/>

- Capture Evidence for DEV: A signed piece of evidence is created and attached to the release bundle, attesting to its successful promotion to DEV.
```
jf evd create --release-bundle ${BUILD_NAME} ...
```

<img src="./images/lab3-rbp-dev-2.png" /> <br/>

- Promote to PROD: The release bundle is then promoted from DEV to the "PROD" environment.
```
jf rbp ${BUILD_NAME} ${BUILD_ID} PROD ...
```

<img src="./images/lab3-rbp-prod-0.png" /> <br/>
<img src="./images/lab3-rbp-prod-1.png" /> <br/>

- Capture Evidence for PROD: A final piece of signed evidence is created for the promotion to the PROD environment.
```
jf evd create --release-bundle ${BUILD_NAME} ...
```

<img src="./images/lab3-rbp-prod-2.png" /> <br/>

<img src="./images/lab3-rbp-prod-3.png" /> <br/>


## Test JAR

### Start service
```
java -jar target/jftd114-lab3.jar --server.port=7080 & 
```
<img src="./images/lab3-test-1.png" /> <br/>

### Validate service
```
curl -w "\n" http://localhost:7080/?name=Krishna
```

<img src="./images/lab3-test-2.png" /> <br/>

### Kill service
```
kill $(lsof -t -i :7080) &
```
<img src="./images/lab3-test-3.png" /> <br/>

## Conclusion
Excellent work! You have successfully executed a secure software supply chain pipeline.

In this lab, you have seen how JFrog CLI can automate the process of building, securing, and promoting software releases. By creating signed release bundles and capturing evidence at each stage, you can build a verifiable and tamper-proof audit trail for your software releases, ensuring a compliant and secure SDLC.


## References
- RBv2 keys# https://jfrog.com/help/r/jfrog-artifactory-documentation/create-signing-keys-for-release-bundles-v2
    - Administration >> Keys Managment >> Signing Keys
- Evidence keys# https://jfrog.com/help/r/jfrog-artifactory-documentation/evidence-setup
    - Administration >> Keys Managment >> Public Keys
- JFrog CLI: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/binaries-management-with-jfrog-artifactory/package-managers-integration#running-maven-builds
- Java source code generated using https://start.spring.io
- Artifactory
    - Rest APIs: https://jfrog.com/help/r/jfrog-rest-apis/artifactory-rest-apis
- Xray
    - Rest APIs: https://jfrog.com/help/r/xray-rest-apis
    - https://jfrog.com/help/r/jfrog-security-user-guide/products/xray
- [![Walk through LAB-3 demo](https://img.youtube.com/vi/7rSrEa74eSA/0.jpg)](https://youtu.be/7rSrEa74eSA) 