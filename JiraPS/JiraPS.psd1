@{
    RootModule        = 'JiraPS.psm1'
    ModuleVersion     = '3.0'
    GUID              = '4bf3eb15-037e-43b7-9e47-20a30436324f'
    Author            = 'AtlassianPS'
    CompanyName       = 'AtlassianPS.org'
    Copyright         = '(c) 2017 AtlassianPS. All rights reserved.'
    Description       = 'Windows PowerShell module to interact with Atlassian JIRA'
    PowerShellVersion = '3.0'
    # RequiredModules    = @()
    # RequiredAssemblies = @()
    # ScriptsToProcess   = @()
    # TypesToProcess     = @()
    FormatsToProcess  = 'JiraPS.format.ps1xml'
    # NestedModules = @()
    FunctionsToExport = '*'
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = '*'
    # ModuleList = @()
    FileList          = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @(
                "powershell",
                "powershell-gallery",
                "readthedocs",
                "rest",
                "api",
                "atlassianps",
                "jira",
                "atlassian"
            )
            LicenseUri = 'https://github.com/AtlassianPS/JiraPS/blob/master/LICENSE'
            ProjectUri = 'https://AtlassianPS.org/module/JiraPS'
            IconUri    = 'https://AtlassianPS.org/assets/img/JiraPS.png'
            # ReleaseNotes = ''
            # ExternalModuleDependencies = ''
        }
    }
    # HelpInfoURI = ''
    # DefaultCommandPrefix = ''
}
