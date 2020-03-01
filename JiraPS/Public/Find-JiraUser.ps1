function Find-JiraUser {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType([AtlassianPS.JiraPS.User])]
    param(
        [Parameter( Mandatory, ParameterSetName = "ByEmailAddress" )]
        [AllowEmptyString()]
        [String]
        $EmailAddress,

        [Parameter( Mandatory, ParameterSetName = "ByUserName" )]
        [AllowEmptyString()]
        [String]
        $UserName,

        [Switch]
        $IncludeInactive,

        [ValidateRange(1, [int]::MaxValue)]
        [UInt32]$PageSize = 50,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/user/search?{0}={1}&expand=groups"

        if ($IncludeInactive) {
            $resourceURi += "&includeInactive=true"
        }
        if ($PageSize) {
            $resourceURi += "&maxResults=$PageSize"
        }
        if ($Skip) {
            $resourceURi += "&startAt=$Skip"
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdLet.ParameterSetName) {
            "ByEmailAddress" {
                $fieldMapping = @{ key = "query"; value = $EmailAddress }
            }
            "ByUserName" {
                $fieldMapping = @{ key = "username"; value = $UserName }
            }
        }

        if (-not $fieldMapping) {
            $writeErrorSplat = @{
                Exception = "Missing parameters for search"
                ErrorId   = "InvalidArgument.User.MissingSearchProperty"
                Category  = "InvalidArgument"
                Message   = "Unable to determine by which field to search for"
            }
            ThrowError @writeErrorSplat
        }

        $parameter = @{
            URI        = $resourceURi -f $fieldMapping["key"], $fieldMapping["value"]
            Method     = "GET"
            OutputType = "JiraUser"
            Credential = $Credential
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        Invoke-JiraMethod @parameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
