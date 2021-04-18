function Get-JiraField {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.JiraPS.Field] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = '_ById' )]
        [String[]]
        $Id,

        [Parameter( Position = 0, Mandatory, ParameterSetName = '_ByName' )]
        [String[]]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $parameter = @{
            URI        = "$server/rest/api/latest/field"
            Method     = "GET"
            OutputType = "JiraField"
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        $allFields = Invoke-JiraMethod @parameter
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_All' {
                $allFields
            }
            '_ById' {
                foreach ($_id in $Id) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_id]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_id [$_id]"

                    $allFields | Where-Object { ($_.Id -eq $_id) }
                }
            }
            '_ByName' {
                foreach ($_name in $Name) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_name]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_name [$_name]"

                    $allFields | Where-Object { ($_.Name -like $_name) }
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
