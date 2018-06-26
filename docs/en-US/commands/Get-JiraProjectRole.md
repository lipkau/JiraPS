---
external help file: JiraPS-help.xml
Module Name: JiraPS
online version: https://atlassianps.org/docs/JiraPS/commands/Get-JiraProject/
schema: 2.0.0
---

# Get-JiraProjectRole

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### _All (Default)
```
Get-JiraProjectRole [-Project] <Object> [-RoleId <UInt32[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### _Search
```
Get-JiraProjectRole [-ProjectId] <UInt32[]> [-RoleId <UInt32[]>] [-Credential <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Credential
{{Fill Credential Description}}

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

### -Project
{{Fill Project Description}}

```yaml
Type: Object
Parameter Sets: _All
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProjectId
{{Fill ProjectId Description}}

```yaml
Type: UInt32[]
Parameter Sets: _Search
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RoleId
{{Fill RoleId Description}}

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object
System.UInt32[]


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
