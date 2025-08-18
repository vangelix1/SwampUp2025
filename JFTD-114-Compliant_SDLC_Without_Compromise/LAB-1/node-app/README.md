# Node app

## Prestep
- Create remote repo 'curation-blocked-npm-remote'


## Curation Policy
- login to Artifactory
- go to tab 'Platform'
- left navigation Curation >> Policies 
- Create new policy 
    - policy name: curation-blocked-remote
    - scope: specific repositories
        - select remote repo: curation-blocked-npm-remote
    - Policy Condition: Block all
    - Waiver: BLOCK THIS
    - Actions & Notification: BLOCK
    - Configure the waiver request options for clock packages: Manually approved
        - select decision owner for notification and approval: admin

### Execution using JFrog CLI
```
jf pipc --repo-resolve=${RT_REPO_REMOTE} 

jf ca --format=table --threads=100
```

### Screen flow
<img src="../images/1-PolicyName.png" />
<br/>
<img src="../images/2-Scope.png" />
<br/>
<img src="../images/3-PolicyCondition.png" />
<br/>
<img src="../images/4-Waivers.png" />
<br/>
<img src="../images/5-ActionsAndNotifications.png" />
<br/>