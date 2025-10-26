#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
#sudo rm -rf /usr/local/Homebrew/
#sudo rm -rf /usr/local/var/homebrew
sudo rm -rf /opt/homebrew

# zero-out .profile
cat /dev/null > ~/.zprofile
