function Get-JiraFilterPermission {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.FilterPermission] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [AtlassianPS.JiraPS.Filter[]]
        $Filter,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/filter/{0}/permission"

        $parameter = @{
            Method     = 'GET'
            OutputType = 'JiraFilterPermission'
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # TODO: test that filter has Id

        foreach ($_filter in $Filter) {
            $parameter['Uri'] = $resourceURi -f $_filter.Id

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            Invoke-JiraMethod @parameter
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
