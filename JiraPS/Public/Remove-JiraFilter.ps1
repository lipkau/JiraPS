function Remove-JiraFilter {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( ConfirmImpact = "Medium", SupportsShouldProcess )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('Id')]
        [AtlassianPS.JiraPS.Filter]
        $Filter,

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

        $resourceURi = "$server/rest/api/latest/filter/{0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_filter in $Filter) {
            $parameter['URI'] = $resourceURi -f $_filter.Id

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($_filter.toString(), "Deleting Filter")) {
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
