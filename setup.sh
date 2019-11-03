#!/bin/bash

sh ~/dotfiles/dotfilesLink.sh
sh ~/dotfiles/homebrew.install.sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" # install oh-my-zsh

brew bundle
