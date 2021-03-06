# Get-ShortHelp

## Synopsis

Get the short example-based help for a command

## Examples

### EXAMPLE 1

Invokes Get-ShortHelp via it's standard alias, on itself.

```powershell
tldr tldr
```

### EXAMPLE 2

Invokes Get-ShortHelp for each of the commands in the tldr module.

```powershell
Get-Command -Module tldr | Get-ShortHelp
```


## Syntax

```powershell
Get-ShortHelp [[-Name] <String>] [-Module <String>] [-Online] [-NoCache] [-Regenerate] [<CommonParameters>]
```

