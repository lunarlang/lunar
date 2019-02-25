<div align="center"><img src="https://i.imgur.com/xVujd8N.png"/></div>

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

## Getting Started
Lunar is written for Lua 5.1, therefore you need the Lua 5.1 runtime. On some installs of Lua, you might not have `./?.lua` and `./?/init.lua` in your `LUA_PATH`. Configure your system environment variables and append `;./?.lua;./?/init.lua` into `LUA_PATH`.

### Prerequisites for development
You will need [luarocks](https://luarocks.org/) (lua package manager), and [busted](http://olivinelabs.com/busted/) (unit testing framework).
```
$ git clone https://github.com/lunarlang/lunar
$ luarocks install busted
$ cd ./lunar # the root folder, not the lunar source code folder.
```

To run tests and verify everything's in working order, just run `busted` with the root directory of this repository as the current working directory.
