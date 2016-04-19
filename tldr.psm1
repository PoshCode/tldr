#requires -Module @{ModuleName="Configuration"; ModuleVersion="0.3"}

$PagesUrl = "https://github.com/PoshCode/tldr/raw/master/pages/"
$OnlineUrl = "https://github.com/PoshCode/tldr/blob/master/pages/"

function GetStoragePath {
    Configuration\Get-StoragePath
}

function ImportConfiguration {
    #.Synopsis
    #   Read the colors from the configuration file
    $Config = Configuration\Import-Configuration

    [bool]$script:NoCache = $Config.NoCache
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
        # If set, local caching will be ignored,
        # results will always be fetched from the ${OnlineUrl}
        [bool]$NoCache,
        # A hashtable of Foreground and Background colors for the Name
        [hashtable]$NameColors,
        # A hashtable of Foreground and Background colors for the Synopsis
        [hashtable]$SynopsisColors,
        # A hashtable of Foreground and Background colors for the Description
        [hashtable]$DescriptionColors,
        # A hashtable of Foreground and Background colors for the Examples
        [hashtable]$CodeColors,
        # A hashtable of Foreground and Background colors to highlight Variables
        [hashtable]$VariableColors
    )
    $Config = Configuration\Import-Configuration

    if($PSBoundParameters.ContainsKey("NoCache")) {
        $Config.NoCache = $NoCache
        $null = $PSBoundParameters.Remove("NoCache")
    }

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
    [bool]$script:NoCache = $Config.NoCache
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
    [CmdletBinding(DefaultParameterSetName="Text")]
    param(
        # The name of a command to fetch some examples for
        [Alias("Command")]
        [Parameter(Position=0, ParameterSetName="Text")]
        [string]$Name = "*",

        # A Module name (to make the results more specific)
        [Parameter(ParameterSetName="Text")]
        [string]$Module,


        # Show the web version of the file
        [Switch]$Online,

        # Don't consider (or create new) local copies
        # You can set the default for this option in the configuration using Set-TldrConfiguration
        [Switch]$NoCache = $script:NoCache,

        # If set, generates a new tldr file from the help
        [switch]$Regenerate
    )
    Write-Verbose "NoCache:$NoCache"
    Write-Progress "Fetching Help for $Name" "Loading help cache"

    # Cache initial data ... 
    if(!$StoragePath) {
        Write-Verbose "Load StoragePath"
        $Script:StoragePath = GetStoragePath
    }
    if(!$HelpCache){
        Write-Progress "Fetching Help for $Name" "No active cache - loading from ${PagesUrl}index.json"
        Write-Verbose "Load online help index"
        $Script:HelpCache = Invoke-RestMethod ${PagesUrl}index.json
    }

    $null = $PSBoundParameters.Remove("Regenerate")
    $null = $PSBoundParameters.Remove("NoCache")
    $null = $PSBoundParameters.Remove("Online")
    Write-Progress "Fetching Help for $Name" "Testing if command exists locally"
    $Command = Resolve-Command @PSBoundParameters

    # Find the command if it's available on the local system
    $FullName = $Name    

    if($Command) {
        $Name = $Command.Name
        $Module = $Command.ModuleName
    } else {
        Write-Verbose "Command Not Found (checking online index anyway)"
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
    $Best = $HelpCache | Where { $_.Name -eq $Name -and ($Module -eq $Null -or $Module -eq $_.Module)}
    if($Best) {
        Write-Verbose "Found online help for $($Best.Module)/$($Best.Name) last updated $($Best.Updated)"
    }

    if($Online) {
        if($Best) {
            Write-Progress "Fetching Help for $Name" "Loading online version of help into browser"
            foreach($page in $Best) {
                Start-Process "${OnlineUrl}$($page.Module)/$($page.Name).md"
            }
            return
        } else {
            Write-Error "There's no online documentation for $Module\$Name"
            return
        }
    }

    # Use syntax from the actual command, if available
    if($Command) {
        Write-Verbose "Loading syntax from PowerShell"
        $Syntax = Get-Command $Command -Syntax
    }

    if(!$NoCache -and ($HelpFile = Find-TldrDocument $Name $Module)) {
        # If they did not Module-qualify the name, and the command doesn't exist locally
        # It's possible that we have multiple matches online or locally or both
        foreach($filePath in @($HelpFile)) {
            Write-Verbose "Found $filePath for $Module\$Name"
            # Write the output right now, before we try to update ...
            Write-Help -Name $Name -Path $HelpFile -Syntax $Syntax

            # If it's ok to cache the latest, we might want to update
            if($Best) {
                $FileInfo = Get-Item $FilePath
                foreach($page in @($Best)) {
                    if($page.Module -eq $Module -or $page.Module -eq $FileInfo.Directory.Name) {
                        # FINALLY! If the online version is newer, update now
                        if($FileInfo.LastWriteTime -lt $Best.Updated) {
                            $Url ="${PagesUrl}$($Best.Module)/($Best.Name).md"
                            Write-Warning "Newer help content found online, updating $filePath with $Url"
                            Invoke-WebRequest $Url -OutFile $filePath -ErrorAction Stop
                        }
                    }
                }
            }
        }
        return
    }

    # If we don't have a local copy (or we're ignoring it) but there is one online...
    if(($NoCache -or !$HelpFile) -and $Best) {
        Write-Progress "Fetching Help for $Name" "Loading latest help file from remote server"

        foreach($page in @($Best)) {
            if($NoCache) {
                $HelpFile = [IO.Path]::GetTempFileName()
            } else {
                $null = mkdir (join-Path $Script:StoragePath $Page.Module) -force
                $HelpFile = Join-Path ${Script:StoragePath} "$($Page.Module)\$($Page.Name).md"
            }
            $Url = "${PagesUrl}$($Page.Module)/$($Page.Name).md"
            Write-Verbose "NoCache:$NoCache - Downloading $Url for to $HelpFile"
            Invoke-WebRequest $Url -OutFile "$HelpFile" -ErrorAction Stop
            Write-Help -Name $Name -Path $HelpFile -Syntax $Syntax
            if($NoCache) {
                Remove-Item $HelpFile
            }
        }
        return
    }

    # Asked to regenerate or there's no HelpFile
    if(($Help = Get-Help $Command) -and ($Regenerate -or !$HelpFile)) {
        Write-Warning "tldr page not found for $Name. Generating from built-in help."
        $HelpFile = New-TldrDocument $Command
        Write-Help -Name $Name -Path $HelpFile -Syntax $Syntax
        return
    }

    Write-Error "Cannot find help for $Name!"
    
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
    #.Synopsis
    #   Generates a new tldr help document from the command's built-in help. Called automatically by tldr when custom-written help doesn't already exist.
    #.Description
    #   Generates a new tldr help document from the command's built-in help, using just the synopsys, and snippets from the examples. 
    #
    #   Note that only the lines which appear to be commands, plus the first line of commentary are actually pulled from the examples. Depending on how well the help was written, examples may need a lot of editing to make them useful with that little commentary.
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The command we're generating help for
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

        if($PSCmdlet.ShouldProcess("Generated the file '$($HelpFile)'",
                                 "Generate the file '$($HelpFile)'?",
                                 "Generating Help Files")) {
            Write-Progress "Generating HelpFile:" "$HelpFile"
            Write-Warning "Please consider editing the generated file to match the tldr guidelines and sharing it for others to use.`nFILE PATH:`n$HelpFile`n    See also: Get-Help about_tldr`n`n"


            "# $Name`n`n" | Out-File $HelpFile
            "## Synopsis`n`n$Synopsis`n" | Out-File $HelpFile -Append
            "## Examples`n" | Out-File $HelpFile -Append

            foreach($example in $Help.Examples.example) {
                $code = $example.code -split "[\r\n]+"
                # We always want the first line, *maybe* other lines with the prompt prefix
                $code = @($code[0]) + @($code[1..1e3] -match $prefix) -replace $prefix

                # We really aren't interested in those long-winded explanations, but keep the first paragraph

                $intro = if([string]::IsNullOrWhiteSpace($example.introduction.Text)) { 
                    @($example.remarks[0].Text -split '(?<=\.) ')[0]
                } else {
                    $example.introduction.Text
                }
                "### EXAMPLE`n" | Out-File $HelpFile -Append
                "$intro`n" | Out-File $HelpFile -Append
                "``````powershell`n$code`n```````n" | Out-File $HelpFile -Append
            }

            "`n## Syntax`n" | Out-File $HelpFile -Append
            foreach($syn in $syntax) {
                "``````powershell`n$syn`n```````n" | Out-File $HelpFile -Append
            }
        }

        Convert-Path $HelpFile
    }
}

