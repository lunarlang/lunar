$path = [regex]::escape($env:APPDATA)

@"
package.path = ";./?.lua;./?/init.lua;$path/Lunar/?.lua;$path/Lunar/?/init.lua;" .. package.path

require("lunar.lunarc")
"@ | lua
