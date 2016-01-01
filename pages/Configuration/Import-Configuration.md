# Import-Configuration

> Import layered configuration files for a module.

- Load configuration data within your own module

`${Configuration} = Import-Configuration`

- Load configuration data for a specified module

`${Configuration} = Get-Module ${ModuleName} | Import-Configuration`

## Full Syntax

`Import-Configuration [-CallStack <CallStackFrame[]>] [-Version <Version>] [<CommonParameters>]`

`Import-Configuration [-Module <PSModuleInfo>] [-Version <Version>] [<CommonParameters>]`

`Import-Configuration -CompanyName <String> -Name <String> [-DefaultPath <String>] [-Version <Version>] [<CommonParameters>]`

