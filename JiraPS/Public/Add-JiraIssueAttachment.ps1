function Add-JiraIssueAttachment {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [AtlassianPS.JiraPS.Attachment] )]
    param(
        [Parameter( Mandatory )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateScript(
            {
                if (-not (Test-Path $_ -PathType Leaf)) {
                    $exception = ([System.ArgumentException]'File not found')
                    $errorId = 'ParameterValue.FileNotFound'
                    $errorCategory = 'ObjectNotFound'
                    $errorTarget = $_
                    $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
                    $errorItem.ErrorDetails = "No file could be found with the provided path '$_'."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                }
                else {
                    return $true
                }
            }
        )]
        [Alias('InFile', 'FullName', 'Path')]
        [String[]]
        $FilePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Switch]
        $PassThru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $IssueUrl = Resolve-JiraIssueUrl -Issue $Issue
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($file in $FilePath) {
            $file = Resolve-FilePath -Path $file

            $enc = [System.Text.Encoding]::GetEncoding('iso-8859-1')
            $boundary = [System.Guid]::NewGuid().ToString()

            $headers = @{
                'Content-Type'      = "multipart/form-data; boundary=`"$boundary`""
                'X-Atlassian-Token' = 'nocheck'
            }

            $fileName = Split-Path -Path $file -Leaf
            $readFile = [System.IO.File]::ReadAllBytes($file)
            $fileEnc = $enc.GetString($readFile)

            $bodyLines = @'
--{0}
Content-Disposition: form-data; name="file"; filename="{1}"
Content-Type: application/octet-stream

{2}
--{0}--
'@ -f $boundary, $fileName, $fileEnc

            $parameter = @{
                URI        = "$IssueUrl/attachments"
                Method     = 'POST'
                Body       = $bodyLines
                Headers    = $headers
                RawBody    = $true
                OutputType = 'JiraAttachment'
                Credential = $Credential
                Cmdlet     = $PSCmdlet
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Issue.ToString(), "Adding attachment '$fileName'.")) {
                $result = Invoke-JiraMethod @parameter

                if ($PassThru) { $result }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
