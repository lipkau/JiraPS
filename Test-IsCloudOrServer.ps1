function Test-IsCloudOrServer {
    param(
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    function Test-HeadMatch {
        param(
            [Hashtable] $HeaderItem,
            [Hashtable] $TargetHeaderList
        )

        if ($HeaderItem.key -notin $TargetHeaderList.Keys) {
            return $false
        }

        foreach ($key in $TargetHeaderList.Keys) {
            if (-not $TargetHeaderList[$key]) {
                return $true
            }
            if ($TargetHeaderList[$key] -and ($HeaderItem.value -like $TargetHeaderList[$key])) {
                return $true
            }
        }
        return $false
    }

    $cloudHeaders = @{ "Server" = "AtlassianProxy"; "ATL-TraceId" = $null; "Expect-CT" = "web-security-reports.services.atlassian.com" }
    $serverHeaders = @{ "X-ASEN" = $null; "X-AUSERNAME" = $null }

    if (-not (Get-JiraConfigServer)) {
        throw "not server defined yet."
    }
    $parameters = @{
        Method = 'Get'
        Uri    = "{0}/rest/api/latest/myself" -f (Get-JiraConfigServer)
    }

    if ($Credential -and ($Credential -ne [System.Management.Automation.PSCredential]::Empty)) {
        $SecureCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(
                $('{0}:{1}' -f $Credential.UserName, $Credential.GetNetworkCredential().Password)
            ))
        $parameters['Headers'] = @{ Authorization = "Basic $($SecureCreds)" }
    }
    elseif ($session = Get-JiraSession) {
        $parameters['WebSession'] = $session.WebSession
    }
    else {
        throw "Could not find credentials."
    }

    $headers = (Invoke-WebRequest @parameters).Headers
    foreach ($header in $headers.Keys) {
        $header = @{ key = $header; value = $headers[$header] }
        if (Test-HeadMatch -HeaderItem $header -TargetHeaderList $cloudHeaders) {
            return "you are using a jira in: CLOUD"
        }
        if (Test-HeadMatch -HeaderItem $header -TargetHeaderList $serverHeaders) {
            return "you are using a jira in: ON-PREMISE"
        }
    }
    return "you are using a jira in: I HAVE NO CLUE"
}
