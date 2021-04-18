function ConvertTo-JiraRemoteLink {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.RemoteIssueLink] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.RemoteIssueLink](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    GlobalId,
                    @{ Name = 'Application'; Expression = {
                            = (ConvertTo-Hashtable -InputObject $object.application) ?? @{ }
                        }
                    },
                    Relationship,
                    @{ Name = 'Object'; Expression = {
                            = (ConvertTo-JiraRemoteObject -InputObject $object.object) ?? $null
                        }
                    },
                    @{ Name = 'RestUrl'; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
