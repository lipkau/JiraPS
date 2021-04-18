function ConvertTo-JiraIssueLink {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.IssueLink] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.IssueLink](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    @{ Name = "Type"; Expression = {
                            = (ConvertTo-JiraIssueLinkType -InputObject $object.type) ?? $null
                        }
                    },
                    @{ Name = "InwardIssue"; Expression = {
                            = (ConvertTo-JiraIssue -InputObject $object.inwardIssue) ?? $null
                        }
                    },
                    @{ Name = "OutwardIssue"; Expression = {
                            = (ConvertTo-JiraIssue -InputObject $object.outwardIssue) ?? $null
                        }
                    },
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
