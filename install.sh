#!/bin/sh

log() { printf "%b\n" "$*"; }

fail() { log "\nERROR: $*\n" ; exit 1 ; }

usage() {
  log "$0 [--head]"
  log ""
  log "Unless otherwise specified, the latest release of Cedar will be installed"
  log ""
  log "Options:"
  log "  --head   Gets the latest master revision of Cedar from github.com/pivotal/cedar"
}

switch_to_latest_tag() {
  LATEST_VERSION_TAG=$(git for-each-ref refs/tags --sort=-refname --format="%(refname:short)"  | grep v\\?\\d\\.\\d\\.\\d | head -n1)

  git checkout ${LATEST_VERSION_TAG} > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    fail "Unable to find tag for version ${LATEST_VERSION_TAG}"
  fi
}

while (($# > 0))
do
  token="$1"
  shift
  case "$token" in
    --head|--HEAD|head|HEAD)
      GET_HEAD=1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done


if [[ $GET_HEAD == 1 ]] ; then
  echo "Installing Cedar HEAD from master"
else
  echo "Installing latest Cedar release"
fi
rm -rf ~/.cedar > /dev/null

echo "Cloning Cedar repo to ~/.cedar"
git clone git@github.com:pivotal/cedar ~/.cedar > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    fail "Unable to clone Cedar GitHub repo"
fi
cd ~/.cedar > /dev/null

if [[ $GET_HEAD == 1 ]] ; then
  LATEST_VERSION_TAG=$(git rev-parse HEAD)
else
  switch_to_latest_tag
fi

echo "Initializing Cedar submodules"
git submodule update --init --recursive > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    fail "Unable to initialize Cedar Git submodules"
fi

echo "Installing Cedar snippets and templates"
./installCodeSnippetsAndTemplates > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    fail "Unable to install Cedar snippets and templates"
fi

echo "Cedar version ${LATEST_VERSION_TAG} installed to ~/Library"

