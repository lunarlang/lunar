# Building Lunar
Dependencies:
```sh
$ sudo apt install lua5.1 luarocks build-essential gcc-multilib g++-multilib mingw-w64
$ sudo luarocks install luastatic
```

Ensure you're in the root directory of Lunar.

Compile Lunar:
```sh
$ LUA_PATH="$LUA_PATH;./lib/?.lua;./lib/?/init.lua" lua ./lib/lunar/lunarc/init.lua
```

Build:
```sh
$ chmod +x ./build/scripts/build-binaries.sh
$ sudo ./build/scripts/build-binaries.sh
```

Your files *(located in `./build/bin`)*:
```sh
$ ls -l ./build/bin
```
