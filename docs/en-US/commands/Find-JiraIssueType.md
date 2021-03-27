---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Find-JiraIssueType/
schema: 2.0.0
locale: en-US
layout: documentation
permalink: /docs/JiraPS/commands/Find-JiraIssueType/
---

# Find-JiraIssueType

## SYNOPSIS

Find an IssueType by it's name.

## SYNTAX

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1

```powershell
Find-JiraIssueType 'Bug'
```

Finds and returns any IssueTypes where the name matches `Bug`.

### EXAMPLE 2

```powershell
Find-JiraIssueType '*Change'
```

Finds and returns any IssueTypes where the name ends with `Change`.

## PARAMETERS

### -Name

Name of the IssueType we are looking for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information,
see [about_CommonParameters](<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### String[]

## OUTPUTS

### [AtlassianPS.JiraPS.IssueType]

## NOTES

This function requires either the \`-Credential\` parameter to be passed
or a persistent JIRA session.
See \`New-JiraSession\` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[Get-JiraIssueType](../Get-JiraIssueType/)
