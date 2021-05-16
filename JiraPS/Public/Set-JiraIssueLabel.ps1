function Set-JiraIssueLabel {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'ReplaceLabels' )]
    [OutputType( [AtlassianPS.JiraPS.Issue] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue[]]
        $Issue,

        [Parameter( Mandatory, ParameterSetName = 'ReplaceLabels' )]
        [Alias('Label', 'Replace')]
        [String[]]
        $Set,

        [Parameter( ParameterSetName = 'ModifyLabels' )]
        [String[]]
        $Add,

        [Parameter( ParameterSetName = 'ModifyLabels' )]
        [String[]]
        $Remove,

        [Parameter( Mandatory, ParameterSetName = 'ClearLabels' )]
        [Switch]
        $Clear,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter()]
        [Switch]
        $PassThru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_issue in $Issue) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issue]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issue [$_issue]"

            if (-not $_issue.RestURL) {
                $_issue = Get-JiraIssue -Issue $_issue.Key -Credential $Credential -ErrorAction Stop
            }

            $labels = [System.Collections.ArrayList]@($_issue.labels | Where-Object { $_ })

            switch ($PSCmdlet.ParameterSetName) {
                'ClearLabels' {
                    Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Clearing all labels"
                    $labels = [System.Collections.ArrayList]@()
                }
                'ReplaceLabels' {
                    Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Replacing existing labels"
                    $labels = [System.Collections.ArrayList]$Set
                }
                'ModifyLabels' {
                    if ($Add) {
                        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Adding labels"
                        $null = foreach ($_add in $Add) { $labels.Add($_add) }
                    }
                    if ($Remove) {
                        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Removing labels"
                        foreach ($item in $Remove) {
                            $labels.Remove($item)
                        }
                    }
                }
            }

            $requestBody = @{
                'update' = @{
                    'labels' = @(
                        @{ 'set' = @($labels) }
                    )
                }
            }

            $parameter = @{
                URI        = $_issue.RestURL
                Method     = "PUT"
                Body       = ConvertTo-Json -InputObject $requestBody -Depth 6
                Credential = $Credential
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($_issue.Key, "Updating Issue labels")) {
                $null = Invoke-JiraMethod @parameter

                if ($PassThru) {
                    Get-JiraIssue -Issue $_issue.Key -Credential $Credential
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
