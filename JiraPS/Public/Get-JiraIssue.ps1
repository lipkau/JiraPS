function Get-JiraIssue {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = 'ByIssueKey' )]
    [OutputType( [AtlassianPS.JiraPS.Issue] )]
    param(
        [Parameter( Position = 0, Mandatory, ParameterSetName = 'ByIssueKey' )]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [String[]]
        $Issue,

        [Parameter( Position = 0, Mandatory, ParameterSetName = 'ByInputObject' )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Issue[]]
        $InputObject,

        [Parameter( Mandatory, ParameterSetName = 'ByJQL' )]
        [Alias('JQL')]
        [String]
        $Query,

        [Parameter( Mandatory, ParameterSetName = 'ByFilter' )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Filter]
        $Filter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Fields = '*all',

        [Parameter( ParameterSetName = 'ByJQL' )]
        [Parameter( ParameterSetName = 'ByFilter' )]
        [ValidateRange(1, [UInt32]::MaxValue)]
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

        $searchURi = "$server/rest/api/latest/search"
        $resourceURi = "$server/rest/api/latest/issue/{0}"

        [String]$Fields = $Fields -join ','

        $parameter = @{
            Method       = 'GET'
            GetParameter = @{
                validateQuery = $true
                expand        = 'transitions'
                maxResults    = $PageSize
            }
            OutputType   = 'JiraIssue'
            Credential   = $Credential
            Cmdlet       = $PSCmdlet
        }
        if ($Fields) {
            $parameter['GetParameter']['fields'] = $Fields
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            'ByIssueKey' {
                foreach ($_issue in $Issue) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issue]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issue [$_issue]"

                    $parameter['URI'] = $resourceURi -f $_issue

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            'ByInputObject' {
                # Write-Warning "[$($MyInvocation.MyCommand.Name)] The parameter '-InputObject' has been marked as deprecated."
                foreach ($_issue in $InputObject) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issue]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issue [$_issue]"

                    Get-JiraIssue -Issue $_issue.Key -Fields $Fields -Credential $Credential
                }
            }
            'ByJQL' {
                $parameter['URI'] = $searchURi
                $parameter['GetParameter']['jql'] = (ConvertTo-URLEncoded $Query)
                $parameter['Paging'] = $true

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $parameter[$_] = $PSCmdlet.PagingParameters.$_
                }

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                Invoke-JiraMethod @parameter
            }
            'ByFilter' {
                if (-not $Filter.SearchUrl) {
                    $Filter = Get-JiraFilter -Filter $Filter -Credential $Credential -ErrorAction Stop
                }

                $parameter['URI'] = $Filter.SearchUrl
                $parameter['Paging'] = $true

                # Paging
                ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                    $parameter[$_] = $PSCmdlet.PagingParameters.$_
                }

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
