function Get-JiraUser {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = 'Self' )]
    [OutputType([AtlassianPS.JiraPS.User])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = 'ByUserName' )]
        [ValidateNotNullOrEmpty()]
        [Alias('AccountId', 'Key')]
        [AtlassianPS.JiraPS.User[]]
        $UserName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $selfResourceUri = "$server/rest/api/latest/myself"
        $exactResourceUri = "$server/rest/api/latest/user?{0}={1}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdLet.ParameterSetName) {
            "Self" {
                $resourceURi = $selfResourceUri

                $parameter = @{
                    URI        = $resourceURi
                    Method     = "GET"
                    OutputType = "JiraUser"
                    Credential = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                if ($result = Invoke-JiraMethod @parameter) {
                    $restUrl = $(if (([Uri]$result.RestUrl).Query) { "&" } else { "?" }) + "expand=groups"

                    $parameter["URI"] = "{0}{1}" -f $result.RestUrl, $restUrl
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

                    $parameter = @{
                        URI        = "$exactResourceUri&expand=groups" -f $_user.identify().Key, $_user.identify().Value
                        Method     = "GET"
                        OutputType = "JiraUser"
                        Credential = $Credential
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
