#!/bin/sh

rm -f nvim.tar
tar -cf nvim.tar --exclude="ft" --exclude=".git" *
echo "* Created nvim.tar"

echo
echo "* Install by running"
echo "    rmdir ~/.config/nvim"
echo "    tar -xf nvim.tar -C ~/.config/nvim"
