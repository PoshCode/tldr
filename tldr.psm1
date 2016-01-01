#requires -Module @{ModuleName="Configuration"; ModuleVersion="0.3"}

function GetStoragePath {
    Configuration\Get-StoragePath
}

function GetColors {
    $Config = Configuration\Import-Configuration
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
    if(!$StoragePath) {
        $Script:StoragePath = GetStoragePath
    }

    # Find the command ...
    $FullName = $Name
    $Command = Get-Command $Name -ErrorAction Ignore

    # Find the module name if there is one
    $Module, $Name = $Name -split "[\\/](?=[^\\/]+$)",2
    if(!$Name) {
        $Name = $Module
        $Module = $Null
    }

    # And append that to the search path if it exists
    if($Module) {
        $local:StoragePath = Join-Path $StoragePath $Module
        if(Test-Path $local:StoragePath) {
            Remove-Variable StoragePath -Scope Local
        }
    }

    $HelpFile = Get-ChildItem $StoragePath -Recurse -Filter "${Name}.md" | Convert-Path
    if($Command) {
        $Help = Get-Help $Command
        $Syntax = $Help.Syntax | Out-String -stream -width 1e4 | Where-Object { $_ }
    }

    if(!$HelpFile -and $Help -and !$Regenerate) {
        $Module = $Help.ModuleName
        if($Module) {
            $local:StoragePath = Join-Path $StoragePath $Module
            if(Test-Path $local:StoragePath) {
                Remove-Variable StoragePath -Scope Local
            }
        }
        $Name = $Help.Name
        $HelpFile = Get-ChildItem $StoragePath -Recurse -Filter "${Name}.md" | Convert-Path
    }

    if($Regenerate -or !$HelpFile) {
        if($Help) {
            $ErrorActionPreference = "Stop"
            Write-Warning "tldr page not found for $Name. Generating from help"
            $Module = $Help.ModuleName
            $Name = $Help.Name

            $local:StoragePath = Join-Path $StoragePath $Module
            $null = mkdir $StoragePath -force
            $HelpFile = Join-Path $StoragePath "${Name}.md"

            $Synopsis = $Help.Synopsis
            
            Write-Progress "Generating HelpFile:" "$HelpFile"
            Write-Warning "You should consider editing the generated file to match the Contribution Guidelines and submitting it for others to use.`nFILE PATH:`n$HelpFile`n    See also: Get-Help about_tldr`n`n"

            "# $Name`n" | Out-File $HelpFile
            "> $Synopsis`n" | Out-File $HelpFile -Append
            # I'm slightly torn about listing the syntax blocks here, because I don't know how many is useful
            # For example, Where-Object and ForEach-Object have, e.g. 35 combinations
            # So, we will list just the first one at the top:
            $Index = 0
            if($Command.DefaultParameterSet) {
                $Index = [array]::IndexOf( $Command.ParameterSets.Name,  $Command.DefaultParameterSet )
            }

            $prefix = "PS C:\\>" # Stupid prefix is sometimes in the code, sometimes not
            foreach($example in $Help.Examples.example) {
                $code = $example.code -split "[\r\n]+"
                # We always want the first line, *maybe* other lines with the prompt prefix
                $code = @($code[0]) + @($code[1..1e3] -match $prefix) -replace $prefix

                # We really aren't interested in your long-winded explanations.
                $remarks = $example.remarks[0].Text
                "- $remarks`n" | Out-File $HelpFile -Append
                "``$code```n" | Out-File $HelpFile -Append
            }

            "## Full Syntax`n" | Out-File $HelpFile -Append
            foreach($syn in $syntax) {
                "``$syn```n" | Out-File $HelpFile -Append
            }
        }
        else {
            Write-Error "No help or command found for $FullName"
            return
        }
    }

    Write-Help $HelpFile $Syntax

}


filter Write-Help {
    param($HelpFile, $Syntax)
    GetColors
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
