# Get-ShortHelp

## Synopsis
Get short, example-based help and command-line syntax for a command

## Examples

### Example 1
Invoke Get-ShortHelp (via it's standard alias) on itself

```powershell
tldr tldr
```

### Example 2
Force re-generation of a tldr file from the command's standard help

```powershell
tldr ${CommandName} -Regenerate
```

## Syntax

```powershell
Get-ShortHelp [[-Name] <String>] [[-Module] <String>] [-Regenerate] [<CommonParameters>]
```

