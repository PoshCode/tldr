&{
    Get-ChildItem (Join-Path $PSScriptRoot pages) -File -Recurse -Filter *.md |
        Select-Object @{name="Name"; expr={$_.BaseName}}, 
                      @{name="Module"; expr={$_.Directory.Name}},
                      @{name="Updated"; expr={
                        $last = [DateTimeOffset]$(git log -n 1 --pretty=format:%ai HEAD -- $_.FullName)
                        # To shrink this, remove useless nanoseconds, and always use Zulu time:
                        ("{0:o}" -f $last.UtcDateTime) -replace "\.0000000"
                       }}
} | ConvertTo-Json -Compress | Set-Content (Join-Path (Join-Path $PSScriptRoot pages) index.json)