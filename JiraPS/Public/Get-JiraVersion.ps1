function Get-JiraVersion {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsPaging, DefaultParameterSetName = 'byVersion' )]
    [OutputType( [AtlassianPS.JiraPS.Version] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'byVersion' )]
        [Alias('Id')]
        [AtlassianPS.JiraPS.Version]
        $Version,

        [Parameter( Mandatory , ValueFromPipeline, ParameterSetName = 'byProject' )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Project[]]
        $Project,

        [Parameter( ParameterSetName = 'byProject' )]
        [String[]]
        $Name = "*",

        [Parameter( ParameterSetName = 'byProject' )]
        [ValidateSet(
            "sequence",
            "name",
            "startDate",
            "releaseDate"
        )]
        [String]
        $Sort = "name",

        [Parameter()]
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

        $resourceURi = "$server/rest/api/latest/{0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PsCmdlet.ParameterSetName) {
            "byId" {
                foreach ($_version in $Version) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_version]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_version [$_version]"

                    if (-not $_version) {
                        $writeErrorSplat = @{
                            Exception    = "Missing property for identification"
                            ErrorId      = "InvalidData.Version.MissingIdentificationProperty"
                            Category     = "InvalidData"
                            Message      = "Version needs to be identifiable by Id. Id was missing."
                            TargetObject = $_version
                        }
                        WriteError @writeErrorSplat
                        return
                    }

                    $parameter = @{
                        URI        = $resourceURi -f "version/$($_version.id)"
                        Method     = "GET"
                        OutputType = "JiraVersion"
                        Credential = $Credential
                    }
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            "byProject" {
                foreach ($_project in $Project) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_project]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_project [$_project]"

                    if (-not $_project) {
                        $writeErrorSplat = @{
                            Exception    = "Missing property for identification"
                            ErrorId      = "InvalidData.Project.MissingIdentificationProperty"
                            Category     = "InvalidData"
                            Message      = "Project needs to be identifiable by Key. Key was missing."
                            TargetObject = $_project
                        }
                        WriteError @writeErrorSplat
                        return
                    }

                    $parameter = @{
                        URI          = $resourceURi -f "project/$($_project.key)/version"
                        Method       = "GET"
                        GetParameter = @{
                            orderBy    = $Sort
                            maxResults = $PageSize
                        }
                        Paging       = $true
                        OutputType   = "JiraVersion"
                        Credential   = $Credential
                    }
                    # Paging
                    ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
                        $parameter[$_] = $PSCmdlet.PagingParameters.$_
                    }

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    if ($result = Invoke-JiraMethod @parameter) {
                        $result | Where-Object {
                            $__ = $_.Name
                            Write-DebugMessage ($__ | Out-String)
                            $Name | Foreach-Object {
                                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Matching $_ against $($__)"
                                $__ -like $_
                            }
                        }
                    }
                }
            }
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
