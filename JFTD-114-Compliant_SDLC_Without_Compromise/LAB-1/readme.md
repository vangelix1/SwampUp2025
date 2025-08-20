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


## Artifactory 
- change direcotry in IDE UI or IDE Terminal
```
cd ~/jfrog/JFTD-114-Compliant_SDLC_Without_Compromise/LAB-1
```

### Create repositories using CLI
- Run the command in the *LAB-1* folder
    - Remote
    - Local
    - Virtual
````
    ./setup-repos.sh
````


## Curation

### Platform >> Catalog >> Labels
- Create label by clicking button `Create New Label`
<img src="./images/catalog-labels-newbutton.png" />
<br/>
- Enter *Label Name* and *Description*
    - ` ALLOW-THIS `
    - ` ALLOW PACKAGES `
<img src="./images/catalog-labels-create.png" />
<br/>
- Click button `Save Label`


### Administration >> Curation Settings
- Toggle to enable Curation
<img src="./images/curation-enablement.png" />
<br/>
- Enable desired repositories
<img src="./images/curation-enable-repos.png" />
<br/>
- Toggle the remote repositories created using 'setup-repos.sh'
<img src="./images/curation-enable-desired-repos.png" />
<br/>
- Navigate to Administration >> Curation Settings >> Conditions
- Click buttion `Create Condition` 
- Select 'Custom conditions templates' is `Block package unless it has a label in allowed labels list` and enter below values
        - ` DEFAULT-BLOCK-ALL `
        - ` ALLOW-THIS `
<img src="./images/curation-custom-condition.png" />
<br/>
- Navigate to Administration >> Curation Settings >> General
- Click buttion `Create policy` and enter below values
    - Policy Name is ` blocked-pypi-remote `
    - Scope select 'Specific remote repositories' is ` pypi-remote ` 
    <img src="./images/curation-policy-scope.png" /> <br/>
    - Select 'Policy Condition' as ` DEFAULT-BLOCK-ALL `
    <img src="./images/curation-policy-condition.png" /> <br/>
    - Select 'Waiver label' as ` ALLOW-THIS ` and 'Justification' as ` Allow for Swampup Lab `
    <img src="./images/curation-policy-waiver.png" /> <br/>
    - Actions & Notifcation 
        - Select the required action if a violation occurs as ` Block `
        - Configure the waiver request options for blocked packages as ` Manual approved `
        - Owner Groups as ` sup-admin `








### Developer waiver request
<img src="./images/output-0.png" />
<br/>

### Approver screens
<img src="./images/output-1.png" />
<br/>
<img src="./images/output-2.png" />
<br/>

## References
