#requires -Module @{ModuleName="Configuration"; ModuleVersion="0.3"}

function GetStoragePath {
    Configuration\Get-StoragePath
}

function ImportConfiguration {
    #.Synopsis
    #   Read the colors from the configuration file
    $Config = Configuration\Import-Configuration
    $script:NameColors = $Config.Colors.Name
    $script:SynopsisColors = $Config.Colors.Synopsis
    $script:DescriptionColors = $Config.Colors.Description
    $script:CodeColors = $Config.Colors.Code
    $script:VariableColors = $Config.Colors.Variables
}

function Set-TldrConfiguration {
    #.Synopsis
    #   Change options in the configuration files
    #.Description
    #   Imports your current configuration, changes the specified options, and stores them
    param(
        [hashtable]$NameColors,
        [hashtable]$SynopsisColors,
        [hashtable]$DescriptionColors,
        [hashtable]$CodeColors,
        [hashtable]$VariableColors
    )
    $Config = Configuration\Import-Configuration

    # Enumerate all those color values
    foreach($key in $PSBoundParameters.Keys) {
        foreach($color in $PSBoundParameters[$key].Keys) {
            if($color -notin "Foreground","Background") {
                throw "Invalid key '$Color' in ${key}: should be 'Foreground' or 'Background'"
            }
            if(!($PSBoundParameters[$key][$color] -as [ConsoleColor])) {
                throw "Invalid value for $key.$color, must be a ConsoleColor"
            }
            $Config.Colors[($key -replace "Colors$")] = $PSBoundParameters[$key]
        }
    }

    $Config | Configuration\Export-Configuration

    # Update the script-scope variables without re-reading the config (again)
    $script:NameColors = $Config.Colors.Name
    $script:SynopsisColors = $Config.Colors.Synopsis
    $script:DescriptionColors = $Config.Colors.Description
    $script:CodeColors = $Config.Colors.Code
    $script:VariableColors = $Config.Colors.Variables
}

function Get-ShortHelp {
    #.Synopsis
    #   Get the short example-based help for a command
    #.Example
    #   tldr tldr
    #   Invokes Get-ShortHelp via it's standard alias, on itself.
    [CmdletBinding()]
    param(
        # The name of a command to fetch some examples for
        [Alias("Command")]
        [string]$Name = "*",

        # A Module name to filter the results
        [string]$Module,

        # If set, generates a new tldr file from the help
        [switch]$Regenerate
    )
    if(!$StoragePath) { $Script:StoragePath = GetStoragePath }
    $Command = Resolve-Command @PSBoundParameters

    # Find the command if it's available on the local system
    $FullName = $Name    

    if($Command) {
        $Name = $Command.Name
        $Module = $Command.ModuleName
    } else {
        # If we didn't find the command, we can still show help
        # We support two syntaxes, because Get-Command does:
        # Get-ShortHelp Get-Service -Module Microsoft.PowerShell.Management
        # Get-ShortHelp Microsoft.PowerShell.Management\Get-Service
        $Module, $Name = $Name -split "[\\/](?=[^\\/]+$)",2
        if(!$Name) {
            $Name = $Module
            $Module = $Null
        }
    }

    # TODO: if the online version is (newer?), fetch that one
    
    $HelpFile = Find-TldrDocument $Name $Module

    # Use syntax from the actual command help, if available
    if($Command) {
        $Help = Get-Help $Command
        $Syntax = $Help.Syntax | Out-String -stream -width 1e4 | Where-Object { $_ }
    }

    # Error conditions
    if($Regenerate -or !$HelpFile) {
        if($Help) {
            Write-Warning "tldr page not found for $Name. Generating from help"
            $HelpFile = New-TldrDocument $Command
        }
        else {
            Write-Error "No help or command found for $FullName"
            return
        }
    }
    Write-Help $HelpFile $Syntax
}

function Resolve-Command {
    [OutputType([System.Management.Automation.CommandInfo])]
    [CmdletBinding()]
    param(
        # The name of a command to fetch some examples for
        [Alias("Command")]
        [string]$Name = "*",

        # A Module name to filter the results
        [string]$Module        
    )
    $Command = Get-Command @PSBoundParameters -Type "Alias", "Function", "Filter", "Cmdlet", "ExternalScript", "Script", "Workflow", "Configuration"
    if($Command -is [System.Management.Automation.AliasInfo]) {
        $Command = Get-Command $Command.Definition
    }
    return $Command
}

