# Set-TldrConfiguration

## Synopsis

Change options in the configuration files

## Examples

### EXAMPLE 1

Set the color used for printing section names to a blue foreground

```powershell
Set-TldrConfiguration -NameColors @{ Foreground = "Blue" }
```

### EXAMPLE 2

Set the colors used for printing code snippets

```powershell
Set-TldrConfiguration -CodeColors @{ Foreground = "Blue"; Background = "Black" } -VariableColors @{ Foreground = "DarkGray"; Background = "Black"}
```



## Syntax

```powershell
Set-TldrConfiguration [[-NoCache] <Boolean>] [[-NameColors] <Hashtable>] [[-SynopsisColors] <Hashtable>] [[-DescriptionColors] <Hashtable>] [[-CodeColors] <Hashtable>] [[-VariableColors] <Hashtable>] [<CommonParameters>]
```

