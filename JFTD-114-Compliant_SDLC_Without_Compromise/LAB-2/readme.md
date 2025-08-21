# Lab 2: Identify Secrets & Malicious Indicators

## Prerequisites
Before you begin, make sure you have the following:
- VS Code: Installed on your machine.
- JFrog Platform Account: You'll need the URL and login credentials for your JFrog environment.
- A Project to Scan: Have a sample project with some code ready to be scanne

### Setup and Authentication
First, let's get the JFrog extension installed and connected to your account.
- Pre installed the JFrog Extension in the IDE 

### Connect to Your JFrog Platform:
- Click on the JFrog icon in the Activity Bar to open the JFrog panel.
- You will be prompted to sign in. Enter your JFrog Platform URL and your Username and Password/Access Token.
- Click Sign In to establish the connection. If you use SSO, there's an option for that as well.

### Configuring Security Policies and Scans
Now, let's set up the rules that JFrog will use to scan your code. These are managed through "Policies" and "Watches" in your JFrog Platform.
- Create a Security Policy in JFrog Xray:
    - Log in to your JFrog Platform in your web browser.
    - Navigate to the Administration module, then go to Xray > Watches & Policies.
    - Click on the Policies tab and then New Policy.
    - Give your policy a Name (e.g., "Secrets-Detection-Policy") and choose the Security policy type.
    - Click Add Rule. For this lab, create a rule that triggers on "High" or "Critical" severity issues. This will be enough to catch most secrets.
    - Save the rule and the policy.
- Create a Watch to Apply the Policy:
    - In the same Watches & Policies section, go to the Watches tab and click New Watch.
    - Give your watch a Name (e.g., "IDE-Scans-Watch").
    - Under Manage Resources, add the repositories or builds you want this watch to monitor. For local IDE scans, you can assign it to a project you've set up in JFrog.
    - Under Manage Policies, add the "Secrets-Detection-Policy" you just created to the watch.
    - Click Create to save the watch.
- Configure the VS Code Extension to Use the Policy:
    - Back in VS Code, open the Command Palette (Ctrl+Shift+P).
    - Type "JFrog: Focus on project" and select the project associated with your watch. This tells the extension which set of policies to apply.

### Running the Scan
With everything configured, you're ready to scan your project.
- Open the Project: Make sure you have your project folder open in VS Code.
- Initiate the Scan:
    - Click on the JFrog icon in the Activity Bar.
    - The extension will automatically start scanning your project's dependencies and code. You should see a progress indicator in the JFrog panel.

### Analyzing the Results
Once the scan is complete, the results will be displayed in the JFrog panel.
- View the Issues: The panel will show a tree view of your project's components and any discovered vulnerabilities.
- Filter for Secrets: Look for issues categorized as "Exposed Secrets" or those with high severity.
- Get More Details: Click on an issue to see detailed information, including:
    - The file and line number where the secret was found.
    - The type of secret (e.g., API key, password).
    - Remediation advice, which usually involves moving the secret to a secure vault or environment variable.


## References
- Source code forked from https://github.com/OWASP/NodeGoat

