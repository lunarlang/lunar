$cwdPath = (Get-Item -Path ".\").FullName
$targetDir = Join-Path $env:APPDATA "Lunar"
$binDir = Join-Path $cwdPath "bin"
$lunarDir = Join-Path $cwdPath "lunar"

if (Test-Path $targetDir) {
  $confirmation = Read-Host "Would you like to reinstall or uninstall? [R/U]"

  if ($confirmation.ToLower() -eq "u") {
    [Console]::WriteLine("Uninstalling Lunar...")
    Remove-Item $targetDir -Recurse
    exit
  } else {
    [Console]::WriteLine("Preparing Lunar for reinstall...")
    Remove-Item $targetDir -Recurse
  }
}

Copy-Item -Path $binDir,$lunarDir -Destination $targetDir -Container -Recurse

$env:PATH += ";" + $targetDir
[Environment]::SetEnvironmentVariable("Path", $env:PATH, [System.EnvironmentVariableTarget]::User)

$env:LUA_PATH += ";" + ($targetDir + "\?.lua")
$env:LUA_PATH += ";" + ($targetDir + "\?\init.lua")
[Environment]::SetEnvironmentVariable("LUA_PATH", $env:LUA_PATH, [System.EnvironmentVariableTarget]::User)

[Console]::WriteLine("Lunar has been installed in $targetDir")
