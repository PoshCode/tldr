# Export-Configuration

## Synopsis

Exports a configuration object to a specified path.

## Examples

### EXAMPLE 1

This example shows how to use Export-Configuration in your module to cache some data.

```powershell
@{UserName = $Env:UserName; LastUpdate = [DateTimeOffset]::Now } | Export-Configuration
```

### EXAMPLE 2

This example shows how to use Export-Configuration from outside the module to export data for use within the module.

```powershell
Get-Module Configuration | Export-Configuration @{UserName = $Env:UserName; LastUpdate = [DateTimeOffset]::Now }
```

## Syntax

```powershell
Export-Configuration [-InputObject] <Object> [-Module <PSModuleInfo>] [-Version <Version>] [-WhatIf] [-Confirm] [<CommonParameters>]

Export-Configuration [-InputObject] <Object> [-CallStack <CallStackFrame>] [-Version <Version>] [-WhatIf] [-Confirm] [<CommonParameters>]

Export-Configuration [-InputObject] <Object> -CompanyName <String> -Name <String> [-DefaultPath <String>] [-Scope {User | Machine | Enterprise | AppDomain}] [-Version <Version>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

