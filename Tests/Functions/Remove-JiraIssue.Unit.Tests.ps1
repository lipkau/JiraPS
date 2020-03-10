#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Remove-JiraIssue" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        $jiraServer = 'http://jiraserver.example.com'

        $TestIssueJSONs = @{

            # basic issue
            'TEST-1' = @'
            {
                "expand": "renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations",
                "id": "58159",
                "self": "https://jiraserver.example.com/rest/api/2/issue/58159",
                "key": "TEST-1",
                "fields": {
                  "subtasks": [],
                  "project": {
                    "self": "https://jiraserver.example.com/rest/api/2/project/14801",
                    "id": "14801",
                    "key": "TEST",
                    "name": "TEST - Service Desk",
                    "avatarUrls": {
                      "48x48": "https://jiraserver.example.com/secure/projectavatar?avatarId=12003",
                      "24x24": "https://jiraserver.example.com/secure/projectavatar?size=small&avatarId=12003",
                      "16x16": "https://jiraserver.example.com/secure/projectavatar?size=xsmall&avatarId=12003",
                      "32x32": "https://jiraserver.example.com/secure/projectavatar?size=medium&avatarId=12003"
                    }
                  },
                  "aggregatetimespent": null,
                  "resolutiondate": null,
                  "workratio": -1,
                  "description": "Test issue.",
                  "summary": "Test Issue",
                  "comment": {
                    "comments": [],
                    "maxResults": 0,
                    "total": 0,
                    "startAt": 0
                  }
                }
              }
'@
            # issue w/ subtasks
            'TEST-2' = @'
            {
                "expand": "renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations",
                "id": "58160",
                "self": "https://jiraserver.example.com/rest/api/2/issue/58160",
                "key": "TEST-2",
                "fields": {
                  "subtasks": [
                    {
                      "id": "58161",
                      "key": "TEST-3",
                      "self": "https://jiraserver.example.com/rest/api/2/issue/58161",
                      "fields": {
                        "summary": "Test Sub-Task",
                        "status": {
                          "self": "https://jiraserver.example.com/rest/api/2/status/11202",
                          "description": "This was auto-generated by JIRA Service Desk during workflow import",
                          "iconUrl": "https://jiraserver.example.com/images/icons/status_generic.gif",
                          "name": "Open",
                          "id": "11202",
                          "statusCategory": {
                            "self": "https://jiraserver.example.com/rest/api/2/statuscategory/2",
                            "id": 2,
                            "key": "new",
                            "colorName": "blue-gray",
                            "name": "To Do"
                          }
                        },
                        "priority": {
                          "self": "https://jiraserver.example.com/rest/api/2/priority/4",
                          "iconUrl": "https://jiraserver.example.com/images/icons/priorities/minor.svg",
                          "name": "Medium",
                          "id": "4"
                        },
                        "issuetype": {
                          "self": "https://jiraserver.example.com/rest/api/2/issuetype/5",
                          "id": "5",
                          "description": "The sub-task of the issue",
                          "iconUrl": "https://jiraserver.example.com/secure/viewavatar?size=xsmall&avatarId=11016&avatarType=issuetype",
                          "name": "Sub-task",
                          "subtask": true,
                          "avatarId": 11016
                        }
                      }
                    }
                  ],
                  "project": {
                    "self": "https://jiraserver.example.com/rest/api/2/project/14801",
                    "id": "14801",
                    "key": "TEST",
                    "name": "TEST - Service Desk",
                    "avatarUrls": {
                      "48x48": "https://jiraserver.example.com/secure/projectavatar?avatarId=12003",
                      "24x24": "https://jiraserver.example.com/secure/projectavatar?size=small&avatarId=12003",
                      "16x16": "https://jiraserver.example.com/secure/projectavatar?size=xsmall&avatarId=12003",
                      "32x32": "https://jiraserver.example.com/secure/projectavatar?size=medium&avatarId=12003"
                    }
                  },
                  "description": "Test issue with a sub-task attached.",
                  "summary": "Test Parent-Task Issue",
                  "comment": {
                    "comments": [],
                    "maxResults": 0,
                    "total": 0,
                    "startAt": 0
                  }
                }
              }
'@
            # the sub-task itself
            'TEST-3' = @'
            {
                "expand": "renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations",
                "id": "58161",
                "self": "https://jiraserver.example.com/rest/api/2/issue/58161",
                "key": "TEST-3",
                "fields": {
                  "parent": {
                    "id": "58160",
                    "key": "TEST-2",
                    "self": "https://jiraserver.example.com/rest/api/2/issue/58160",
                    "fields": {
                      "summary": "Test Parent-Task Issue",
                      "status": {
                        "self": "https://jiraserver.example.com/rest/api/2/status/1",
                        "description": "The issue is new and has not been looked at yet.",
                        "iconUrl": "https://jiraserver.example.com/images/icons/statuses/open.png",
                        "name": "OPENED",
                        "id": "1",
                        "statusCategory": {
                          "self": "https://jiraserver.example.com/rest/api/2/statuscategory/2",
                          "id": 2,
                          "key": "new",
                          "colorName": "blue-gray",
                          "name": "To Do"
                        }
                      },
                      "priority": {
                        "self": "https://jiraserver.example.com/rest/api/2/priority/4",
                        "iconUrl": "https://jiraserver.example.com/images/icons/priorities/minor.svg",
                        "name": "Medium",
                        "id": "4"
                      },
                      "issuetype": {
                        "self": "https://jiraserver.example.com/rest/api/2/issuetype/3",
                        "id": "3",
                        "description": "A task that needs to be done.",
                        "iconUrl": "https://jiraserver.example.com/secure/viewavatar?size=xsmall&avatarId=11018&avatarType=issuetype",
                        "name": "Task",
                        "subtask": false,
                        "avatarId": 11018
                      }
                    }
                  },
                  "subtasks": [],
                  "project": {
                    "self": "https://jiraserver.example.com/rest/api/2/project/14801",
                    "id": "14801",
                    "key": "TEST",
                    "name": "TEST - Service Desk",
                    "avatarUrls": {
                      "48x48": "https://jiraserver.example.com/secure/projectavatar?avatarId=12003",
                      "24x24": "https://jiraserver.example.com/secure/projectavatar?size=small&avatarId=12003",
                      "16x16": "https://jiraserver.example.com/secure/projectavatar?size=xsmall&avatarId=12003",
                      "32x32": "https://jiraserver.example.com/secure/projectavatar?size=medium&avatarId=12003"
                    }
                  },
                  "description": "Test sub-task.",
                  "summary": "Test Sub-Task",
                  "comment": {
                    "comments": [],
                    "maxResults": 0,
                    "total": 0,
                    "startAt": 0
                  }
                }
              }
'@

        }

        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Get-JiraIssue {
            $obj = $TestIssueJSONs[$Key] | ConvertFrom-Json

            $obj.PSObject.TypeNames.Insert(0, 'JiraPS.Issue')

            $obj | Add-Member -MemberType ScriptMethod -Name ToString -Value {return ""} -Force
            return $obj
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter {$URI -like "$jiraServer/rest/api/*/issue/TEST-1?*" -and $Method -eq "Delete"} {
            return $null
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter {$URI -like "$jiraServer/rest/api/*/issue/TEST-2?deleteSubTasks=False" -and $Method -eq "Delete"} {

            Write-Error -Exception  -ErrorId
            $MockedResponse = @"
            {
                "errorMessages": [
                  "The issue 'TEST-2' has subtasks.  You must specify the 'deleteSubtasks' parameter to delete this issue and all its subtasks."
                ],
                "errors": {}
              }
"@ | ConvertFrom-Json


            $Exception = ([System.ArgumentException]"Server responded with Error")
            $errorId = "ServerResponse"
            $errorCategory = 'NotSpecified'
            $errorTarget = $MockedResponse

            $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $Exception, $errorId, $errorCategory, $errorTarget
            $errorItem.ErrorDetails = "Jira encountered an error: [The issue 'TEST-2' has subtasks.  You must specify the 'deleteSubtasks' parameter to delete this issue and all its subtasks.]"

            $PSCmdlet.WriteError($errorItem)
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter {$URI -like "$jiraServer/rest/api/*/issue/TEST-2?deleteSubTasks=True" -and $Method -eq "Delete"} {
            return $null
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        Context "Sanity checking" {
            $command = Get-Command -Name Remove-JiraIssue

            defParam $command 'IssueId'
            defParam $command 'InputObject'
            defParam $command 'IncludeSubTasks'
            defParam $command 'Credential'
        }

        Context "Functionality" {

            It "Accepts generic object with the correct properties" {
                {
                    $issue = Get-JiraIssue -Key TEST-1
                    Remove-JiraIssue -Issue $issue -Force
                } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
            }

            It "Accepts string-based input as a non-pipelined parameter" {
                {Remove-JiraIssue -IssueId TEST-1 -Force} | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
            }

            It "Accepts a JiraPS.Issue object over the pipeline" {
                { Get-JiraIssue -Key TEST-1 | Remove-JiraIssue -Force} | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
            }

            It "Writes an error on issues with subtasks" {
                # Pester is not capable of (easily) asserting non-terminating errors,
                # so the error is upgraded to a terminating one in this situation.
                { Get-JiraIssue -Key TEST-2 | Remove-JiraIssue -Force -ErrorAction Stop} | Should Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
            }

            It "Passes on issues with subtasks and -DeleteSubTasks" {
                { Get-JiraIssue -Key TEST-2 | Remove-JiraIssue -IncludeSubTasks -Force} | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
            }

            It "Validates pipeline input" {
                { @{id = 1} | Remove-JiraIssue -ErrorAction Stop} | Should Throw
            }
        }
    }
}
