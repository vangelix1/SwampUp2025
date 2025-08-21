# Lab 3: JFrog RLM & Evidence
This lab demonstrates an end-to-end workflow for building a Maven project, creating a secure and auditable Release Bundle, and promoting it through an environment while attaching signed evidence at each stage.

## Initial Setup & Configuration
- Set up a connection to your JFrog instance named academy and make it the active configuration.
- Define variables for your Maven virtual repository, signing keys for Release Bundles and Evidence, and the build name/ID. This centralizes configuration and makes the script reusable.

## Build the Maven Project & Publish Build-Info
Next, you'll build your Java application using Maven and publish the comprehensive build information to Artifactory.
- Configure Maven Repositories: Use jf mvnc to automatically configure Maven to resolve dependencies from your specified Artifactory virtual repository.
- Run the Maven Build: Execute a clean install build using the jf mvn wrapper. This command captures all dependencies, artifacts, and environment details.
- Publish Build-Info: Use jf rt bp to upload the collected build information to your JFrog Platform, creating a detailed and reproducible record of the build.
- Attach Initial Evidence: Create and attach a signed piece of evidence to the build-info itself, attesting that the build has been successfully published.

## Create the Release Bundle (RBv2)
With a successful build published, you will now package it into a signed, immutable Release Bundle.
- Define the Bundle Contents: Create a specification file that tells JFrog to include all artifacts and dependencies from the build you just published.
- Create the Release Bundle: Run the jf rbc command, pointing to your specification and a signing key. This creates a tamper-proof, signed bundle that represents your release candidate.

## Promote the Release Bundle & Attach Promotion Evidence
Finally, you will promote the Release Bundle to the "DEV" environment and record evidence of this action.
- Promote to DEV: Use the jf rbp command to promote the Release Bundle to the DEV environment. This action can trigger repository moves or copies as defined in your lifecycle management setup.
- Attach Promotion Evidence: Create a new JSON evidence file containing details about the promotion (e.g., mock test results, actor). Attach and sign this evidence directly to the Release Bundle, creating an auditable record that this specific version passed the "DEV" gate.



## References
- [RBv2 keys](https://jfrog.com/help/r/jfrog-artifactory-documentation/create-signing-keys-for-release-bundles-v2)
    - Administration >> Keys Managment >> Signing Keys
- [Evidence keys](https://jfrog.com/help/r/jfrog-artifactory-documentation/evidence-setup)
    - Administration >> Keys Managment >> Public Keys