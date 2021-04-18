function ConvertTo-JiraComponent {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Component] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.Component](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    description,
                    @{ Name = 'Lead'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.Lead) ?? $null
                        }
                    },
                    assigneeType,
                    @{ Name = 'assignee'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.assignee) ?? $null
                        }
                    },
                    realAssigneeType,
                    @{ Name = 'realAssignee'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.realAssignee) ?? $null
                        }
                    },
                    isAssigneeTypeValid,
                    @{ Name = 'Project'; Expression = {
                            if ($object.projectId -and $object.project) {
                                [AtlassianPS.JiraPS.Project]@{
                                    Id   = $object.projectId
                                    Name = $object.project
                                }
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
