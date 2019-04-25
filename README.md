<div align="center">
  <img src="https://i.imgur.com/8fH3GcD.png"/>

  # Lunar
  [![Build Status](https://travis-ci.org/lunarlang/lunar.svg?branch=master)](https://travis-ci.org/lunarlang/lunar)
  [![Coverage Status](https://coveralls.io/repos/github/lunarlang/lunar/badge.svg?branch=master)](https://coveralls.io/github/lunarlang/lunar?branch=master)
  [![Discord Server](https://discordapp.com/api/guilds/517093929770942474/embed.png)](https://discord.gg/CHFC3pS)

  The Lua 5.1 superset programming language.

  Check out the [language documentation and examples](https://github.com/lunarlang/evolution) which contains information about Lunar's syntax and semantics.

</div>

**THIS PROJECT IS NOW ABANDONED IN FAVOR OF ROBLOX'S TYPED LUA.** Maybe it will be picked up in the future again, but the main motivation drive is gone now.

## Goals: what we want
  - embeds most idioms into the language (default args, named varargs, classes, etc)
  - implements type checking and type inference
  - implements a language server for LSP features (intellisense, goto def, etc)
  - interoperate with Lua, both ways. Code written in Lunar should be as easy to use in Lua.

## Roadmap
These are the general idea of what we want to implement for Lunar. It does not cover everything in detail, and it's not strictly in any particular order.
  - Syntax
    - [x] Classes
    - [x] Self-assignment operators
    - [x] Lambda expressions
    - [ ] Import/export
    - [ ] Interfaces
    - [ ] Extension methods
  - Language Features (via Lunar's Compiler API)
    - [ ] Semantic highlighting
    - [ ] Static type checking
    - [ ] Intellisense
    - [ ] Static code analyzers
    - [ ] Code refactorings/rewriters
    - [ ] Linting with autofixes where possible.

## Getting Started
Lunar is written for Lua 5.1, therefore you need the Lua 5.1 runtime. On some installs of Lua, you might not have `./?.lua` and `./?/init.lua` in your `LUA_PATH`. Configure your system environment variables and append `;./?.lua;./?/init.lua` into `LUA_PATH`.

## Installing from Source
Currently this is required as we do not have precompiled binaries to install Lunar for you.

#### What you need
  - Git
  - Lua for Windows or Lua 5.1
  - LuaRocks *(included with Lua for Windows)*
  - LuaFileSystem *(included with Lua for Windows)*

  If you are working on Lunar itself, you need `busted`, which can be installed through `luarocks install busted`

#### Downloading the Source
From the command line, which is `Command Prompt` or `Powershell` for Windows, and `Terminal` for Linux.

  - `git clone https://github.com/lunarlang/lunar`
  - `cd ./lunar`

Alternatively, you can download the source as a zipped file. In the top right of this page, you can find a green button, click that and below that should be a `Download ZIP` button.

  - Extract the files from the downloaded .zip file.
  - For Linux, you should open a Terminal where the extracted files are located.

#### Installing
  - Linux
    - Run `chmod +x ./install.sh`
    - Run `sudo ./install.sh`
    - Test by running `lunarc`
  - Windows
    - Find the `install.bat` file and open it
    - Test by running `lunarc`
      - You may need to open a new Command Prompt or Powershell.

#### Reinstalling and Uninstalling
  We've included a way to reinstall and uninstall Lunar. Follow the [Installing](#installing) steps, and then you should be prompted to press R to reinstall, or U to uninstall.

  To update Lunar, you can use `git pull` from the downloaded git repository from when you originally installed Lunar, and then follow the [Installing](#installing) steps, using `R` to reinstall.

#### Setting up your project
  - Open your project in your editor of choice, though we recommend VSCode.
  - Ensure your source code is in a separate folder, typically named `src`
  - In the project folder, create a `.lunarconfig` file.
    - In Windows, the File Explorer will not allow you to create a file without a name. You must do this through an editor such as VSCode.
  - In your `.lunarconfig`, add this:
    - Do not use `local` in the configuration file.
```lua
include = { "src" }
out_dir = "out"
```
  - Once completed, save the file, and attempt running `lunarc` from the command line.
  - If you receive an issue that isn't listed in [Common issues](#common-issues), please create an issue and let us know what message you got. Alternatively, you can join our [Discord](https://discord.gg/CHFC3pS) server and ask in the `#help` channel.

#### Common issues
  - required dependency 'LuaFileSystem' was not found, install with 'luarocks install luafilesystem'
    - Lunar is unable to find LuaFileSystem, or you do not have it installed. Check your LUA_PATH environment variable to ensure it points to a directory that contains LuaFileSystem.
  - Could not find '.lunarconfig'
    - Ensure you are running `lunarc` from your projects directory, and ensure it contains a `.lunarconfig` file.
  - 'include' *or* 'out_dir' was not defined in '.lunarconfig'
    - Please check the structure of your `.lunarconfig` to ensure it is valid.
  - Syntax errors
    - These are typically caused by own code, however it is possible that it may be an issue with Lunar. If your code worked normally before, or it *should* work, please create an issue so we can track this.

If you did all of the above correctly, you should be able to compile your projects with `lunarc`.
