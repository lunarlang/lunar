#!/bin/bash

CMD_TARGET_DIR="/usr/local/bin"
LIB_TARGET_DIR="/usr/local/lib/lunar"

if [ $EUID -ne 0 ]; then
  echo "Try again as root"
  exit 1
fi

remove_lunar() {
  rm -rf $LIB_TARGET_DIR
  rm $CMD_TARGET_DIR/lunarc
}

if [ -f $CMD_TARGET_DIR/lunarc ]; then
  read -r -p "Would you like to reinstall or uninstall? [R/U] " response

  if [[ "$response" =~ ^([Uu])+$ ]]; then
    echo "Uninstalling Lunar..."
    remove_lunar;
    exit 1
  else
    echo "Preparing Lunar for reinstall..."
    remove_lunar;
  fi
fi

cp ./bin/lunarc $CMD_TARGET_DIR
chmod +x $CMD_TARGET_DIR/lunarc
mkdir -p $LIB_TARGET_DIR/lunar
cp -r ./dist/lunar $LIB_TARGET_DIR
echo "Lunar has been installed."
