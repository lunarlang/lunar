[Console]::WriteLine("Installing Lunar...")

$targetDir = Join-Path $env:APPDATA "Lunar"
$binDir = Join-Path $PSScriptRoot "bin"
$lunarDir = Join-Path $PSScriptRoot "dist/lunar"

if (Test-Path $targetDir) {
  $confirmation = Read-Host "A Lunar was install found, would you like to reinstall or uninstall it? [R/U]"

  if ($confirmation.ToLower() -eq "u") {
    [Console]::WriteLine("Uninstalling Lunar...")
    $escaped = [regex]::escape($targetDir)
    $cleanPath = $env:PATH -replace ";$escaped",""
    [Environment]::SetEnvironmentVariable("Path", $cleanPath, [System.EnvironmentVariableTarget]::Machine)
    Remove-Item $targetDir -Recurse
    exit
  } else {
    [Console]::WriteLine("Preparing Lunar for reinstall...")
    Remove-Item $targetDir -Recurse
  }
}

[Console]::WriteLine("This may take a few seconds.")

$env:LUA_PATH = "./lib/?.lua;./lib/?/init.lua;$env:LUA_PATH"
Start-Process (Get-Command lua).Source -ArgumentList "$PSScriptRoot/lib/lunar/lunarc/init.lua" -WorkingDirectory "$PSScriptRoot" -Wait -NoNewWindow
Copy-Item -Path $binDir,$lunarDir -Destination $targetDir -Container -Recurse

$env:PATH += ";" + $targetDir
[Environment]::SetEnvironmentVariable("Path", $env:PATH, [System.EnvironmentVariableTarget]::Machine)

[Console]::WriteLine("Lunar has been installed in $targetDir")

Write-Host "Press any key to close this window."
Read-Host
