#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraIssue" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "expand": "renderedFields,names,schema,transitions,operations,editmeta,changelog,versionedRepresentations",
    "id": "10013",
    "self": "https://powershell.atlassian.net/rest/api/latest/issue/10013",
    "key": "TV-14",
    "transitions": [
        {
            "id": "11",
            "name": "To Do",
            "to": {
                "self": "https://powershell.atlassian.net/rest/api/2/status/10000",
                "description": "",
                "iconUrl": "https://powershell.atlassian.net/",
                "name": "To Do",
                "id": "10000",
                "statusCategory": {
                    "self": "https://powershell.atlassian.net/rest/api/2/statuscategory/2",
                    "id": 2,
                    "key": "new",
                    "colorName": "blue-gray",
                    "name": "To Do"
                }
            },
            "hasScreen": false,
            "isGlobal": true,
            "isInitial": false,
            "isAvailable": true,
            "isConditional": false,
            "isLooped": false
        },
        {
            "id": "21",
            "name": "In Progress",
            "to": {
                "self": "https://powershell.atlassian.net/rest/api/2/status/3",
                "description": "This issue is being actively worked on at the moment by the assignee.",
                "iconUrl": "https://powershell.atlassian.net/images/icons/statuses/inprogress.png",
                "name": "In Progress",
                "id": "3",
                "statusCategory": {
                    "self": "https://powershell.atlassian.net/rest/api/2/statuscategory/4",
                    "id": 4,
                    "key": "indeterminate",
                    "colorName": "yellow",
                    "name": "In Progress"
                }
            },
            "hasScreen": false,
            "isGlobal": true,
            "isInitial": false,
            "isAvailable": true,
            "isConditional": false,
            "isLooped": false
        },
        {
            "id": "31",
            "name": "Done",
            "to": {
                "self": "https://powershell.atlassian.net/rest/api/2/status/10001",
                "description": "",
                "iconUrl": "https://powershell.atlassian.net/",
                "name": "Done",
                "id": "10001",
                "statusCategory": {
                    "self": "https://powershell.atlassian.net/rest/api/2/statuscategory/3",
                    "id": 3,
                    "key": "done",
                    "colorName": "green",
                    "name": "Done"
                }
            },
            "hasScreen": false,
            "isGlobal": true,
            "isInitial": false,
            "isAvailable": true,
            "isConditional": false,
            "isLooped": false
        }
    ],
    "fields": {
        "statuscategorychangedate": "2021-03-20T22:30:28.481+0100",
        "issuetype": {
            "self": "https://powershell.atlassian.net/rest/api/2/issuetype/10100",
            "id": "10100",
            "description": "A user story. Created by JIRA Software - do not edit or delete.",
            "iconUrl": "https://powershell.atlassian.net/images/icons/issuetypes/story.svg",
            "name": "Story",
            "subtask": false
        },
        "timespent": 86400,
        "project": {
            "self": "https://powershell.atlassian.net/rest/api/2/project/10000",
            "id": "10000",
            "key": "TV",
            "name": "T Virus Project",
            "projectTypeKey": "software",
            "simplified": false,
            "avatarUrls": {
                "48x48": "https://powershell.atlassian.net/secure/projectavatar?avatarId=10324",
                "24x24": "https://powershell.atlassian.net/secure/projectavatar?size=small&s=small&avatarId=10324",
                "16x16": "https://powershell.atlassian.net/secure/projectavatar?size=xsmall&s=xsmall&avatarId=10324",
                "32x32": "https://powershell.atlassian.net/secure/projectavatar?size=medium&s=medium&avatarId=10324"
            }
        },
        "fixVersions": [
            {
                "self": "https://powershell.atlassian.net/rest/api/2/version/12308",
                "id": "12308",
                "name": "v1",
                "archived": false,
                "released": true,
                "releaseDate": "2019-05-13"
            },
            {
                "self": "https://powershell.atlassian.net/rest/api/2/version/12309",
                "id": "12309",
                "name": "v2",
                "archived": true,
                "released": false
            }
        ],
        "aggregatetimespent": 86400,
        "resolution": {
            "self": "https://powershell.atlassian.net/rest/api/2/resolution/10000",
            "id": "10000",
            "description": "Work has been completed on this issue.",
            "name": "Done"
        },
        "customfield_10107": [
            {
                "id": 1,
                "name": "Sample Sprint 2",
                "state": "active",
                "boardId": 1,
                "startDate": "2017-06-16T21:35:23.762Z",
                "endDate": "2017-06-30T21:55:23.762Z"
            }
        ],
        "customfield_10503": null,
        "customfield_10108": "0|i0002v:",
        "resolutiondate": "2021-03-20T22:30:28.473+0100",
        "workratio": 60,
        "customfield_10509": null,
        "issuerestriction": {
            "issuerestrictions": {},
            "shouldDisplay": false
        },
        "watches": {
            "self": "https://powershell.atlassian.net/rest/api/2/issue/TV-14/watchers",
            "watchCount": 0,
            "isWatching": false
        },
        "lastViewed": "2021-03-20T22:33:17.482+0100",
        "created": "2017-06-23T04:35:22.149+0200",
        "priority": {
            "self": "https://powershell.atlassian.net/rest/api/2/priority/3",
            "iconUrl": "https://powershell.atlassian.net/images/icons/priorities/medium.svg",
            "name": "Medium",
            "id": "3"
        },
        "customfield_10101": "3_*:*_1_*:*_69659979957_*|*_10000_*:*_1_*:*_48430526434_*|*_10001_*:*_1_*:*_0",
        "customfield_10103": [],
        "labels": [
            "bar",
            "baz",
            "foo"
        ],
        "timeestimate": 28800,
        "aggregatetimeoriginalestimate": 144000,
        "versions": [
            {
                "self": "https://powershell.atlassian.net/rest/api/2/version/12308",
                "id": "12308",
                "name": "v1",
                "archived": false,
                "released": true,
                "releaseDate": "2019-05-13"
            }
        ],
        "issuelinks": [
            {
                "id": "10103",
                "self": "https://powershell.atlassian.net/rest/api/2/issueLink/10103",
                "type": {
                    "id": "10000",
                    "name": "Blocks",
                    "inward": "is blocked by",
                    "outward": "blocks",
                    "self": "https://powershell.atlassian.net/rest/api/2/issueLinkType/10000"
                },
                "outwardIssue": {
                    "id": "10009",
                    "key": "TV-10",
                    "self": "https://powershell.atlassian.net/rest/api/2/issue/10009",
                    "fields": {
                        "summary": "As a developer, I can update story and task status with drag and drop (click the triangle at far left of this story to show sub-tasks)"
                    }
                }
            }
        ],
        "assignee": null,
        "updated": "2021-03-20T22:33:17.307+0100",
        "status": {
            "self": "https://powershell.atlassian.net/rest/api/2/status/10001",
            "description": "",
            "iconUrl": "https://powershell.atlassian.net/",
            "name": "Done",
            "id": "10001",
            "statusCategory": {
                "self": "https://powershell.atlassian.net/rest/api/2/statuscategory/3",
                "id": 3,
                "key": "done",
                "colorName": "green",
                "name": "Done"
            }
        },
        "components": [
            {
                "self": "https://powershell.atlassian.net/rest/api/2/component/10100",
                "id": "10100",
                "name": "server 1"
            }
        ],
        "timeoriginalestimate": 144000,
        "description": "*Creating Quick Filters*\n\nYou can add your own Quick Filters in the board configuration (select *Board > Configure*)",
        "timetracking": {
            "originalEstimate": "1w",
            "remainingEstimate": "1d",
            "timeSpent": "3d",
            "originalEstimateSeconds": 144000,
            "remainingEstimateSeconds": 28800,
            "timeSpentSeconds": 86400
        },
        "customfield_10600": [
            {
                "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                "emailAddress": "oliver@lipkau.net",
            }
        ],
        "customfield_10007": {
            "hasEpicLinkFieldDependency": false,
            "showField": false,
            "nonEditableReason": {
                "reason": "PLUGIN_LICENSE_ERROR",
                "message": "The Parent Link is only available to Jira Premium users."
            }
        },
        "security": null,
        "attachment": [
            {
                "self": "https://powershell.atlassian.net/rest/api/2/Issue/10033",
                "id": "10033",
                "filename": ".editorconfig",
                "author": {
                    "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                    "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                    "emailAddress": "oliver@lipkau.net",
                },
                "created": "2021-03-14T03:51:09.599+0100",
                "size": 202,
                "mimeType": "application/octet-stream",
                "content": "https://powershell.atlassian.net/secure/Issue/10033/.editorconfig"
            },
            {
                "self": "https://powershell.atlassian.net/rest/api/2/Issue/10032",
                "id": "10032",
                "filename": ".editorconfig",
                "author": {
                    "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                    "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                    "emailAddress": "oliver@lipkau.net",
                },
                "created": "2021-03-14T03:22:43.570+0100",
                "size": 202,
                "mimeType": "application/octet-stream",
                "content": "https://powershell.atlassian.net/secure/Issue/10032/.editorconfig"
            }
        ],
        "aggregatetimeestimate": 28800,
        "summary": "As a user, I can find important items on the board by using the customisable \"Quick Filters\" above >> Try clicking the \"Only My Issues\" Quick Filter above",
        "creator": {
            "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
            "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
            "emailAddress": "oliver@lipkau.net",
        },
        "subtasks": [],
        "reporter": {
            "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
            "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
            "emailAddress": "oliver@lipkau.net",
        },
        "customfield_10000": "{}",
        "aggregateprogress": {
            "progress": 86400,
            "total": 115200,
            "percent": 75
        },
        "customfield_10200": 3.0,
        "environment": null,
        "duedate": null,
        "progress": {
            "progress": 86400,
            "total": 115200,
            "percent": 75
        },
        "comment": {
            "comments": [
                {
                    "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/comment/10005",
                    "id": "10005",
                    "author": {
                        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "emailAddress": "oliver@lipkau.net",
                    },
                    "body": "Joined Sample Sprint 2 1 days 4 hours 10 minutes ago",
                    "updateAuthor": {
                        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "emailAddress": "oliver@lipkau.net",
                    },
                    "created": "2017-06-23T04:35:22.145+0200",
                    "updated": "2017-06-23T04:35:22.145+0200",
                    "jsdPublic": true
                }
            ],
            "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/comment",
            "maxResults": 1,
            "total": 1,
            "startAt": 0
        },
        "votes": {
            "self": "https://powershell.atlassian.net/rest/api/2/issue/TV-14/votes",
            "votes": 0,
            "hasVoted": false
        },
        "worklog": {
            "startAt": 0,
            "maxResults": 20,
            "total": 1,
            "worklogs": [
                {
                    "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/worklog/10007",
                    "author": {
                        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "emailAddress": "oliver@lipkau.net",
                    },
                    "updateAuthor": {
                        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
                        "emailAddress": "oliver@lipkau.net",
                    },
                    "created": "2021-03-20T22:30:47.694+0100",
                    "updated": "2021-03-20T22:30:47.694+0100",
                    "started": "2021-03-20T22:30:00.000+0100",
                    "timeSpent": "3d",
                    "timeSpentSeconds": 86400,
                    "id": "10007",
                    "issueId": "10013"
                }
            ]
        }
    }
}
"@

        #region Mocks
        Mock ConvertTo-JiraAttachment -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Attachment]@{ } }
        Mock ConvertTo-JiraComment -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Comment]@{ } }
        Mock ConvertTo-JiraComponent -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Component]@{ } }
        # Mock ConvertTo-JiraIssue -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Issue]@{ } }
        Mock ConvertTo-JiraIssueLink -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.IssueLink]@{ } }
        Mock ConvertTo-JiraIssueType -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.IssueType]@{ } }
        Mock ConvertTo-JiraPriority -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Priority]@{ } }
        Mock ConvertTo-JiraProject -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Project]@{ } }
        Mock ConvertTo-JiraStatus -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Status]@{ } }
        Mock ConvertTo-JiraTransition -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Transition]@{ } }
        Mock ConvertTo-JiraUser -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.User]@{ } }
        Mock ConvertTo-JiraWorklogItem -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.WorklogItem]@{ } }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Issue]1000 | Should -BeOfType [AtlassianPS.JiraPS.Issue]
            [AtlassianPS.JiraPS.Issue]"Fix Bugs" | Should -BeOfType [AtlassianPS.JiraPS.Issue]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Issue]@{
                Key    = "TV-14"
                Fields = @{
                    summary = "Fix some Bugs"
                    creator = $mockedJiraCloudUser
                }
            } | Should -BeOfType [AtlassianPS.JiraPS.Issue]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $assertMockCalledSplat = @{
                ModuleName = 'JiraPS'
                Exactly    = $true
                Times      = 1
                Scope      = 'Describe'
            }

            $issue = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssue -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Issue object" {
            $issue | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Issue]" {
            $issue | Should -BeOfType [AtlassianPS.JiraPS.Issue]
        }

        It 'converts nested types' {
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraAttachment'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraComment'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraComponent'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraIssueLink'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraIssueType'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraPriority'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraProject'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraStatus'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraTransition'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraUser' -Times 3
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraWorklogItem'
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $issue = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssue -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10013' }
            @{ property = 'Key'; value = 'TV-14' }
            @{ property = 'Fields'; type = 'Hashtable' }
            @{ property = 'Transition'; type = 'AtlassianPS.JiraPS.Transition[]' }
            @{ property = 'Expand'; type = 'String[]' }
            @{ property = 'HttpUrl'; value = 'https://powershell.atlassian.net/browse/TV-14' }
            @{ property = 'RestUrl'; value = 'https://powershell.atlassian.net/rest/api/latest/issue/10013' }
        ) {
            $issue.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $issue.$property | Should -Be $value
            }
            if ($type) {
                , ($issue.$property) | Should -BeOfType $type
            }
        }

        It "has a property '<property>' with value '<value>' of type '<type>' in the Fields" -ForEach @(
            @{ property = 'Summary'; value = 'As a user, I can find important items on the board by using the customisable "Quick Filters" above >> Try clicking the "Only My Issues" Quick Filter above' }
            @{ property = 'Description'; value = "*Creating Quick Filters*`n`nYou can add your own Quick Filters in the board configuration (select *Board > Configure*)" }
            @{ property = 'statuscategorychangedate'; type = 'DateTime' }
            @{ property = 'lastViewed'; type = 'DateTime' }
            @{ property = 'created'; type = 'DateTime' }
            @{ property = 'updated'; type = 'DateTime' }
            @{ property = 'timespent'; type = 'TimeSpan' }
            @{ property = 'timeestimate'; type = 'TimeSpan' }
            @{ property = 'timeoriginalestimate'; type = 'TimeSpan' }
            @{ property = 'aggregatetimespent'; type = 'TimeSpan' }
            @{ property = 'resolution' <# TODO: #> }
            @{ property = 'customfield_10107' }
            @{ property = 'issuerestriction' <# TODO: #> }
            @{ property = 'timetracking' <# TODO: #> }
            @{ property = 'aggregateprogress' <# TODO: #> }
            @{ property = 'progress' <# TODO: #> }
            @{ property = 'votes' <# TODO: #> }
            @{ property = 'worklog' <# TODO: #> }
            @{ property = 'IssueType'; type = 'AtlassianPS.JiraPS.IssueType' }
            @{ property = 'Project'; type = 'AtlassianPS.JiraPS.Project' }
            @{ property = 'Priority'; type = 'AtlassianPS.JiraPS.Priority' }
            @{ property = 'IssueLink'; type = 'AtlassianPS.JiraPS.IssueLink' }
            @{ property = 'Status'; type = 'AtlassianPS.JiraPS.Status' }
            @{ property = 'Component'; type = 'AtlassianPS.JiraPS.Component' }
            @{ property = 'Creator'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'Reporter'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'Comment'; type = 'AtlassianPS.JiraPS.Comment' }
            @{ property = 'Version'; type = 'AtlassianPS.JiraPS.Version' }
            @{ property = 'Attachment'; type = 'AtlassianPS.JiraPS.Attachment' }
            @{ property = 'FixVersion'; value = @('v1', 'v2'); <# type = 'AtlassianPS.JiraPS.Version'#> }
            # Note for 'FixVersion' and 'Attachment':
            #   Powershell reports it as `Object[]` because the first object is stored to memory
            #   and the type is defined.
            #   The type is not recalculated once the second object is added to the collection.
        ) {
            $issue.Fields.Keys | Should -Contain $property
            if ($value) {
                $issue.Fields.$property | Should -Be $value
            }
            if ($type) {
                , ($issue.Fields.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $issue.ToString() | Should -Be '[TV-14] As a user, I can find important items on the board by using the customisable "Quick Filters" above >> Try clicking the "Only My Issues" Quick Filter above'
        }
    }
}
