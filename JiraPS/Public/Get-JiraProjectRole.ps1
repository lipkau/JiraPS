function Get-JiraProjectRole {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_All' )]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('JiraPS.Project')]
        $Project,

        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Search' )]
        [UInt32[]]
        $ProjectId,

        [Parameter()]
        [UInt32[]]
        $RoleId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $resourceURi = "{0}/role{1}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($ProjectId) {
            $Project = Get-JiraProject $ProjectId -ErrorAction Stop
        }

        foreach ($_project in $Project) {
            if ($RoleId) {
                foreach ($_roleId in $RoleId) {
                    $_role = "/$_roleId"
                    $parameter = @{
                        URI        = $resourceURi -f $_project.RestURL, $_role
                        Method     = "GET"
                        Credential = $Credential
                    }
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    $result = Invoke-JiraMethod @parameter

                    Write-Output (ConvertTo-JiraProjectRole $result)
                }
            }
            else {
                $parameter = @{
                    URI        = $resourceURi -f $_project.RestURL, $_role
                    Method     = "GET"
                    Credential = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                $result = Invoke-JiraMethod @parameter

                ($result | Get-Member -MemberType NoteProperty -ErrorAction Ignore).Name | Foreach-Object {
                    $name = $_
                    if ($result.$name -match "\/project\/(?<projectid>\d+)\/role\/(?<id>\d+)") {
                        Write-Output (ConvertTo-JiraProjectRole @{
                                name      = $name
                                self      = $result.$name
                                id        = $matches["id"]
                                projectId = $matches["projectid"]
                            }
                        )
                    }
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
