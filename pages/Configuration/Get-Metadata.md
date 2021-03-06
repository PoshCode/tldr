# Get-Metadata

## Synopsis

Reads a specific value from a module manifest file

## Examples

### EXAMPLE 1

Returns the module version number as a string. This is the default property that Get-Metadata returns.

```powershell
Get-Metadata .\Configuration.psd1
```

### EXAMPLE 2

Returns the release notes (from inside the PrivatData\PSData section created by PowerShellGet)

```powershell
Get-Metadata .\Configuration.psd1 ReleaseNotes
```

## Syntax

```powershell
Get-Metadata [[-Manifest] <String>] [[-PropertyName] <String>] [-Passthru] [<CommonParameters>]
```

