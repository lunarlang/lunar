# Makefile for (cross)compiling lunarc binaries.
# Do not use directly, run ./scripts/build-binaries.sh instead.
# Credit to lunarc (https://github.com/mpeterv/lunarc/blob/master/build/Makefile)

LUA_VERSION= 5.1.5
LFS_VERSION= 1.7.0-2
ARGPARSE_VERSION= 0.6.0-1

LUA_DIR= lua-$(LUA_VERSION)
LFS_DIR= luafilesystem-$(LFS_VERSION)/luafilesystem
ARGPARSE_DIR= argparse-$(ARGPARSE_VERSION)/argparse

BASE_CC= gcc
BASE_AR= ar rc
BASE_RANLIB= ranlib
BASE_STRIP= strip

CROSS=
CC= $(CROSS)$(BASE_CC)
CFLAGS= -O2 -Wall -Wextra
AR= $(CROSS)$(BASE_AR)
RANLIB= $(CROSS)$(BASE_RANLIB)
STRIP= $(CROSS)$(BASE_STRIP)

SUFFIX=
TARGET= bin/lunarc$(SUFFIX)

LUA_O= $(patsubst %.c,%.o,$(filter-out $(addprefix $(LUA_DIR)/src/,lua.c luac.c print.c),$(wildcard $(LUA_DIR)/src/*.c)))
LUA_A= $(LUA_DIR)/src/liblua.a
LFS_O= $(patsubst %.c,%.o,$(wildcard $(LFS_DIR)/src/*.c))
LFS_A= $(LFS_DIR)/src/lfs.a

default:	$(TARGET)

$(LUA_DIR):
	@echo
	@echo "=== Downloading Lua $(LUA_VERSION) ==="
	@echo
	curl "https://www.lua.org/ftp/$(LUA_DIR).tar.gz" | tar xz

$(LFS_DIR):
	@echo
	@echo "=== Downloading LuaFileSystem $(LFS_VERSION) ==="
	@echo
	luarocks unpack luafilesystem $(LFS_VERSION)

$(ARGPARSE_DIR):
	@echo
	@echo "=== Downloading argparse $(ARGPARSE_VERSION) ==="
	@echo
	luarocks unpack argparse $(ARGPARSE_VERSION)

fetch:	$(LUA_DIR) $(LFS_DIR) $(ARGPARSE_DIR)

$(LUA_O):	CFLAGS+= $(if $(LINUX),-DLUA_USE_POSIX)
$(LUA_A):	$(LUA_O)
$(LFS_O):	CFLAGS+= -I$(LUA_DIR)/src
$(LFS_A):	$(LFS_O)

%.a:
	$(AR) $@ $^
	$(RANLIB) $@

bin/lunarc.lua.c: $(LUA_A) $(LFS_A)
	cp $(LUA_A) .
	cp $(LFS_A) .
	cp $(ARGPARSE_DIR)/src/argparse.lua .
	cp -r ../dist/lunar .
	CC="" luastatic bin/lunarc.lua lunar/*/*.lua lunar/*/*/*.lua argparse.lua liblua.a lfs.a

$(TARGET):	bin/lunarc.lua.c
	$(CC) $(if $(LINUX),-static) -Os $< $(LUA_A) $(LFS_A) -I$(LUA_DIR)/src -lm $(if $(LINUX),-lpthread) -o $@
	$(STRIP) $@

clean:
	rm -f $(TARGET) bin/lunarc.lua.c
	rm -f $(LUA_O) $(LUA_A) $(LFS_O) $(LFS_A)
	rm -f argparse.lua liblua.a lfs.a
	rm -rf lunarc

.PHONY: default fetch clean
