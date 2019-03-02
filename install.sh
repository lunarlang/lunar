#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo "Try again as root"
  exit 1
fi

remove_lunar() {
  rm -rf /usr/lib/lunar
  rm /usr/local/bin/lunarc
}

if [ -f /usr/local/bin/lunarc ]; then
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

cp ./bin/lunarc /usr/local/bin/
mkdir /usr/lib/lunar
cp -r . /usr/lib/lunar/lunar
echo "Lunar has been installed in /usr/local/bin/lunarc"
