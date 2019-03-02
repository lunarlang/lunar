@"
package.path = package.path .. ";./?.lua;./?/init.lua;/usr/lib/lunar/?.lua;/usr/lib/lunar/?/init.lua;"
require("lunar.lunarc")
"@ | lua
