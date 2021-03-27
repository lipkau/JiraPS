function Get-JiraRole {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_Search' )]
    [OutputType( [AtlassianPS.JiraPS.Role] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Search' )]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = '_ById' )]
        [AtlassianPS.JiraPS.Role[]]
        $Role,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi_ById = "$server/rest/api/latest/role"
        $resourceURi_Search = "$server/rest/api/latest/project/{0}/role"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_ById' {
                foreach ($_role in $Role) {
                    $parameter = @{
                        Uri        = "$resourceURi_ById/$_role"
                        Method     = "GET"
                        OutputType = "JiraRole"
                        Credential = $Credential
                        Cmdlet     = $PSCmdlet
                    }

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            '_Search' {
                $parameter = @{
                    Uri        = "$resourceURi_Search" -f $Project.Key
                    Method     = "GET"
                    Credential = $Credential
                    Cmdlet     = $PSCmdlet
                }

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                $roles = Invoke-JiraMethod @parameter | ConvertTo-Hashtable

                foreach ($role in $roles.Keys) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$role]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$role [$role]"

                    $parameter = @{
                        Uri        = $roles["$role"]
                        Method     = "GET"
                        OutputType = "JiraRole"
                        Credential = $Credential
                        Cmdlet     = $PSCmdlet
                    }

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
