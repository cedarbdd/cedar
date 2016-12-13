#!/bin/bash

cd cedar

[[ `which rbenv` ]] && eval "$(rbenv init -)"
rbenv install -s 2.2.3
rbenv rehash
rbenv local 2.2.3
gem install bundler
bundle

echo Running tests against SDK Version: ${CEDAR_SDK_RUNTIME_VERSION}
rake ci
