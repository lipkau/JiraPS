function Get-JiraUser {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = 'Self' )]
    [OutputType( [AtlassianPS.JiraPS.User] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = 'ByUserName' )]
        [ValidateNotNullOrEmpty()]
        [Alias('AccountId', 'Key')]
        [AtlassianPS.JiraPS.User[]]
        $Username,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceUri_Self = "$server/rest/api/latest/myself"
        $resourceUri_Exact = "$server/rest/api/latest/user"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $parameter = @{
            Method       = "GET"
            GetParameter = @{}
            OutputType   = "JiraUser"
            Credential   = $Credential
            Cmdlet       = $PSCmdlet
        }

        switch ($PSCmdLet.ParameterSetName) {
            "Self" {
                $parameter["URI"] = $resourceUri_Self

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                if ($result = Invoke-JiraMethod @parameter) {
                    $parameter["URI"] = $result.RestUrl
                    $parameter["GetParameter"]["expand"] = "groups"

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            "ByUserName" {
                foreach ($_user in $UserName) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_user]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_user [$_user]"

                    if (-not $_user.identify()) {
                        $writeErrorSplat = @{
                            Exception    = "Missing property for identification"
                            ErrorId      = "InvalidData.User.MissingIdentificationProperty"
                            Category     = "InvalidData"
                            Message      = "User needs to be identifiable by AccountId or Key."
                            TargetObject = $_user
                        }
                        WriteError @writeErrorSplat
                    }

                    $parameter["URI"] = $resourceUri_Exact
                    $parameter["GetParameter"]["expand"] = "groups"
                    $parameter["GetParameter"][$_user.identify().Key] = $_user.identify().Value

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
