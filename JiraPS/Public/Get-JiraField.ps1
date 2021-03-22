function Get-JiraField {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.JiraPS.Field] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Search' )]
        [AtlassianPS.JiraPS.Field[]]
        $Field,

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
            '_Search' {
                foreach ($_field in $Field) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_field]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_field [$_field]"

                    if ($_field.Id) {
                        $allFields | Where-Object { ($_.Id -eq $_field.Id) }
                    }
                    else {
                        $allFields | Where-Object { ($_.Name -like $_field.Name) }
                    }
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
