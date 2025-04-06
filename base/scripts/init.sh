#!/bin/bash

cd $HOME

#sdkman
mkdir -p /tmp/sdkman
cd /tmp/sdkman
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
sed -i 's/sdkman_auto_env=false/sdkman_auto_env=true/g' $HOME/.sdkman/etc/config

#maven
sdk install maven

#nvm
mkdir -p /tmp/nvm && cd /tmp/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source $HOME/.bashrc
nvm install --latest-npm
nvm alias default $(node --version)
npm --version
