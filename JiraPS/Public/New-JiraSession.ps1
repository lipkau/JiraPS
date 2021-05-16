function New-JiraSession {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory )]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Hashtable]
        $Headers = @{ },

        [Switch]
        $Passthru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/2/myself"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $parameter = @{
            URI          = $resourceURi
            Method       = "GET"
            Headers      = $Headers
            StoreSession = $true
            Credential   = $Credential
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        $result = Invoke-JiraMethod @parameter

        if ($MyInvocation.MyCommand.Module.PrivateData) {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Adding session result to existing module PrivateData"
            $MyInvocation.MyCommand.Module.PrivateData.Session = $result
        }
        else {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Creating module PrivateData"
            $MyInvocation.MyCommand.Module.PrivateData = @{
                'Session' = $result
            }
        }

        if ($Passthru) {
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
