# Lab 1: OSS Filtering using Curated Remote Repo
The script automates the configuration of a JFrog Artifactory instance by setting up remote repositories and a curation policy using the JFrog CLI and REST API

## Prerequisites
- JFrog CLI installed and available in your shell environment.
- Access to your JFrog Artifactory instance with credentials.
- `jq` tool for JSON processing.

## Steps
### Setup
- Configure JFrog CLI for Artifactory and Xray (non-interactive)
- Verify setup configuration and Artifactory availability.
- Artifactory: Creates 3 remote repositories (Maven, PyPI, NPM) with names containing a timestamp.

### Create repositories using CLI
- Run the command in the `LAB-1` folder
````
    ./setup-repos.sh
````
<img src="./images/repo-created.png" />
<br/>
- Verify  the created repos in the `LAB-1` folder
## Verify
````
    ./repos-create.sh verify
````

## Curation
### Enable
- login to JFrog Platform UI using the credentials
- Go to 'Administration' tab
- Enable Curation toggle
<img src="./images/0-curation-enablement.png" />
<br/>
- Enable curation for repoisitories
<img src="./images/1-curation-policies-enable-repo.png" />
<br/>
- Toggle ON for the repos creating using ./setup-repos.sh
<img src="./images/2-curation-enable-repos.png" />
<br/>
- Create catalog label
<img src="./images/3-curation-catalog-label.png" />
<br/>
<img src="./images/3-curation-catalog-label-saved.png" />
<br/>
- Create policy
<img src="./images/3-curation-create-policy.png" />
<br/>








### Developer waiver request
<img src="./images/output-0.png" />
<br/>

### Approver screens
<img src="./images/output-1.png" />
<br/>
<img src="./images/output-2.png" />
<br/>

## References
