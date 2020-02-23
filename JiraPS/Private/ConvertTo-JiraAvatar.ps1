function ConvertTo-JiraAvatar {
    [CmdletBinding()]
    [OutputType([AtlassianPS.JiraPS.Avatar])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Avatar](ConvertTo-Hashtable -InputObject ( $a | Select-Object `
                    @{Name = "x16"; Expression = { $_."16x16" } },
                    @{Name = "x24"; Expression = { $_."24x24" } },
                    @{Name = "x32"; Expression = { $_."32x32" } },
                    @{Name = "x48"; Expression = { $_."48x48" } }
                )
            )
        }
    }
}

$var = @"
{
    "48x48": "https://secure.gravatar.com/avatar/a35295e666453af3d0adb689d8da7934?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FOL-4.png&size=48&s=48",
    "24x24": "https://secure.gravatar.com/avatar/a35295e666453af3d0adb689d8da7934?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FOL-4.png&size=24&s=24",
    "16x16": "https://secure.gravatar.com/avatar/a35295e666453af3d0adb689d8da7934?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FOL-4.png&size=16&s=16",
    "32x32": "https://secure.gravatar.com/avatar/a35295e666453af3d0adb689d8da7934?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FOL-4.png&size=32&s=32"
  }
"@
