function ConvertTo-JiraServerInfo {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.ServerInfo] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.ServerInfo](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        baseUrl,
                    # With PoSh v6, the version shall be casted to [SemanticVersion]
                    version,
                    deploymentType,
                    buildNumber,
                    @{ Name = "BuildDate"; Expression = {
                            if ($object.buildDate) { Get-Date $object.buildDate } else { $null }
                        }
                    },
                    @{ Name = "ServerTime"; Expression = {
                            if ($object.serverTime) { Get-Date $object.serverTime } else { $null }
                        }
                    },
                    scmInfo,
                    serverTitle
                )
            )
        }
    }
}
