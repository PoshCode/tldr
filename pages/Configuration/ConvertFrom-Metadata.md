# ConvertFrom-Metadata


## Synopsis

Deserializes objects from PowerShell Data language (PSD1)

## Examples

### EXAMPLE 1

Convert the example string into a real PSObject using the built-in object serializer.

```powershell
ConvertFrom-Metadata 'PSObject @{ Name = PSObject @{ First = "Joel"; Last = "Bennett" }; Id = 1; }'

Id Name
-- ----
 1 @{Last=Bennett; First=Joel}

```

### EXAMPLE 2

Convert a module manifest into a hashtable of properties for introspection, preserving the order in the file

```powershell
$data = ConvertFrom-Metadata .\Configuration.psd1 -Ordered
```

### EXAMPLE 3

Shows how to temporarily add a "ValidCommand" called "DateTimeOffset" to support extra data types in the metadata.

```powershell
ConvertFrom-Metadata ("DateTimeOffset 635968680686066846 -05:00:00") -Converters @{
    "DateTimeOffset" = {
      param($ticks,$offset)
      [DateTimeOffset]::new( $ticks, $offset )
    }
}

```


## Syntax

```powershell
ConvertFrom-Metadata [[-InputObject] <Object>] [-Converters <Hashtable>] [-ScriptRoot <Object>] [-Ordered] [<CommonParameters>]
```

