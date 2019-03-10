<div align="center"><img src="https://i.imgur.com/8fH3GcD.png"/></div>

# Lunar
[![Build Status](https://travis-ci.org/lunarlang/lunar.svg?branch=master)](https://travis-ci.org/lunarlang/lunar)
[![Coverage Status](https://coveralls.io/repos/github/lunarlang/lunar/badge.svg?branch=master)](https://coveralls.io/github/lunarlang/lunar?branch=master)
[![Discord Server](https://discordapp.com/api/guilds/517093929770942474/embed.png)](https://discord.gg/CHFC3pS)

The Lua 5.1 superset programming language.

## Examples
Classes, the staple of object-oriented programming, is implemented in Lunar.
```lua
-- unfortunately no syntax highlighting for lunar yet, so we'll stick with lua
class Account
  constructor(name, balance)
    self.name = name
    self.balance = balance or 0
  end

  function deposit(credit)
    self.balance += credit
  end

  function withdraw(debit)
    self.balance -= debit
  end
end

local account = Account.new("Jeff Bezos", 500)
print(account.balance) --> 500
account:deposit(250)
print(account.balance) --> 750
account:withdraw(300)
print(account.balance) --> 450
```

Lunar adds 6 new operators: `..=`, `+=`, `-=`, `*=`, `/=`, and `^=`.
```lua
local message = "hello"
message ..= " world!"
print(message) --> "hello world!"

local a, b = 1, 2
a, b += 1, 2
print(a, b) --> 2, 4
```

Lunar also adds lambda expressions making it more convenient to create short and quick functions as well as big functions.
```lua
local divisible = |dividend, divisor| dividend % divisor == 0
local fizz = |n| do
  local message = ""

  if divisible(n, 3) then message ..= "Fizz" end
  if divisible(n, 5) then message ..= "Buzz" end
  if message == "" then message = n end

  return message
end

for i = 1, 100 do
  print(fizz(i))
end
```

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
    - Find the `install.ps1` file, right click on it, and click `Run with PowerShell`
      - We would normally recommend you run this similar to Linux, however there are strict rules about running unsigned Powershell scripts from a Powershell session.
    - In the command line, test your install by using `lunarc`
      - You may have to open a new window to update the PATH.

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
