$cwdPath = (Get-Item -Path ".\").FullName

$env:PATH += ";" + $cwdPath + "\bin"
[Environment]::SetEnvironmentVariable("Path", $env:PATH, [System.EnvironmentVariableTarget]::User)

$env:LUA_PATH += ";" + ($cwdPath + "\?.lua")
$env:LUA_PATH += ";" + ($cwdPath + "\?\init.lua")
[Environment]::SetEnvironmentVariable("LUA_PATH", $env:LUA_PATH, [System.EnvironmentVariableTarget]::User)
