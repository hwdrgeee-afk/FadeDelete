[Console]::OutputEncoding=[Text.Encoding]::UTF8
Clear-Host

$global:step = 0
$total = 16

function Run-Step($name,$script){

    $global:step++

    Write-Host ""
    Write-Host ("[{0:00}/{1}] {2}" -f $step,$total,$name) -ForegroundColor Cyan

    try{
        & $script
        Write-Host "  [OK]" -ForegroundColor Green
    }
    catch{
        Write-Host "  [FAIL]" -ForegroundColor Red
    }
}

Write-Host "=== Fade ===" -ForegroundColor Yellow
Start-Sleep 1

Run-Step "Temp files" {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Run-Step "PowerShell history" {
    $p="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if(Test-Path $p){ Remove-Item $p -Force }
}

Run-Step "Recent files" {
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Run-Step "DNS cache" {
    Clear-DnsClientCache
}

Run-Step "Thumbnail cache" {
    Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*" -Force -ErrorAction SilentlyContinue
}

Run-Step "Recycle bin" {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

Run-Step "Chrome cache" {
    $c="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    if(Test-Path $c){
        Remove-Item "$c\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Run-Step "Edge cache" {
    $e="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    if(Test-Path $e){
        Remove-Item "$e\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Run-Step "Windows search index" {
    Stop-Service WSearch -ErrorAction SilentlyContinue
    Remove-Item "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service WSearch -ErrorAction SilentlyContinue
}

Run-Step "Icon cache" {
    Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
}

Run-Step "Downloads zone info" {
    Get-ChildItem "$env:USERPROFILE\Downloads" -Recurse -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue
}

Run-Step "Network cache" {
    ipconfig /flushdns | Out-Null
}

Run-Step "Explorer restart" {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer
}

Run-Step "Windows error reports" {
    Remove-Item "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Run-Step "Crash dumps" {
    Remove-Item "C:\Windows\Minidump\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Run-Step "Finalize" {
    Start-Sleep 1
}

Write-Host ""
Write-Host "======================================"
Write-Host "Steps: $step / $total completed"
Write-Host "Restart recommended." -ForegroundColor Yellow