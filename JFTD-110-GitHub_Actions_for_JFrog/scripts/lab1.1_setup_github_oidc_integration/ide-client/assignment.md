In this lab, you will configure your JFrog Platform instance to return an ephemeral JFrog Access Token to a Github Actions workflow run.  We will first setup the OIDC integration and create an [Identity Mapping](https://jfrog.com/help/r/jfrog-platform-administration-documentation/understanding-the-oidc-token).  This will allow each student's Github Actions workflow run to authenticate to each JPD.
### Step 1: Create the Github OIDC Integration object in your JFrog Platform instance
1. Log into your JFrog Platform interface (JFrog Platform UI tab).

[button label="JFrog Platform UI"](tab-0)

```md
			- User: admin
			- Password: Admin1234!
```
2. Navigate to `Administration -> General Management -> Manage Integrations - > New Integration -> OpenID Connect tab -> New Integration`.
3. Select `Open ID Connect` in the drop-down menu.
4. Enter the following values in the fields:
* **Provider Name:** Can be anything, but Name cannot contain spaces or special characters.  Hyphens (`-`) are acceptable.  Recommendation is to call it `<your-initials>githuboidc`
* **Provider Type:** `Github`
* **Description:** Not required, can skip
* **Provider URL**: Autofilled after selecting “Provider Type”
* **Audience:** Leave Blank
* **Organization:** The student’s Github account name, usually the same as the student’s Github user name. ( To discuss: there is no "Organization" field in this screen)
5. Copy the Provider name for use in the next step.

>  _Optional:_ Ensure the `JFrog CLI` tab is selected, then click “Show Snippet” to reveal a small snippet of YAML that can be used to deploy the JFrog CLI.  This is a minmal configuration that would be required to properly configure your workflow to use the integration we just created.  As a convenience, we have supplied a configuration block in the source code repository that covers the necessary configuration.  The snippet shown here is for reference only.

6.  Supply the Provider name you copied in the previous step as a Repository Variable named `JF_OIDC_PROVIDER_NAME`. with the value you used in step 4 and copied in step 5.
Validate that your workflow file has a block that looks similar to this:
```
      - name: "Get Artifactory Access Token and Setup JFrog CLI"
        uses: jfrog/setup-jfrog-cli@v4
        id: setup-cli
        env:
          JF_URL: ${{vars.JF_RT_URL}}   # example: http://academy-artifactory.dzmfffgzzkmf.instruqt.io
        with:
          version: latest
          oidc-provider-name: ${{ vars.JF_OIDC_PROVIDER_NAME }}
	```
Next we will configure an Identiy Mapping.  An identity mapping is the object that connects the Github Actions workflow run identity with a JFrog user, group or Admin.  You can have many identity mappings defined in one Integration object.

7. Go into your OIDC Integration Page you created in the previous lab.
8. Under the "Identity Mappings" Section, ensure the "Global" tab is highlighted.
9. Click "Add Identity Mapping"
10. In the "Identity Mappings" fly-out, configure the following settings:
- **Name**: This can by any value, keep it simple
- **Priority**:  We are only creating one identity mapping, so you put any numerical value in here.  It's reommended to set as 100 to allow for adding other mappings easily before and after this one.
- **Description**: Feel free to add a description, but this is not required.
- **Claims JSON**:  This is where you will configure the *required* claims that *must* be present on the Identity Token that your Github Actions Workflow will send to your Jfrog Platform instance.  For details on what this identity token contains, refer to this [Github documentation page](https://docs.github.com/en/actions/concepts/security/about-security-hardening-with-openid-connect#understanding-the-oidc-token).  For now, we will keep things simple and add a JSON-formatted bit of text that will be similar to:
```
{ "repository": "jfrog/SwampUp2025"}
```
Replace `"jfrog/SwampUp2025"` with your actual repository name.
In "Access Token Settings" section , specify the following values:
-**User name** :  `admin` ,
-**Service**: `artifactory`
-**Token Expiration time (In Minutes)** =  10

## Github Actions Workflow Specification
1. In your Github Actions Workflow Spec YAML file, add the `permissions` block as follows:
Note: This step is already done in the `.github/workflows/jftd-110-jfcli-node.yml`
```
name: "JFTD-110-GitHub_Actions_for_JFrog: NPM Package with OIDC"
description: "This workflow demonstrates how to use JFrog CLI with OIDC authentication to build and publish an NPM package, manage builds"
on:
  push:
    paths:
      - 'JFTD-110-GitHub_Actions_for_JFrog/**'
permissions:
  actions: read # for detecting the Github Actions environment.
  id-token: write # for creating OIDC tokens for signing.
  packages: write # for uploading attestations.
  contents: read
  security-events: write # Required for uploading code scanning.
```
This will allow your Github Actions workflow to request an identity token from the Github OIDC service.







