$targetDir = Join-Path $env:APPDATA "Lunar"
$binDir = Join-Path $PSScriptRoot "bin"
$lunarDir = Join-Path $PSScriptRoot "dist/lunar"

$windowsId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$windowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($windowsId)

if (!$windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process -Verb runAs "powershell" -ArgumentList "$PSScriptRoot/install.ps1"
} else {

  if (Test-Path $targetDir) {
    $confirmation = Read-Host "Would you like to reinstall or uninstall? [R/U]"

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

  Copy-Item -Path $binDir,$lunarDir -Destination $targetDir -Container -Recurse

  $env:PATH += ";" + $targetDir
  [Environment]::SetEnvironmentVariable("Path", $env:PATH, [System.EnvironmentVariableTarget]::Machine)

  [Console]::WriteLine("Lunar has been installed in $targetDir")
}
