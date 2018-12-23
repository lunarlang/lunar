[Busted]: http://olivinelabs.com/busted/
[LuaRocks]: https://luarocks.org/

<div align="center"><img src="https://i.imgur.com/xVujd8N.png"/></div>

# Lunar
The Lua 5.1 superset programming language.

## Getting Started
### Prerequisites
You will need Lua 5.1 runtime, [luarocks][LuaRocks] (lua package manager), and [busted][Busted] (unit testing framework).  
On some installs of Lua, you might not have `./?.lua` in your `LUA_PATH`. Configure your system environment variables and append `;;./?.lua` into `LUA_PATH`.
```
$ git clone https://github.com/lunarlang/lunar
$ luarocks install busted
$ cd ./lunar # the root folder, not the lunar source code folder.
```

### Running Tests
Just run `busted` with the root directory of this repository as the current working directory.
