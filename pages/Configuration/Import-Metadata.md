# Import-Metadata

## Synopsis

Creates a data object from the items in a Metadata file (e.g. a .psd1)

## Examples

### EXAMPLE 1

Convert a module manifest into a hashtable of properties for introspection, preserving the order in the file

```powershell
$data = Import-Metadata .\Configuration.psd1 -Ordered
```

## Syntax

```powershell
Import-Metadata [-Path] <String> [[-Converters] <Hashtable>] [-Ordered] [<CommonParameters>]
```

