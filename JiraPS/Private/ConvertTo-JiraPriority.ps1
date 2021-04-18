function ConvertTo-JiraPriority {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Priority] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.Priority](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    description,
                    StatusColor,
                    @{ Name = 'IsSubtask'; Expression = { [System.Convert]::ToBoolean($object.subtask) } },
                    @{ Name = 'AvatarId'; Expression = { [Int]$object.AvatarId } },
                    @{ Name = 'EntityId'; Expression = { [Int]$object.EntityId } },
                    @{ Name = 'HierarchyLevel'; Expression = { [Int]$object.HierarchyLevel } },
                    @{ Name = 'IconUrl'; Expression = {
                            = $object.IconUrl ?? $null
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