function Write-Help {
    #.Synopsis
    # Output Markdown-formatted tldr help files colorfully
    #.Notes
    # Changed in 1.1 to use the platyPS schema    
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias("Name")]
        $CommandName,

        [Parameter()]
        [Alias("File","Path","PSPath")]
        $HelpFile,

        [Parameter()]
        $Syntax = $(Get-Command $CommandName -Syntax)
    )
    ImportConfiguration

    # Syntax:
    # $Syntax| Out-String -stream -width 1e4 | Where-Object { $_ }
    Write-Debug "HelpFile: $HelpFile"

    $help = Get-Content $HelpFile -Raw

    ## indent all the code (we want to print it that way anyway)
    $help = [regex]::replace($help,'(?s)\n```.*?\n```',{ $args[0] -replace '(?m)(^(?!```).*)','    $1' })

    # foreach command name (matches '# Command Name' without throwing it out
    foreach($command in $help -split '(?m)^(?=#\s+.*$)') {
        $Name = [regex]::Match($command,'^#\s+(.*)(?m:$)').Groups[1].Value
    
        if(!$CommandName -or $CommandName -eq $Name) {
            Write-Host $Name @NameColors
            # split each section on the headline: '## whatever'
            foreach($helpBlock in $command -split '(?m)^(?=##\s+.*$)') {
                $global:match = [regex]::Match($helpBlock,'(?m)^##\s+(?<name>.*?)$').Groups['name'].Value
                $blockName = $match
                switch($blockName.trim()) {
                    "Synopsis" {
                        Write-Host "  " ($helpBlock -replace "^(.*?)(?m:$)").Split(("`r","`n")).where{$_}[0] @SynopsisColors
                    }
                    "Examples" {
                        Write-Host "`nExamples:".ToUpper() @NameColors
                        # We throw out the "EXAMPLE" junk header
                        foreach($example in $helpBlock -split '(?m)^###\s+.*$') {
                            if($example -match '(?s)(?<intro>.*)```(?:powershell)?(?<code>.*)```(?<remarks>.*)') {
                                $intro = if(![string]::IsNullOrWhiteSpace($matches['intro'])) {
                                    $matches['intro']
                                } elseif($matches['remarks']) {
                                    $matches['remarks']
                                }

                                Write-Host ($intro -split "\n").where{![string]::IsNullOrWhiteSpace($_)}[0] @DescriptionColors
                                $matches['code'] | Write-Code
                            }
                        }
                    }
                    default {
                        Write-Debug "$($helpBlock.Split(@("`r","`n")).where{$_}[0]) not wanted"
                    }
                }
            }
        }
    }

    if($Syntax) {
        Write-Host "Syntax:".ToUpper() @NameColors
        $Syntax | Out-String -stream -width 1e4 | Where-Object { $_ } | Write-Code -VariablePattern "(?=\<.*?\>)|(?<=\<.*?\>)"
    }
}

filter Write-Code {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Code,

        $VariablePattern = "(?=\$\{.*?\})|(?<=\$\{.*?\})|(?=\$\w+)|(?<=\$\w+)"
    )
    $Code = ($Code -split "[\r\n]+").where{![string]::IsNullOrWhiteSpace($_)} -join "`n"

    $Code = $Code -replace '(?m)^( {4})?PS C:\\>(.*)', '$1$2'
    $Code = $Code -replace '(?m)^(\S+.*)', '    $1'
    switch -regex ($Code -split $VariablePattern) {
        $VariablePattern { Write-Host $_ @VariableColors -NoNewLine}
        default { Write-Host $_ @CodeColors -NoNewLine}
    }
    Write-Host "`n"
}




Set-Alias tldr Get-ShortHelp
