### Lab Exercise: Create and configure Npm Virtual repository

#### **LAB I: Developer Experience**

**Objective:** This lab exercise will guide your through the create a  Npm Virtual repository

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
This step configures the Npm environment to access the JFrog platform for Npm modules.
1. Open the terminal tab [button label="IDE Terminal"](tab-2)
2. Run these commands

```
 /root/jfrog/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/env-config.sh
```
3. Paste the token and press enter

### **Step 3: Create a Npm virtual repository**
```
  lab110-npm-virtual:
    type: npm
    repoLayout: npm-default
    repositories:
      - lab110-npm-sandbox-local
      - lab110-npm-remote
    defaultDeploymentRepo: lab110-npm-sandbox-local
```
Run:
```
source /root/.bashrc

/root/jfrog/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/setup-init.sh
```

![lab110-npm-virtual.png](https://github.com/jfrog/SwampUp2025/blob/JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/lab110-npm-virtual.png)


#### **Expected Results:**
The repository named `lab110-npm-virtual` should exist . Click on "Check" below to verify your lab environment .

Set the "JF_URL"  in your Github action workflow to the the value printed by the following:
```

echo "http://academy-artifactory.$_SANDBOX_ID.instruqt.io"
```