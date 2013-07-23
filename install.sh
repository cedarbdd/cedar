#!/bin/sh

echo "Installing Cedar"
rm -rf ~/.cedar > /dev/null

echo "Cloning Cedar repo"
git clone git@github.com:pivotal/cedar ~/.cedar > /dev/null 2>&1
rc=$?
if [[ $rc != 0 ]] ; then
    echo "Unable to clone Cedar GitHub repo"
    exit $rc
fi
cd ~/.cedar > /dev/null

echo "Initializing Cedar submodules"
git submodule update --init --recursive > /dev/null 2>&1
rc=$?
if [[ $rc != 0 ]] ; then
    echo "Unable to initialize Cedar Git submodules"
    exit $rc
fi

echo "Installing Cedar snippets and templates"
./installCodeSnippetsAndTemplates > /dev/null 2>&1
rc=$?
if [[ $rc != 0 ]] ; then
    echo "Unable to install Cedar snippets and templates"
    exit $rc
fi

echo "Cedar installed to ~/.cedar"
