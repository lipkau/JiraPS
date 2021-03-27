function Get-JiraIssueType {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    [OutputType( [AtlassianPS.JiraPS.IssueType] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_ById' )]
        [AtlassianPS.JiraPS.IssueType[]]
        $IssueType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issuetype"

        $parameter = @{
            Uri        = $resourceURi
            Method     = "GET"
            OutputType = "JiraIssueType"
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_All' {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                Invoke-JiraMethod @parameter
            }
            '_ById' {
                foreach ($_issueType in $IssueType) {
                    if (-not $_issueType.Id) {
                        $writeErrorSplat = @{
                            Exception    = "Missing property for identification"
                            ErrorId      = "InvalidData.IssueType.MissingIdentificationProperty"
                            Category     = "InvalidData"
                            Message      = "IssueType needs to be identifiable by Id. Id was missing."
                            TargetObject = $_issueType
                        }
                        WriteError @writeErrorSplat
                        return
                    }

                    $parameter['Uri'] += "/" + $_issueType.Id

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
