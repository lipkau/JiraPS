function Get-JiraComponent {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = 'ByID' )]
    [OutputType( [AtlassianPS.JiraPS.Component] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = 'ByProject' )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Project[]]
        $Project,

        [Parameter( Position = 0, Mandatory, ParameterSetName = 'ByID' )]
        [Alias("Id")]
        [Int[]]
        $ComponentId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceUri_ByProject = "$server/rest/api/latest/project/{0}/components"
        $resourceUri_ById = "$server/rest/api/latest/component"

        $parameter = @{
            Method     = 'GET'
            OutputType = 'JiraComponent'
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            "ByProject" {
                foreach ($_project in $Project) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_project]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_project [$_project]"

                    $parameter["Uri"] = $resourceUri_ByProject -f $_project.Key

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            "ByID" {
                foreach ($_id in $ComponentId) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_id]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_id [$_id]"

                    $parameter["Uri"] = "$resourceUri_ById/$_id"

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
