#requires -modules JiraPS
#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

$script:DebugMode = $false

#region ExposedFunctions
function Invoke-InitTest {
    param(
        [Parameter(Mandatory)]
        $Path
    )

    Remove-Item -Path Env:\BH*
    $projectRoot = Get-ProjectPath -Path $Path

    Import-Module BuildHelpers
    Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

    # Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"
    Remove-Module JiraPS -ErrorAction SilentlyContinue
}

function Get-ProjectPath {
    param(
        [Parameter(Mandatory)][String]$Path
    )

    $_path = Resolve-Path $Path
    While ($_path) {
        $nextLevel = Split-Path -Path $_path

        if ((Get-ChildItem $_path -Force -Attributes D).Name -contains '.git') { return $_path }
        elseif ($_path -eq $nextLevel) { return $null }
        else { $_path = $nextLevel }
    }
}

function Invoke-TestCleanup {
    param()
    Remove-Module JiraPS -ErrorAction SilentlyContinue
    Remove-Module BuildHelpers -ErrorAction SilentlyContinue
    Remove-Item -Path Env:\BH*
}

function Set-DebugMode {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param([Bool]$Enabled)
    $script:DebugMode = $Enabled
}

function Write-MockInfo {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    param(
        $functionName,
        [Hashtable]$parameter
    )
    if ($script:DebugMode) {
        Write-Host "       Mocked $functionName" -ForegroundColor Cyan
        foreach ($p in $parameter.Keys) {
            Write-Host "         [$p]  $($parameter[$p])" -ForegroundColor Cyan
        }
    }
}

#region Mocked objects
$mockedJiraFilter = [AtlassianPS.JiraPS.Filter]@{
    Id      = 10005
    RestUrl = 'https://jira.example.com/rest/api/latest/filter/10005'
}
$mockedJiraIssue = [AtlassianPS.JiraPS.Issue]@{
    Id      = 41701
    Key     = 'TEST-001'
    Fields  = @{ Summary = 'A cool ticket' }
    RestURL = 'http://jiraserver.example.com/rest/api/latest/issue/41701'
}
$mockedJiraIssueLink = [AtlassianPS.JiraPS.IssueLink]@{
    type         = [AtlassianPS.JiraPS.IssueLinkType]@{name = 'Composition' }
    outwardIssue = [AtlassianPS.JiraPS.Issue]@{key = 'TEST-002' }
}
$mockedJiraIssueComment = [AtlassianPS.JiraPS.Comment]@{
    Id           = "10103"
    Body         = "restricted comment"
    Author       = $mockedJiraServerUser
    UpdateAuthor = $mockedJiraCloudUser
    Created      = Get-Date "2021-04-05T20:35:03.838+0200"
    Updated      = Get-Date "2021-04-05T20:35:03.838+0200"
    Visibility   = @{
        type  = "role"
        value = "Developers"
    }
    RestUrl      = "https://powershell.atlassian.net/rest/api/2/issue/10013/comment/10103"
}
$mockedJiraComponent = [AtlassianPS.JiraPS.Component]@{
    Id          = "11000"
    Name        = "test component"
    Description = "A test component"
    RestUrl     = "http://jiraserver.example.com/rest/api/2/component/11000"
}
$mockedJiraIssueType = [AtlassianPS.JiraPS.IssueType]@{
    Id   = 40001
    Name = 'Bug'
}
$mockedJiraProject = [AtlassianPS.JiraPS.Project]@{
    Id   = 20001
    Key  = 'TV'
    Name = 'T Virus'
}
$mockedJiraProjectCategory = [AtlassianPS.JiraPS.ProjectCategory]@{
    Id          = 10000
    Name        = "Home Connect"
    Description = "Home Connect Projects"
    RestUrl     = "http://jiraserver.example.com/rest/api/latest/projectCategory/10000"
}
$mockedJiraRole = [AtlassianPS.JiraPS.Role]@{
    Id   = 30001
    Name = "Administrators"
}
$mockedJiraStatus = [AtlassianPS.JiraPS.Status]@{
    Id          = 4
    Name        = "In Progress"
    Description = "something"
    Category    = $mockedJiraStatusCategory
    IconUrl     = "http://jiraserver.example.com/rest/api/2/statuscategory/inprogress.gif"
    RestUrl     = "http://jiraserver.example.com/rest/api/2/statuscategory/4"
}
$mockedJiraStatusCategory = [AtlassianPS.JiraPS.StatusCategory]@{
    Id        = 2
    Key       = "new"
    Name      = "To Do"
    ColorName = "blue-gray"
    RestUrl   = "https://powershell.atlassian.net/rest/api/2/statuscategory/2"
}
$mockedJiraServerUser = [AtlassianPS.JiraPS.User]@{
    Key          = 'fred'
    Name         = 'Frédéric Chopin'
    DisplayName  = 'Chopin'
    EmailAddress = 'chipin@musicschool.pl'
    Active       = $true
    RestUrl      = 'http://jiraserver.example.com/rest/api/2/user?username=fred'
}
$mockedJiraCloudUser = [AtlassianPS.JiraPS.User]@{
    AccountId    = 'hannes'
    Name         = 'Johannes Chrysostomus Wolfgangus Theophilus Mozart'
    DisplayName  = 'Mozart'
    EmailAddress = 'mozart@musicschool.at'
    Active       = $true
    RestUrl      = 'http://jiraserver.example.com/rest/api/3/user?username=mozart'
}
#endregion Mocked objects

