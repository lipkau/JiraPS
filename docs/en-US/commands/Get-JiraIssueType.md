---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Get-JiraIssueType/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Get-JiraIssueType/
---
# Get-JiraIssueType

## SYNOPSIS

Returns information about the available issue type in JIRA.

## SYNTAX

### _All (Default)

```powershell
Get-JiraIssueType [-Credential <PSCredential>] [<CommonParameters>]
```

### _ById_

```powershell
Get-JiraIssueType [-IssueType] <AtlassianPS.JiraPS.IssueType[]>
[-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This function retrieves all the available IssueType.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-JiraIssueType
```

This example returns all the IssueTypes on the JIRA server.

### EXAMPLE 2

```powershell
Get-JiraIssueType -IssueType 10000
```

This example returns only the IssueType with Id 10000.

## PARAMETERS

### -IssueType

The IssueType fetch.

IssueType must have a value for `Id`.

```yaml
Type: AtlassianPS.JiraPS.IssueType[]
Parameter Sets: _ById
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

## OUTPUTS

### [AtlassianPS.JiraPS.IssueType]

## NOTES

This function requires either the `-Credential` parameter to be passed
or a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[Find-JiraIssueType](../Find-JiraIssueType/)
