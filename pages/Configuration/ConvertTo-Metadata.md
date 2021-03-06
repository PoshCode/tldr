# ConvertTo-Metadata


## Synopsis

Serializes objects to PowerShell Data language (PSD1)

## Examples

### EXAMPLE 1

Convert input objects into a formatted string suitable for storing in a psd1 file.

```powershell
$Name = @{ First = "Joel"; Last = "Bennett" }
@{ Name = $Name; Id = 1; } | ConvertTo-Metadata

@{
    Id = 1
    Name = @{
        Last = 'Bennett'
        First = 'Joel'
    }
}

```

### EXAMPLE 2

Convert complex custom types to metadata by first using Select-Object to convert them to dynamic PSObjects

```powershell
Get-ChildItem -File | Select-Object FullName, *Utc, Length | ConvertTo-Metadata
```

### EXAMPLE 3

Temporarily add a MetadataConverter to serialize a specific type. Note this example would require a "DateTimeOffset" function for deserialization properly

```powershell
ConvertTo-Metadata ([DateTimeOffset]::Now) -Converters @{
    [DateTimeOffset] = { "DateTimeOffset {0} {1}" -f $_.Ticks, $_.Offset }
}
```

## Syntax

```powershell
ConvertTo-Metadata [[-InputObject] <Object>] [[-Converters] <Hashtable>] [<CommonParameters>]
```

