function ConvertTo-JiraProject {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Project] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.Project](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    Key,
                    name,
                    description,
                    @{ Name = "Lead"; Expression = {
                            = (ConvertTo-JiraUser $object.lead) ?? $null
                        }
                    },
                    @{ Name = "IssueTypes"; Expression = {
                            = (ConvertTo-JiraIssueType $object.issuetypes) ?? $null
                        }
                    },
                    @{ Name = "Roles"; Expression = {
                            = (ConvertTo-JiraRole $object.roles) ?? $null
                        }
                    },
                    @{ Name = "Components"; Expression = {
                            = (ConvertTo-JiraComponent $object.components) ?? $null
                        }
                    },
                    style,
                    @{ Name = 'Category'; Expression = {
                            if ($object.category) { ConvertTo-JiraProjectCategory $object.category }
                            elseif ($object.projectCategory) { ConvertTo-JiraProjectCategory $object.projectCategory }
                            else { $null }
                        }
                    },
                    @{ Name = 'HttpUrl'; Expression = {
                            if ($object.self -and $object.key) {
                                "{0}browse/{1}" -f ($object.self -split 'rest')[0], $object.key
                            }
                            else { $null }
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
