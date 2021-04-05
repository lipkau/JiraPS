---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Add-JiraIssueComment/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Add-JiraIssueComment/
---
# Add-JiraIssueComment

## SYNOPSIS

Adds a comment to an existing Issue

## SYNTAX

### NoRestrictions (Default)

```powershell
Add-JiraIssueComment [-Comment] <String> [-Issue] <AtlassianPS.JiraPS.Issue>
[[-Credential] <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RestrictToGroup

```powershell
Add-JiraIssueComment [-Comment] <String> [-Issue] <AtlassianPS.JiraPS.Issue>
[-RestrictToGroup] <AtlassianPS.JiraPS.Group> [[-Credential] <PSCredential>]
[-WhatIf] [-Confirm] [<CommonParameters>]
```

### RestrictToRole

```powershell
Add-JiraIssueComment [-Comment] <String> [-Issue] <AtlassianPS.JiraPS.Issue>
[-RestrictToRole] <AtlassianPS.JiraPS.Role> [[-Credential] <PSCredential>]
[-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This function adds a comment to an existing Issue.
You can optionally set the visibility of the comment to a specific Group or Role.

## EXAMPLES

### EXAMPLE 1

```powershell
Add-JiraIssueComment -Comment "Test comment" -Issue "TEST-001"
```

This example adds a simple comment to the issue TEST-001.

### EXAMPLE 2

```powershell
Get-JiraIssue "TEST-002" | Add-JiraIssueComment "Test comment from PowerShell"
```

This example illustrates pipeline use from `Get-JiraIssue` to `Add-JiraIssueComment`.

### EXAMPLE 3

```powershell
Get-JiraIssue -Query 'project = "TEST" AND created >= -5d' |
    Add-JiraIssueComment "This issue has been cancelled per Vice President's orders."
```

This example illustrates commenting on all projects which match a given JQL query.
It would be best to validate the query first to make sure the query returns the expected issues!

### EXAMPLE 4

```powershell
$comment = Get-Process | Format-Jira
Add-JiraIssueComment $comment -Issue TEST-003
```

This example illustrates adding a comment based on other logic to a JIRA issue.
Note the use of `Format-Jira` to convert the output of `Get-Process` into a format that is easily read by users.

### EXAMPLE 5

```powershell
Add-JiraIssueComment 'restricted comment' -Issue TEST-003 -RestrictToGroup 'Administrators'
```

Adds a new Comment to the Issue which is restricted so that only members of the
Group 'Administrators' can see it.

### EXAMPLE 6

```powershell
$group = Get-JiraUser | Select-Object Groups -First 1
Add-JiraIssueComment 'restricted comment' -Issue TEST-003 -RestrictToGroup $group
```

Adds a new comment which is restricted for members of the first group of the User
running the command.

### EXAMPLE 7

```powershell
Add-JiraIssueComment 'restricted comment' -Issue TEST-003 -RestrictToRole 'Developer'
```

Adds a new Comment to the Issue which is restricted so that only members of the
'Developer' Role can see it.

## PARAMETERS

### -Comment

Comment that Should be added to JIRA.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Issue

Issue to which to add the comment.

```yaml
Type: AtlassianPS.JiraPS.Issue
Parameter Sets: (All)
Aliases: Key

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RestrictToGroup

Group to which the visibility of the comment should be set to.

```yaml
Type: AtlassianPS.JiraPS.Group
Parameter Sets: (All)
Aliases:

Required: False
Position: False
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestrictToRole

Role to which the visibility of the comment should be set to.

```yaml
Type: AtlassianPS.JiraPS.Role
Parameter Sets: (All)
Aliases:

Required: False
Position: False
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Credentials to use to connect to JIRA.  
If not specified, this function will use anonymous access.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### AtlassianPS.JiraPS.Issue

## OUTPUTS

### AtlassianPS.JiraPS.Comment

## NOTES

This function requires either the `-Credential` parameter to be passed
or a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[Get-JiraIssue](../Get-JiraIssue/)

[Get-JiraIssueComment](../Get-JiraIssueComment/)

[Format-Jira](../Format-Jira/)
