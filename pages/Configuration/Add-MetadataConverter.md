# Add-MetadataConverter


## Synopsis

Add a converter functions for serialization and deserialization to metadata

## Examples

### EXAMPLE 1

Shows a simple example of mapping bool to a scriptblock that serializes it in a way that's inherently parseable by PowerShell.

```powershell
Add-MetadataCOnverter @{ [bool] = { if($_) { '$True' } else { '$False' } } }
```

### EXAMPLE 2

Shows how to map a function for serializing Uri objects as strings with a Uri function that just casts them.

```powershell
Add-MetadataConverter @{
    [Uri] = { "Uri '$_' " }
    "Uri" = {
        param([string]$Value)
        [Uri]$Value
    }
}

```

### EXAMPLE 3

Shows how to change the DateTimeOffset serialization.

```powershell
Add-MetadataConverter @{
    [DateTimeOffset] = { "DateTimeOffset {0} {1}" -f $_.Ticks, $_.Offset }
    "DateTimeOffset" = {param($ticks,$offset) [DateTimeOffset]::new( $ticks, $offset )}   
}
```

## Syntax

```powershell
Add-MetadataConverter [-Converters] <Hashtable> [<CommonParameters>]
```

