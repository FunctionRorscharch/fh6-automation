param(
    [int]$GamePid = 31320,
    [int]$BotPid = 40704,
    [string]$LogPath = "runtime_monitor.log",
    [int]$IntervalSeconds = 10
)

$ErrorActionPreference = "SilentlyContinue"

while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $rows = @()

    foreach ($pidValue in @($GamePid, $BotPid)) {
        $proc = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
        if ($proc) {
            $rows += [pscustomobject]@{
                ts = $timestamp
                pid = $proc.Id
                name = $proc.ProcessName
                responding = $proc.Responding
                cpu = [math]::Round($proc.CPU, 3)
                memory_mb = [math]::Round($proc.WorkingSet64 / 1MB, 1)
                title = $proc.MainWindowTitle
            }
        } else {
            $rows += [pscustomobject]@{
                ts = $timestamp
                pid = $pidValue
                name = "missing"
                responding = $false
                cpu = 0
                memory_mb = 0
                title = ""
            }
        }
    }

    $rows | ConvertTo-Json -Compress | Add-Content -Path $LogPath -Encoding UTF8
    Start-Sleep -Seconds $IntervalSeconds
}
