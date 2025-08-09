### Lab Exercise: Clone the SwampUP 25 Training repository
We will need each student to have their own fork of the source code repository.  This will allow each student to supply their own values for their instances of the JFrog Platform, supply environment-specific reposiroty variables and make other modifications as we go.

1. In a separate browser tab, log in to your Github account and *Fork* the source code repository found at https://github.com/jfrog/SwampUp2025.
2. Confirm that the fork was successful and the URL is something like `https://github.com/<your Github User Name>/SwampUp25`

### Lab Exercise: Create and configure Npm Virtual repository
This lab exercise will execute some automation to create NPM Local, Remote and Virtual repositories

---
#### **Step-by-Step Instructions:**
### **Step 1: Generate an access token**
1. Log into your JFrog Platform interface (JFrog Platform UI tab).

[button label="JFrog Platform UI"](tab-0)

```md
- User: admin
- Password: Admin1234!
```

2. Close the initial window "Welcome to the JFrog Platform!".
3.  Navigate to  "Administration".
4.  From the navigation bar go to "User Management" and select "Access Tokens"
5.  Click on "Generate Token"
6.  Description:  your choice
7.  User name: **admin**
8.  Click "Generate"
9.  Click "Copy" (save it locally if you need, but do not loose it)

### **Step 2: Configure dev environment**
This step configures the Npm environment to access the JFrog platform for your NPM builds.  The script will prompt you for the JFrog Access Token that you generated in the previous step.
1. Open the terminal tab [button label="IDE Terminal"](tab-2)
2. Run this command:

```
 /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/env-config.sh
```
3. Paste the token from the previous step and press enter.

### **Step 3: Create a Npm virtual repository**
The `setup-init.sh` script will create a Local, Remote and Virtual repositories.  This allows you to build and publish a real NPM package.  The repository setup looks like:
```md
  lab110-npm-virtual:
    type: npm
    repoLayout: npm-default
    repositories:
      - lab110-npm-sandbox-local
      - lab110-npm-remote
    defaultDeploymentRepo: lab110-npm-sandbox-local
```
Run these two shell commands in the `IDE Terminal` tab:
```bash
source /root/.bashrc
/root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/setup-init.sh
```

![lab110-npm-virtual.png](https://github.com/jfrog/SwampUp2025/blob/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/lab110-npm-virtual.png)


#### **Expected Results:**
The repository named `lab110-npm-virtual` should exist . Click on "Check" below to verify your lab environment .

### **Step 4: Set your JFrog Platofrm URL as a Github Repository Variable**
In your fork of the source code repository, you will need to set a Repository Variable so the JFrog CLI will know where to reach your specific JFrog Platform.
Fetch the value that needs to be applied by running the following shell command in your `IDE Terminal` tab:
```
echo "http://academy-artifactory.$_SANDBOX_ID.instruqt.io"
```
This value should be added as the Github Repository variable `JF_RT_URL`.
_Instructions for Github Repository variables can be found [here](https://github.com/tomjfrog/swampup-demo-app.git)_