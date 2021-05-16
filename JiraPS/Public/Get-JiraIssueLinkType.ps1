function Get-JiraIssueLinkType {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    param(
        [Parameter( Position = 0, Mandatory, ParameterSetName = '_Search' )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.IssueLinkType]
        $LinkType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issueLinkType{0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_All' {
                $parameter = @{
                    URI        = $resourceURi -f ""
                    Method     = "GET"
                    Credential = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                $result = Invoke-JiraMethod @parameter

                Write-Output (ConvertTo-JiraIssueLinkType -InputObject $result.issueLinkTypes)
            }
            '_Search' {
                # If the link type provided is an int, we can assume it's an ID number.
                # If it's a String, it's probably a name, though, and there isn't an API call to look up a link type by name.
                if ($LinkType -is [Int]) {
                    $parameter = @{
                        URI        = $resourceURi -f "/$LinkType"
                        Method     = "GET"
                        Credential = $Credential
                    }
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    $result = Invoke-JiraMethod @parameter

                    Write-Output (ConvertTo-JiraIssueLinkType -InputObject $result)
                }
                else {
                    Write-Output (Get-JiraIssueLinkType -Credential $Credential | Where-Object { $_.Name -like $LinkType })
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
