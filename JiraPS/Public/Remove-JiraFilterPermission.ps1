function Remove-JiraFilterPermission {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [AtlassianPS.JiraPS.Filter]
        $Filter,

        [Parameter( Position = 1, Mandatory )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.FilterPermission[]]
        $Permission,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $parameter = @{
            Method     = "DELETE"
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }

        $resourceURi = "$server/rest/api/latest/filter/{0}/permission/{1}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # TODO: check that filter has id

        foreach ($_permission in $Permission) {
            # TODO: check that filterpermission has id

            $parameter['URI'] = $resourceURi -f $Filter.Id, $_permission.Id

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Filter.ToString(), "Remove Permission [$($_permission.Type)]")) {
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
