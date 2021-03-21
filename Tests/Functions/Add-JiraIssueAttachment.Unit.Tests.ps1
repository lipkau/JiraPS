#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Add-JiraIssueAttachment' -Tag 'Unit' {
    BeforeAll {
        $fileName = 'MyFile.txt'
        $filePath = "TestDrive:\$fileName"
        Set-Content $filePath -Value 'my test text.'

        $attachmentResponse = @{
            'RestURL'  = 'http://jiraserver.example.com/rest/api/2/attachment/10010'
            'id'       = '10010'
            'filename' = 'image.png'
            'author'   = [AtlassianPS.JiraPS.User]@{
                'RestURL'      = 'http://jiraserver.example.com/rest/api/2/user?username=admin'
                'name'         = 'admin'
                'key'          = 'admin'
                'accountId'    = '0000:000000-0000-0000-0000-ab899c878d00'
                'emailAddress' = 'admin@example.com'
                'displayName'  = 'Admin'
                'active'       = $true
                'timeZone'     = 'Europe/Berlin'
            }
            'created'  = '2017-10-16T09:06:48.070+0200'
            'size'     = 438098
            'mimeType' = "'applation/pdf'"
            'content'  = 'http://jiraserver.example.com/secure/attachment/10010/image.png'
        }

        #region Mock
        Add-CommonMocks

        Add-MockGetJiraIssue

        Mock Resolve-FilePath -ModuleName 'JiraPS' { $Path }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $Uri -like "*/issue/*/attachments*"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            [AtlassianPS.JiraPS.Attachment]$attachmentResponse
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            Set-Content -Path TestDrive:\access.log -Value 'some content'
            Set-Content -Path TestDrive:\error.log -Value 'some content'

            $files = Get-ChildItem TestDrive:\*.log
        }

        It 'attaches files to a ticket' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
                ParameterFilter = { $RawBody -eq $true }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            Set-Content -Path TestDrive:\access.log -Value 'some content'
            Set-Content -Path TestDrive:\error.log -Value 'some content'

            $files = Get-ChildItem TestDrive:\*.log

            $issue = $mockedJiraIssue
        }

        It 'fetches the Issue if an incomplete object was provided' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName 'JiraPS' -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Issue when a complete object was provided' {
            Add-JiraIssueAttachment -Issue $issue -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName 'JiraPS' -Exactly -Times 0 -Scope It
        }

        It "files when the file doesn't exist" {
            { Add-JiraIssueAttachment -Issue $issue -FilePath 'non-existing.file' -ErrorAction Stop } | Should -Throw -Because 'ArgumentException: File not found'
        }

        It 'returns an object when specified' {
            $result = Add-JiraIssueAttachment -Issue $issue -FilePath $files -PassThru -ErrorAction Stop

            $result | Should -Not -BeNullOrEmpty
        }

        It 'accepts multiple Users' {
            Add-JiraIssueAttachment -Issue $issue -FilePath $files -PassThru -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 2
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'accepts files over the pipeline' {
            $files | Add-JiraIssueAttachment -Issue $issue -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' {
        BeforeAll {
            Set-Content -Path TestDrive:\access.log -Value 'some content'

            $files = Get-ChildItem TestDrive:\access.log

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'uses the multipart form-data boundary correctly' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match "(?sm)^--([a-f0-9-]{36}).*--\1--$" -and
                $Headers['Content-Type'] -like ("*boundary=`"{0}`"" -f $matches[1])
            }
        }

        It 'deactivates atlassian xsrf check' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Headers['X-Atlassian-Token'] -eq 'nocheck'
            }
        }

        It 'uses octet-stream for the form upload' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Headers['Content-Type'] -like "multipart/form-data*" -and
                $Body -like "*Content-Type: application/octet-stream*"
            }
        }

        It 'sets the filename in the form upload' {
            Add-JiraIssueAttachment -Issue 'TEST-001' -FilePath $files.FullName -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -like "*Content-Disposition: form-data; name=`"file`"; filename=`"access.log`"*"
            }
        }
    }
}
