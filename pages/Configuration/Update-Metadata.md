# Update-Metadata

## Synopsis

Update a PowerShell module manifest

## Examples

### EXAMPLE 1

Increments the Build part of the ModuleVersion in the Configuration.psd1 file

```powershell
Update-Metadata .\Configuration.psd1
```

### EXAMPLE 2

Increments the Major version part of the ModuleVersion in the Configuration.psd1 file

```powershell
Update-Metadata .\Configuration.psd1 -Increment Major
```

### EXAMPLE 3

Sets the ModuleVersion in the Configuration.psd1 file to 0.4

```powershell
Update-Metadata .\Configuration.psd1 -Value '0.4'
```

### EXAMPLE 4

Sets the PrivateData.PSData.ReleaseNotes value in the Configuration.psd1 file!

```powershell
Update-Metadata .\Configuration.psd1 -Property ReleaseNotes -Value 'Add the awesome Update-Metadata function!'
```

## Syntax

```powershell
Update-Metadata [[-Path] <String>] [-PropertyName <String>] -Value <Object> [<CommonParameters>]

Update-Metadata [[-Path] <String>] [-Increment <String>] [-Passthru] [<CommonParameters>]
```

