echo "! Starting to compile Lunar..."

# Versions
LUA_VER=5.1.5
LFS_VER=1.7.0-2

# Directories
LUA_DIR=lua-$LUA_VER
LFS_DIR=luafilesystem-$LFS_VER/luafilesystem
LNR_DIR=lunar

# Compiler Options
LIN_CC="gcc"
LIN_AR="ar rc"
LIN_RANLIB="ranlib"
LIN_STRIP="strip"

WIN_CC="i686-w64-mingw32-$LIN_CC"
WIN_AR="i686-w64-mingw32-$LIN_AR"
WIN_RANLIB="i686-w64-mingw32-$LIN_RANLIB"
WIN_STRIP="i686-w64-mingw32-$LIN_STRIP"

CUR_CC=""
CUR_AR=""
CUR_RANLIB=""
CUR_STRIP=""

# Fetch Lua
if [ ! -d $LUA_DIR ]; then
  echo "+ Downloading Lua $LUA_VER"
  curl "https://www.lua.org/ftp/$LUA_DIR.tar.gz" | tar xz
fi

# Fetch LFS
if [ ! -d $LFS_DIR ]; then
  echo "+ Downloading LFS $LFS_VER"
  luarocks unpack luafilesystem $LFS_VER
fi

# Compile Lunar
if [ ! -d ../dist ]; then
  echo "+ Compiling Lunar"
  cd ..
  LUA_PATH="$LUA_PATH;./lib/?.lua;./lib/?/init.lua" lua ./lib/lunar/lunarc/init.lua
  cd build
fi

# Fetch Lunar
if [ ! -d $LNR_DIR ]; then
  echo "+ Fetching Lunar"
  cp -r ../dist/lunar .
fi

# Functions
set_compiler() {
  P=$1;
  if [ $P -eq 1 ]; then
    echo "+ Compiling for Windows x86"
    CUR_CC=$WIN_CC
    CUR_AR=$WIN_AR
    CUR_RANLIB=$WIN_RANLIB
    CUR_STRIP=$WIN_STRIP
  else
    echo "+ Compiling for Linux x64"
    CUR_CC=$LIN_CC
    CUR_AR=$LIN_AR
    CUR_RANLIB=$LIN_RANLIB
    CUR_STRIP=$LIN_STRIP
  fi
}

compile_lib() {
  NAME=$1;DIR=$2;O_FILES="";
  shift;shift;
  for f in $DIR/*.c; do
    $CUR_CC -O2 $@ -c -o ${f%.c}.o $f
    O_FILES="$O_FILES ${f%.c}.o"
  done
  $CUR_AR $NAME $O_FILES
  $CUR_RANLIB $NAME
}

# Linux
set_compiler 0
compile_lib liblua.a $LUA_DIR/src "-DLUA_USE_POSIX"
compile_lib lfs.a $LFS_DIR/src "-DLUA_USE_POSIX -I$LUA_DIR/src"
CC="" luastatic bin/lunarc.lua lunar/*/*.lua lunar/*/*/*.lua liblua.a lfs.a
$CUR_CC -static -Os bin/lunarc.lua.c liblua.a lfs.a -I$LUA_DIR/src -lm -lpthread -o bin/lunarc
$CUR_STRIP bin/lunarc

# Windows
set_compiler 1
compile_lib liblua.a $LUA_DIR/src
compile_lib lfs.a $LFS_DIR/src "-I$LUA_DIR/src"
CC="" luastatic bin/lunarc.lua lunar/*/*.lua lunar/*/*/*.lua liblua.a lfs.a
$CUR_CC -Os bin/lunarc.lua.c liblua.a lfs.a -I$LUA_DIR/src -lm -o bin/lunarc.exe
$CUR_STRIP bin/lunarc.exe

# Finished
echo "! Successfully compiled Lunar"
echo "# Linux x64: build/bin/lunarc"
echo "# Windows x86: build/bin/lunarc.exe"
