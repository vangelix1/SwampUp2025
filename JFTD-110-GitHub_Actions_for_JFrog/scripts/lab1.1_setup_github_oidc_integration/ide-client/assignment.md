1. In Student Instance,
Log into your JFrog Platform interface (JFrog Platform UI tab).

[button label="JFrog Platform UI"](tab-0)

```md
			- User: admin
			- Password: Admin1234!
```
2. Navigate to `Administration -> General Management -> Manage Integrations - > OpenID Connect tab -> New Integration`.
3. Select `Open ID Connect` in the drop-down menu.
4. Enter the following values in the fields:
* **Provider Name:** Can be anything, but Name cannot contain spaces or special characters.  Hyphens (`-`) are acceptable.  Recommendation is to call it `<your-initials>githuboidc`
* **Provider Type:** `Github`
* **Description:** Not required, can skip
* **Provider URL**: Autofilled after selecting “Provider Type”
* **Audience:** Leave Blank
* **Organization:** The student’s Github account name, usually the same as the student’s Github user name. ( To discuss: there is no "Organization" field in this screen)
6. Ensure the `JFrog CLI` tab is selected, then click “Show Snippet” to reveal a small snippet of YAML that can be used to deploy the JFrog CLI
7. Fork the https://github.com/jfrog/SwampUp2025.git to your Github.
8. Please create following Github action variables in your  forlked Github repo :
           a) `JF_RT_URL` with value   printed by the following ( example: http://academy-artifactory.dzmfffgzzkmf.instruqt.io ) :
```
echo "http://academy-artifactory.$_SANDBOX_ID.instruqt.io"
```
           b) JF_OIDC_PROVIDER_NAME with the value you used in step 4 above ( example: `svk-githuboidc` ).
9. Copy and paste the snippet into the Github Action `.github/workflows/jftd-110-jfcli-node.yml` in IDE , commit and push.
Note:  This step is already done in the .github/workflows/jftd-110-jfcli-node.yml file  .
So you can  just  replace `http://academy-artifactory.dzmfffgzzkmf.instruqt.io` with your url
from step 8 , in the comment and commit and push to your github repo.
```
      - name: "Setup JFrog CLI"
        uses: jfrog/setup-jfrog-cli@v4
        id: setup-cli
        env:
          JF_URL: ${{vars.JF_RT_URL}}   # example: http://academy-artifactory.dzmfffgzzkmf.instruqt.io
        with:
          version: latest
          oidc-provider-name: ${{ vars.JF_OIDC_PROVIDER_NAME }}
	```