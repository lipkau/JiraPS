function Find-JiraIssueType {
    # .ExternalHelp ..\JiraPS-help.xml
    [OutputType( )]
    [OutputType( [AtlassianPS.JiraPS.IssueType] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [String[]]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $allIssueTypes = Get-JiraFilter -Credential $Credential -ErrorAction Stop
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_name in $Name) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_name]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_name [$_name]"

            $allIssueTypes | Where-Object -FilterScript { $_.Name -like $_name }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