#region Mocked Cmdlets
function Add-CommonMocks {
    Mock Write-Debug { Write-MockDebug $Message }

    Mock Write-DebugMessage -ModuleName JiraPS { }

    Mock Invoke-JiraMethod {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        throw 'Unidentified call to Invoke-JiraMethod'
    }
}

function Add-MockConvertToJiraComponent {
    Mock ConvertTo-JiraComponent -ModuleName 'JiraPS' { $mockedJiraComponent }
}
function Add-MockConvertToJiraIssueType {
    Mock ConvertTo-JiraIssueType -ModuleName 'JiraPS' { $mockedJiraIssueType }
}
function Add-MockConvertToJiraProjectCategory {
    Mock ConvertTo-JiraProjectCategory -ModuleName 'JiraPS' { $mockedJiraProjectCategory }
}
function Add-MockConvertToJiraRole {
    Mock ConvertTo-JiraRole -ModuleName 'JiraPS' { $mockedJiraRole }
}
function Add-MockConvertToJiraUser {
    Mock ConvertTo-JiraUser -ModuleName 'JiraPS' { $mockedJiraServerUser }
}
function Add-MockGetJiraConfigServer {
    Mock Get-JiraConfigServer -ModuleName 'JiraPS' { 'http://jiraserver.example.com' }
}
function Add-MockGetJiraFilter {
    Mock Get-JiraFilter -ModuleName 'JiraPS' { $mockedJiraFilter }
}
function Add-MockGetJiraIssue {
    Mock Get-JiraIssue -ModuleName 'JiraPS' { $mockedJiraIssue }
}
# function Add-MockGetJiraIssueComment {
#     Mock Get-JiraIssueComment -ModuleName 'JiraPS' { $mockedJiraIssueComment, $mockedJiraIssueComment }
# }
function Add-MockGetJiraProject {
    Mock Get-JiraProject -ModuleName 'JiraPS' { $mockedJiraProject }
}
function Add-MockGetJiraRole {
    Mock Get-JiraRole -ModuleName 'JiraPS' { $mockedJiraRole }
}
function Add-MockResolveJiraIssueUrl {
    Mock Resolve-JiraIssueUrl -ModuleName 'JiraPS' {
        $mockedJiraIssue.RestUrl
    }
}
#endregion Mocked Cmdlets

Export-ModuleMember -Function * -Variable *

function Write-MockDebug {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    param( $Message )
    if ($script:ShowDebugText) {
        Write-Host "       [DEBUG] $Message" -ForegroundColor Yellow
    }
}

# function New-ObjectWithTypeName {
#     [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
#     param(
#         [Hashtable]$InputObject,
#         [String]$TypeName
#     )

#     $object = [PSCustomObject]$InputObject
#     $object.PSObject.TypeNames.Insert(0, $TypeName)
#     return $object
# }

#endregion ExposedFunctions

#TODO: remove

# function castsToString($obj) {
#     if ($obj -is [System.Array]) {
#         $o = $obj[0]
#     }
#     else {
#         $o = $obj
#     }

#     $o.ToString() | Should -Not -BeNullOrEmpty
# }

# function checkPsType($obj, $typeName) {
#     It "Uses output type of '$typeName'" {
#         checkType $obj $typeName
#     }
#     It "Can cast to string" {
#         castsToString($obj)
#     }
# }

