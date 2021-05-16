function Find-JiraUser {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.User] )]
    param(
        [Parameter( Mandatory, ParameterSetName = "ByEmailAddress" )]
        [AllowEmptyString()]
        [String]
        $EmailAddress,

        [Parameter( Mandatory, ParameterSetName = "ByUserName" )]
        [AllowEmptyString()]
        [String]
        $UserName,

        [Parameter()]
        [Switch]
        $IncludeInactive,

        [Parameter()]
        [ValidateRange(0, [UInt64]::MaxValue)]
        [UInt64]
        $Skip,

        [Parameter()]
        [ValidateRange(1, 1000)]
        [UInt32]
        $PageSize = $script:DefaultPageSize,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/user/search"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $getParameter = @{
            expand          = "groups"
            maxResults      = $PageSize
            includeInactive = $IncludeInactive
        }

        if ($Skip) {
            $getParameter["startAt"] = $Skip
        }

        switch ($PsCmdLet.ParameterSetName) {
            "ByEmailAddress" {
                $getParameter["query"] = $EmailAddress
            }
            "ByUserName" {
                $getParameter["username"] = $UserName
            }
        }

        <# $writeErrorSplat = @{
            Exception = "Missing parameters for search"
            ErrorId   = "InvalidArgument.User.MissingSearchProperty"
            Category  = "InvalidArgument"
            Message   = "Unable to determine by which field to search for"
        }
        ThrowError @writeErrorSplat #>

        $parameter = @{
            URI          = $resourceURi
            Method       = "GET"
            GetParameter = $getParameter
            OutputType   = "JiraUser"
            Credential   = $Credential
            Cmdlet       = $Cmdlet
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        Invoke-JiraMethod @parameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
