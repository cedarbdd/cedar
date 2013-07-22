#!/bin/sh

echo "Installing Cedar..."
rm -rf ~/.cedar > /dev/null 2>&1
git clone git@github.com:pivotal/cedar ~/.cedar > /dev/null 2>&1
cd ~/.cedar > /dev/null 2>&1
git submodule update --init --recursive > /dev/null 2>&1
./installCodeSnippetsAndTemplates > /dev/null 2>&1
echo "Cedar installed to ~/.cedar"
