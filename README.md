[Busted]: http://olivinelabs.com/busted/
[LuaRocks]: https://luarocks.org/

<div align="center"><img src="https://i.imgur.com/xVujd8N.png"/></div>

# Lunar
[![Build Status](https://travis-ci.org/lunarlang/lunar.svg?branch=master)](https://travis-ci.org/lunarlang/lunar)
[![Coverage Status](https://coveralls.io/repos/github/lunarlang/lunar/badge.svg?branch=master)](https://coveralls.io/github/lunarlang/lunar?branch=master)

The Lua 5.1 superset programming language.

## Goals: what we want
  - embeds most idioms into the language (default args, named varargs, classes, etc)
  - implements type checking and type inference
  - implements a language server for LSP features (intellisense, goto def, etc)
  - interoperate with Lua, both ways. Code written in Lunar should be as easy to use in Lua.

## Getting Started
Lunar is written for Lua 5.1, therefore you need the Lua 5.1 runtime. On some installs of Lua, you might not have `./?.lua` and `./?/init.lua` in your `LUA_PATH`. Configure your system environment variables and append `;./?.lua;./?/init.lua` into `LUA_PATH`.

### Prerequisites for development
You will need [luarocks][LuaRocks] (lua package manager), and [busted][Busted] (unit testing framework).
```
$ git clone https://github.com/lunarlang/lunar
$ luarocks install busted
$ cd ./lunar # the root folder, not the lunar source code folder.
```

To run tests and verify everything's in working order, just run `busted` with the root directory of this repository as the current working directory.
