---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Add-JiraFilterPermission/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/JiraPS/commands/Add-JiraFilterPermission/
---
# Add-JiraFilterPermission

## SYNOPSIS

Share a Filter with other users.

## SYNTAX

### Global (Default)

```powershell
Add-JiraFilterPermission [-Filter] <AtlassianPS.JiraPS.Filter>
[-Global] <Switch> [[-Credential] <PSCredential>] [-WhatIf] [-Confirm]
[<CommonParameters>]
```

### Authenticated

```powershell
Add-JiraFilterPermission [-Filter] <AtlassianPS.JiraPS.Filter>
[-Authenticated] <Switch> [[-Credential] <PSCredential>] [-WhatIf] [-Confirm]
[<CommonParameters>]
```

### Project

```powershell
Add-JiraFilterPermission [-Filter] <AtlassianPS.JiraPS.Filter>
[-Project] <AtlassianPS.JiraPS.Project> [-Role] <AtlassianPS.JiraPS.Role>
[[-Credential] <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Group

```powershell
Add-JiraFilterPermission [-Filter] <AtlassianPS.JiraPS.Filter>
[-Group] <AtlassianPS.JiraPS.Group> [[-Credential] <PSCredential>] [-WhatIf]
[-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Share a Filter with other users, such as "Group", "Project", "ProjectRole",
"Authenticated" or "Global".

## EXAMPLES

### Example 1

```powershell
Add-JiraFilterPermission -Filter 12345 -Global
```

Two methods of sharing Filter 12345 with everyone.

### Example 2

```powershell
12345 | Add-JiraFilterPermission -Authenticated
```

Share Filter 12345 with authenticated users.

_The Id could be read from a file._

### Example 3

```powershell
Get-JiraFilter 12345 | Add-JiraFilterPermission -Group "administrators"
```

Share Filter 12345 only with users in the administrators groups.

### Example 4

```powershell
Add-JiraFilterPermission -Filter 12345 -Project "TV"
```

Restrict this filter to all users who have access to the `TV` project.

### Example 5

```powershell
Add-JiraFilterPermission -Filter 12345 -Project "TV" -Role "Responsibles"
```

Restrict this filter to responiblesof the `TV` project.

## PARAMETERS

### -Filter

Filter object to which the permission Should be applied

```yaml
Type: AtlassianPS.JiraPS.Filter
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Global

Give global access to the filter

```yaml
Type: Switch
Parameter Sets: Global
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Authenticated

Give access to only users who are logged in.

```yaml
Type: Switch
Parameter Sets: Authenticated
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Project

Give access to all users of a project

```yaml
Type: AtlassianPS.JiraPS.Project
Parameter Sets: Project
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role

Give access users which have a specific role in a project.

```yaml
Type: AtlassianPS.JiraPS.Role
Parameter Sets: Project
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group

Give access to only users who are logged in.

```yaml
Type: AtlassianPS.JiraPS.Group
Parameter Sets: Group
Aliases:

Required: True
Position: 1
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
Position: 3
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

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### [AtlassianPS.JiraPS.Filter]

## OUTPUTS

### [AtlassianPS.JiraPS.Filter]

## NOTES

This functions does not validate the input for `-Value`.
In case the value is invalid, unexpected or missing, the API will response with
an error.

This function requires either the `-Credential` parameter to be passed or
a persistent JIRA session.
See `New-JiraSession` for more details.
If neither are supplied, this function will run with anonymous access to JIRA.

## RELATED LINKS

[Find-JiraFilter](../Find-JiraFilter/)

[Get-JiraFilter](../Get-JiraFilter/)

[Get-JiraFilterPermission](../Get-JiraFilterPermission/)

[Remove-JiraFilter](../Remove-JiraFilter/)

[Remove-JiraFilterPermission](../Remove-JiraFilterPermission/)
