---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Find-JiraUser/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Find-JiraUser/
---
# Find-JiraUser

## SYNOPSIS

Search for Jira users.

## SYNTAX

### ByEmailAddress

```powershell
Find-JiraUser [-EmailAddress] <String> [-IncludeInactive] [[-PageSize] <UInt32>]
[[-Skip] <UInt64>] [-Credential <PSCredential>] [<CommonParameters>]
```

### ByUserName

```powershell
Find-JiraUser [-UserName] <String> [-IncludeInactive] [[-PageSize] <UInt32>]
[[-Skip] <UInt64>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This function all Jira user matching the search criteria.

## EXAMPLES

### EXAMPLE 1

```powershell
Find-JiraUser -UserName user1
```

Returns information about all users with username like user1

### EXAMPLE 2

```powershell
Get-ADUser -filter "Name -like 'John*Smith'" | Select-Object -ExpandProperty samAccountName | Find-JiraUser -Credential $cred
```

This example searches Active Directory for "John*Smith", then obtains their JIRA user accounts.

### EXAMPLE 3

```powershell
Find-JiraUser -EmailAddress "jon.doe@example.com" -Credential $cred
```

Searches for users based on their email address.

### EXAMPLE 4

```powershell 
Find-JiraUser -EmailAddress ""
```

Returns all Jira users of a Jira Cloud server.

## PARAMETERS

### -EmailAddress

Email address to search for.

```yaml
Type: String
Parameter Sets: ByEmailAddress
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName

Name of the user to search for.

```yaml
Type: String
Parameter Sets: ByUserName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeInactive

Include inactive users in the search

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Maximum number of user to be returned.

> The API does not allow for any value higher than 1000.

```yaml
Type: UInt32
Parameter Sets: ByUserName
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip

Controls how many objects will be skipped before starting output.

Defaults to 0.

```yaml
Type: UInt64
Parameter Sets: ByUserName
Aliases:

Required: False
Position: Named
Default value: 0
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### [String]

Username, name, or e-mail address

## OUTPUTS

### [AtlassianPS.JiraPS.User]

## NOTES

This function requires either the `-Credential` parameter to be passed
or a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[Get-JiraUser](../Get-JiraUser/)

[New-JiraUser](../New-JiraUser/)

[Remove-JiraUser](../Remove-JiraUser/)
