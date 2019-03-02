@"
package.path = ";./?.lua;./?/init.lua;%APPDATA%/Lunar/?.lua;%APPDATA%/Lunar/?/init.lua;" .. package.path

require("lunar.lunarc")
"@ | lua