function Find-TldrDocument {
    param(
        # The name of a command to fetch some examples for
        [Alias("Command")]
        [string]$Name = "*",

        # A Module name to filter the results
        [string]$Module
    )

    # And append that to the search path if it exists
    if($Module) {
        $local:StoragePath = Join-Path $StoragePath $Module
        if(Test-Path $local:StoragePath) {
            Remove-Variable StoragePath -Scope Local
        }
    }

    Get-ChildItem $StoragePath -Recurse -Filter "${Name}.md" | Convert-Path
}

function New-TldrDocument {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Management.Automation.CommandInfo]$CommandInfo
    )
    begin {
        if(!$StoragePath) { $Script:StoragePath = GetStoragePath }

        $prefix = "PS C:\\>" # Stupid prefix is sometimes in the code, sometimes not        
    }
    process {
        $ErrorActionPreference = "Stop"
        $Help = Get-Help $CommandInfo

        $Module = $Help.ModuleName
        $Name = $Help.Name
        $Synopsis = $Help.Synopsis
        $Syntax = $Help.Syntax | Out-String -stream -width 1e4 | Where-Object { $_ }

        $local:StoragePath = Join-Path $StoragePath $Module
        $null = mkdir $StoragePath -force
        $HelpFile = Join-Path $StoragePath "${Name}.md"

        Write-Progress "Generating HelpFile:" "$HelpFile"
        Write-Warning "You should edit the generated file to match the contribution guidelines before submitting it for others to use.`nFILE PATH:`n$HelpFile`n    See also: Get-Help about_tldr`n`n"

        "# $Name`n" | Out-File $HelpFile
        "> $Synopsis`n" | Out-File $HelpFile -Append

        foreach($example in $Help.Examples.example) {
            $code = $example.code -split "[\r\n]+"
            # We always want the first line, *maybe* other lines with the prompt prefix
            $code = @($code[0]) + @($code[1..1e3] -match $prefix) -replace $prefix

            # We really aren't interested in those long-winded explanations, but keep the first paragraph
            $remarks = $example.remarks[0].Text
            "- $remarks`n" | Out-File $HelpFile -Append
            "``$code```n" | Out-File $HelpFile -Append
        }

        "`n## Full Syntax`n" | Out-File $HelpFile -Append
        foreach($syn in $syntax) {
            "``$syn```n" | Out-File $HelpFile -Append
        }

        Convert-Path $HelpFile
    }
}

function Write-Help {
    [CmdletBinding()]
    param($HelpFile, $Syntax)
    ImportConfiguration
    switch -regex (Get-Content $HelpFile) {
        '^\s*##\s*' {
            # If we have generated syntax, we'll use that instead:
            if($Syntax) { break }
            # Otherwise, continue...
            $Name = $_ -replace '^#+\s*(.*)','$1'
            Write-Host $Name @NameColors
            # Write-Host ("-" * $Name.Length) @NameColors
            continue
        }
        '^\s*#\s*' { 
            $Name = $_ -replace '^#+\s*(.*)','$1'
            Write-Host $Name @NameColors
            # Write-Host ("=" * $Name.Length) @NameColors
        }
        
        '^\s*>\s*' { Write-Host ($_ -replace '^\s*>\s*') @SynopsisColors }
        
        # Example Descriptions
        '^\s*-\s*' { Write-Host ($_ -replace '^\s*-\s*(.*)',"- `$1") @DescriptionColors }
        
        # Example Code
        '^\s*`\s*' { Write-Code $_ }

        default { Write-Host }
    }
    if($Syntax) {
        Write-Host "Full Syntax:" @NameColors
        # Write-Host "-----------" @NameColors
        Write-Host
        $Syntax | Write-Code -VariablePattern "(?=\<.*?\>)|(?<=\<.*?\>)"
    }
}


filter Write-Code {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Code,

        $VariablePattern = "(?=\$\{.*?\})|(?<=\$\{.*?\})"
    )
    $Code = $Code -replace '^\s*`?(.*?)`?$', '    $1'
    switch -regex ($Code -split $VariablePattern) {
        $VariablePattern { Write-Host $_ @VariableColors -NoNewLine}
        default { Write-Host $_ @CodeColors  -NoNewLine}
    }
    Write-Host "`n"
}


Set-Alias tldr Get-ShortHelp
