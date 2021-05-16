function New-JiraIssue {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = "byIssue" )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = "byIssue" )]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter( Mandatory, ParameterSetName = "byProperties" )]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter( Mandatory, ParameterSetName = "byProperties" )]
        [Alias("IssueType")]
        [Atlassian.JiraPS.Type]
        $Type,

        [Parameter( Mandatory, ParameterSetName = "byProperties" )]
        [String]
        $Summary,

        [Parameter( ParameterSetName = "byProperties" )]
        [Int]
        $Priority,

        [Parameter( ParameterSetName = "byProperties" )]
        [String]
        $Description,

        [Parameter( ParameterSetName = "byProperties" )]
        [AllowNull()]
        [AllowEmptyString()]
        [AtlassianPS.JiraPS.User]
        $Reporter,

        [Parameter( ParameterSetName = "byProperties" )]
        [String[]]
        $Labels,

        [Parameter( ParameterSetName = "byProperties" )]
        [String]
        $Parent,

        [Parameter( ParameterSetName = "byProperties" )]
        [Alias('FixVersions')]
        [String[]]
        $FixVersion,

        [Parameter( ParameterSetName = "byProperties" )]
        [PSCustomObject]
        $Fields,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issue"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $createmeta = Get-JiraIssueCreateMetadata -Project $Project -IssueType $IssueType -Credential $Credential -ErrorAction Stop -Debug:$false
        $ProjectObj = Get-JiraProject -Project $Project -Credential $Credential -ErrorAction Stop -Debug:$false
        $issueTypeObj = $projectObj.IssueTypes | Where-Object -FilterScript { $_.Id -eq $IssueType -or $_.Name -eq $IssueType }

        if ($null -eq $issueTypeObj.Id) {
            $errorMessage = @{
                Category         = "InvalidResult"
                CategoryActivity = "Validating parameters"
                Message          = "No issue types were found in the project [$Project] for the given issue type [$IssueType]. Use Get-JiraIssueType for more details."
            }
            Write-Error @errorMessage
        }

        $requestBody = @{
            "project"   = @{ "id" = $ProjectObj.Id }
            "issuetype" = @{ "id" = [String] $IssueTypeObj.Id }
            "summary"   = $Summary
        }

        if ($Priority) {
            $requestBody["priority"] = @{ "id" = [String] $Priority }
        }

        if ($Description) {
            $requestBody["description"] = $Description
        }

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Reporter")) {
            $requestBody["reporter"] = @{ id = $Reporter.identify()["value"] }
        }

        if ($Parent) {
            $requestBody["parent"] = @{"key" = $Parent }
        }

        if ($Labels) {
            $requestBody["labels"] = [System.Collections.ArrayList]@()
            foreach ($item in $Labels) {
                $null = $requestBody["labels"].Add($item)
            }
        }

        if ($FixVersion) {
            $requestBody['fixVersions'] = [System.Collections.ArrayList]@()
            foreach ($item in $FixVersion) {
                $null = $requestBody["fixVersions"].Add( @{ name = "$item" } )
            }
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Resolving `$Fields"
        foreach ($_key in $Fields.Keys) {
            $name = $_key
            $value = $Fields.$_key

            if ($field = Get-JiraField -Field $name -Credential $Credential -Debug:$false) {
                # For some reason, this was coming through as a hashtable instead of a String,
                # which was causing ConvertTo-Json to crash later.
                # Not sure why, but this forces $id to be a String and not a hashtable.
                $id = $field.Id
                $requestBody["$id"] = $value
            }
            else {
                $exception = ([System.ArgumentException]"Invalid value for Parameter")
                $errorId = 'ParameterValue.InvalidFields'
                $errorCategory = 'InvalidArgument'
                $errorTarget = $Fields
                $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
                $errorItem.ErrorDetails = "Unable to identify field [$name] from -Fields hashtable. Use Get-JiraField for more information."
                $PSCmdlet.ThrowTerminatingError($errorItem)
            }
        }

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Validating fields with metadata"
        foreach ($c in $createmeta) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Checking metadata for `$c [$c]"
            if ($c.Required) {
                if ($requestBody.ContainsKey($c.Id)) {
                    Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Required field (id=[$($c.Id)], name=[$($c.Name)]) was provided (value=[$($requestBody.$($c.Id))])"
                }
                else {
                    $exception = ([System.ArgumentException]"Invalid or missing value Parameter")
                    $errorId = 'ParameterValue.CreateMetaFailure'
                    $errorCategory = 'InvalidArgument'
                    $errorTarget = $Fields
                    $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
                    $errorItem.ErrorDetails = "Jira's metadata for project [$Project] and issue type [$IssueType] specifies that a field is required that was not provided (name=[$($c.Name)], id=[$($c.Id)]). Use Get-JiraIssueCreateMetadata for more information."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
            }
            else {
                Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Non-required field (id=[$($c.Id)], name=[$($c.Name)])"
            }
        }

        $hashtable = @{
            'fields' = ([PSCustomObject]$requestBody)
        }

        $parameter = @{
            URI        = $resourceURi
            Method     = "POST"
            Body       = (ConvertTo-Json -InputObject ([PSCustomObject]$hashtable) -Depth 7)
            Credential = $Credential
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        if ($PSCmdlet.ShouldProcess($Summary, "Creating new Issue on JIRA")) {
            if ($result = Invoke-JiraMethod @parameter) {
                # REST result will look something like this:
                # {"id":"12345","key":"IT-3676","self":"http://jiraserver.example.com/rest/api/latest/issue/12345"}
                # This will fetch the created issue to return it with all it'a properties
                Get-JiraIssue -Issue $result.Key -Credential $Credential
            }
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }

    end {
    }
}
