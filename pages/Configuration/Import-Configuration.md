# Import-Configuration

## Synopsis

Import layered configuration files for a module.


## Examples

### EXAMPLE 1
Load configuration data within your own module

```powershell
${Configuration} = Import-Configuration
```

### EXAMPLE 2
Load configuration data for a specified module

```powershell
${Configuration} = Get-Module ${ModuleName} | Import-Configuration
```

## Syntax

```powershell
Import-Configuration [-CallStack <CallStackFrame[]>] [-Version <Version>] [<CommonParameters>]

Import-Configuration [-Module <PSModuleInfo>] [-Version <Version>] [<CommonParameters>]

Import-Configuration -CompanyName <String> -Name <String> [-DefaultPath <String>] [-Version <Version>] [<CommonParameters>]
```