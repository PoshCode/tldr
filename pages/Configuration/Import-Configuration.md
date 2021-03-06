# Import-Configuration


## Synopsis

Import the full, layered configuration for the module.

## Examples

### EXAMPLE 1

This example shows how to use Import-Configuration in your module to load your Configuration.psd1
Note that this would load your defaults, plus any exported settings from the user and machine scope

```powershell
$Configuration = Import-Configuration
```

### EXAMPLE 2

This example shows how to use Import-Configuration to load data that's been cached for another module

```powershell
$Configuration = Get-Module Configuration | Import-Configuration
```

## Syntax

```powershell
Import-Configuration [-CallStack <CallStackFrame>] [-Version <Version>] [-Ordered] [<CommonParameters>]

Import-Configuration [-Module <PSModuleInfo>] [-Version <Version>] [-Ordered] [<CommonParameters>]

Import-Configuration -CompanyName <String> -Name <String> [-DefaultPath <String>] [-Version <Version>] [-Ordered] [<CommonParameters>]
```

