# Contributing to Lunar
First of all, thanks for your interest in contributing to Lunar! If you have any questions, head on over to our [Discord](https://discord.gg/CHFC3pS).

## Development
Lunar is written for Lua 5.1, therefore you need the Lua 5.1 runtime. On some installs of Lua, you might not have `./?.lua` and `./?/init.lua` in your `LUA_PATH`. Configure your system environment variables and append `;./?.lua;./?/init.lua` into `LUA_PATH`.

### Structure
Lunar is essentially a collection of modules, split up based on its responsibility.

  - `lunar/ast`: Representation of your program once compiled.
  - `lunar/compiler/lexical`: Lexical analysis that converts a string to a stream of tokens.
  - `lunar/compiler/syntax`: Parses the stream of tokens and returns an AST.
  - `lunar/compiler/semantic`: Performs semantic analysis, such as whether your `break` statement was used legally, and to bind symbols found elsewhere in your program.
  - `lunar/compiler/codegen`: Generates semantically-equivalent Lua code.
  - `lunar/lunarc`: A compiler intended to be ran locally on your machine wrapping Lunar's APIs.

### Prerequisites for development
We use `busted` for our unit testing framework, therefore you will need [luarocks](https://luarocks.org/) (lua package manager), and [busted](http://olivinelabs.com/busted/) (unit testing framework). You may also need [lfs](https://keplerproject.github.io/luafilesystem/) (decent file system manipulation).
```
$ git clone https://github.com/lunarlang/lunar
$ luarocks install busted
$ luarocks install luafilesystem
$ cd ./lunar # the root folder, not the lunar source code folder.
```

To run tests and verify everything's in working order, just run `busted` with the root directory of this repository as the current working directory.

### Common courtesy
When submitting a bug fix or adding new features, we want to make sure this does not break in the future. So please add test cases in `spec` folder so that we can make sure it continues to work.

Here's what you can do to increase confidence in your tests:

  1. Make sure it fails, and verify that your code under test is consistent with the reproduction steps.
  2. Fix the bug, repeat until this test case passes without any changes directly to it. No cheating!
  3. Personally test the bug with the fix yourself. If it still exists, then your code under test does not correspond with the reproduction step.

### Project style
We prefer consistent style so we're not distracted when we're trying to debug our compiler.

 - Every names should be in `snake_case`, except for classes whose name should be in `PascalCase`.
 - All files and directories should be in `snake_case`, no exceptions.
