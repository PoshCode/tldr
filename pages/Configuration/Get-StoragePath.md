# Get-StoragePath

## Synopsis

Gets an application storage path outside the module storage folder

## Examples

### EXAMPLE 1

This example shows how to use Get-StoragePath with Export-CliXML to cache some data from inside a module.

```powershell
$CacheFile = Join-Path (Get-StoragePath) Data.clixml
$Data | Export-CliXML -Path $CacheFile
```

## Syntax

```powershell
Get-StoragePath [-Scope {User | Machine | Enterprise | AppDomain}] [-Module <PSModuleInfo>] [-Version <Version>] [<CommonParameters>]

Get-StoragePath [-Scope {User | Machine | Enterprise | AppDomain}] [-CallStack <CallStackFrame>] [-Version <Version>] [<CommonParameters>]

Get-StoragePath [-Scope {User | Machine | Enterprise | AppDomain}] -CompanyName <String> -Name <String> [-DefaultPath <String>] [-Version <Version>] [<CommonParameters>]
```

