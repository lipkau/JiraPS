function ConvertTo-JiraRoleActor {
    [OutputType( )]
    [OutputType([AtlassianPS.JiraPS.RoleActor])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.RoleActor](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    @{ Name = "name"; Expression = {
                            if ($object.name) { $object.name }
                            if ($object.actorUser.accountId) { $object.actorUser.accountId }
                        }
                    },
                    displayName,
                    @{ Name = "Type"; Expression = {
                            switch ($object.type) {
                                "atlassian-group-role-actor" { [AtlassianPS.JiraPS.ActorType]"AtlassianGroupRoleActor"; break }
                                "atlassian-user-role-actor" { [AtlassianPS.JiraPS.ActorType]"AtlassianUserRoleActor"; break }
                                Deafult {}
                            }
                        }
                    }
                )
            )
        }
    }
}
