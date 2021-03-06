# Export-Metadata


## Synopsis

Creates a metadata file from a simple object

## Examples

### EXAMPLE 1

Export a configuration object (or hashtable) to the default Configuration.psd1 file for a module
The Configuration module uses Configuration.psd1 as it's default config file.

```powershell
$Configuration | Export-Metadata .\Configuration.psd1
```

## Syntax

```powershell
Export-Metadata [-Path] <Object> [-CommentHeader <String>] -InputObject <Object> [-Converters <Hashtable>] [-Passthru] [<CommonParameters>]
```

