#!/bin/bash

INSTALL_UUID=$(uuidgen)

log() {
  printf "%b\n" "$*"
}

fail() {
  log "\nERROR: $*\n"
  log_event "Install Error" error "${*}"
  exit 1
}

usage() {
  log "$0 [--head] [--version]"
  log ""
  log "Unless otherwise specified, the latest release of Cedar will be installed"
  log ""
  log "Options:"
  log "  --head   Gets the latest master revision of Cedar from github.com/pivotal/cedar."
  log "  --version version_tag           Gets the specified version from the version tag."
}

switch_to_tag() {
  # Defaults to latest version if not given
  VERSION_TAG="$1"
  [ "$VERSION_TAG" ] || VERSION_TAG=$(git for-each-ref refs/tags --sort=-refname --format="%(refname:short)"  | grep v\\?\\d\\+\\.\\d\\+\\.\\d\\+ | ruby -e 'puts STDIN.read.split("\n").sort { |a,b| a.gsub("v", "").split(".").map(&:to_i) <=> b.gsub("v", "").split(".").map(&:to_i) }.last')
  git checkout "$VERSION_TAG" &>/dev/null || fail "Unable to find tag for version $VERSION_TAG"
}

log_event() {
  TOKEN=6bcfa72d98e6f7af1d647acfcd663051
  EVENT=$1
  PROPERTY_NAME=$2
  PROPERTY_VALUE=$3
  if [[ -n ${PROPERTY_NAME} ]] ; then
    PAYLOAD=$(echo '{"event": "'${EVENT}'", "properties": { "distinct_id":"'${INSTALL_UUID}'", "'${PROPERTY_NAME}'":"'${PROPERTY_VALUE}'", "token": "'${TOKEN}'" } }' | base64)
  else
    PAYLOAD=$(echo '{"event": "'${EVENT}'", "properties": { "distinct_id":"'${INSTALL_UUID}'", "token": "'${TOKEN}'" } }' | base64)
  fi
  curl 'https://api.mixpanel.com/track/?data='${PAYLOAD} > /dev/null 2>&1
}

while (($# > 0))
do
  TOKEN="$1"
  case "$TOKEN" in
    --head|--HEAD|head|HEAD)
      GET_HEAD=1
      shift
      ;;
    -version|--version)
      VERSION_TAG="v${2#v}"
      shift 2
	    ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$(which git)" ]] ; then
  echo "Unable to find git.  Have you installed Xcode as well as command line tools?"
  echo "You can install them from Xcode's Preferences, in the Downloads pane."
  fail "Could not find git; installation aborted."
fi

if [[ $GET_HEAD == 1 ]] ; then
  echo "Installing Cedar HEAD from master"
elif [ "$VERSION_TAG" ] ; then
  echo "Installing Cedar version ${VERSION_TAG}"
else
  echo "Installing latest Cedar release"
fi
rm -rf ~/.cedar > /dev/null

echo "Cloning Cedar repo to ~/.cedar"
git clone https://github.com/pivotal/cedar.git ~/.cedar > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    fail "Unable to clone Cedar GitHub repo"
fi
cd ~/.cedar > /dev/null

if [[ $GET_HEAD == 1 ]] ; then
  VERSION_TAG=$(git rev-parse HEAD)
  log_event "Install Script Run" version HEAD
else
  switch_to_tag "$VERSION_TAG"
  log_event "Install Script Run" version "$VERSION_TAG"
fi

echo "Installing Cedar snippets and templates"
./installCodeSnippetsAndTemplates > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    fail "Unable to install Cedar snippets and templates"
fi

echo "Cedar version $VERSION_TAG installed to ~/Library"
log_event "Successful Install"

