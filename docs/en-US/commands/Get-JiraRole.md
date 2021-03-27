---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Get-JiraRole/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Get-JiraRole/
---
# Get-JiraRole

## SYNOPSIS

Retrieve data on the Project's Role(s)

## SYNTAX

### _Search (Default)

```powershell
Get-JiraRole [-Project] <AtlassianPS.JiraPS.Role> [-Credential <PSCredential>]
[<CommonParameters>]
```

### _ById

```powershell
Get-JiraRole -Role <AtlassianPS.JiraPS.Role[]> [-Credential <PSCredential>]
[<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### EXAMPLE 1

```powershell
Get-JiraRole -Project TV
```

Get all available Roles of Project TV.

### EXAMPLE 2

```powershell
$role = Get-JiraRole -TV | Where-Object name -eq 'Administrators'
Add-JiraComment -Comment 'the password is `password`' -Issue TV-100 -RestrictToRole $role
```

Use a role of the project for restricting a Comment.

## PARAMETERS

### -Project

The Project from which to enumerate the Roles.

```yaml
Type: AtlassianPS.JiraPS.Project
Parameter Sets: _Search
Aliases:

Required: True
Position: 1
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Role

The Role to get the data from.

Role must have a value for `Id`.

```yaml
Type: AtlassianPS.JiraPS.Role[]
Parameter Sets: _ById
Aliases:

Required: True
Position: Named
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

### [AtlassianPS.JiraPS.Role]

## NOTES

This function requires either the `-Credential` parameter to be passed or a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

Remaining operations for `Role` have not yet been implemented in the module.

## RELATED LINKS
