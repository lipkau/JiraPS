function ConvertTo-JiraUser {
    [CmdletBinding( )]
    [OutputType([AtlassianPS.JiraPS.User])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.User](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        key,
                    accountId,
                    name,
                    displayName,
                    emailAddress,
                    @{Name = "active"; Expression = { [System.Convert]::ToBoolean($_.active) } },
                    @{Name = "avatar"; Expression = { ConvertTo-JiraAvatar $_.avatarUrls } },
                    timeZone,
                    locale,
                    accountType,
                    @{Name = "groups"; Expression = { if ($_.groups) { $_.groups.items.name } else { $null } } },
                    @{Name = "RestUrl"; Expression = { $object.self } }
                )
            )
        }
    }
}
