zmodload zsh/zprof
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/keisuke/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# init starship
eval "$(starship init zsh)"

# cdr, add-zsh-hook を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# cdr の設定
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
# 自作シェルスクリプトのalias
alias sc='sh ~/shell-scripts/search_code.sh'
alias gcre='sh ~/shell-scripts/gcre.sh'

# peco settings
# 過去に実行したコマンドを選択。ctrl-rにバインド
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# search a destination from cdr list
function peco-get-destination-from-cdr() {
  cdr -l | \
  sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
  peco --query "$LBUFFER"
}

### search a destination from cdr list and cd the destination
function peco-cdr() {
  local destination="$(peco-get-destination-from-cdr)"
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N peco-cdr
bindkey '^u' peco-cdr

# pecoでローカルブランチを簡単切り替え
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
# dockerコンテナに入る
alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'

# ssh by peco
function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
alias pssh='peco-ssh'
# bindkey '^\' peco-ssh

# fzf preview command alias
alias fpreview="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# 失敗したコマンドはzsh_historyに残さない
__record_command() {
  typeset -g _LASTCMD=${1%%$'\n'}
  return 1
}
# comment out temporarily
# zshaddhistory_functions+=(__record_command)

__update_history() {
  local last_status="$?"

  # hist_ignore_space
  if [[ ! -n ${_LASTCMD%% *} ]]; then
    return
  fi

  # hist_reduce_blanks
  local cmd_reduce_blanks=$(echo ${_LASTCMD} | tr -s ' ')

  # Record the commands that have succeeded
  if [[ ${last_status} == 0 ]]; then
    print -sr -- "${cmd_reduce_blanks}"
  fi
}
# comment out temporarily
# precmd_functions+=(__update_history)

# git settings
## git branch切り替えのエイリアス
alias gcolb='git checkout lb'

## add & commit in one command
gagc() {
  git add ./ | git commit -m $*
}

# zsh settings
HISTSIZE=5000               # ヒストリに保存するコマンド数
SAVEHIST=5000               # ヒストリファイルに保存するコマンド数
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
# setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt share_history         # コマンド履歴ファイルを共有する
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録


# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias d='docker'
alias dc='docker compose'
alias b='bundle'
alias e='exec'
alias noti='terminal-notifier -message "コマンド完了"'
alias gplom='git pull origin master'
alias gplod='git pull origin develop'
alias ggpush='git push origin $(git_current_branch)'
alias hisl='history -l'
alias his='history'
alias gcm='git commit'
alias gbrcp='git branch --contains | cut -d " " -f 2 | pbcopy'

# finder
alias .='open .'

# vscode
alias code='code ./'

# my custom scripts
# settings of git commit message generator
alias gcmg='sh ~/dotfiles/scripts/git_commit_message_generator.sh'

# Ruby settings
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export LDFLAGS="-L$HOMEBREW_PREFIX/lib"

# Java
# export JAVA_HOME="/usr/bin/java"
# export JAVA_HOME="/usr/libexec/java_home -v 12"
# export JAVA_HOME="/usr/libexec/java_home"
# export PATH=$JAVA_HOME/bin:$PATH

# dotfiles
export PATH=$PATH:/Users/keisuke/dotfiles

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# go settings
export PATH="$HOME/.goenv/bin:$PATH"
eval "$(goenv init -)"
export GOPATH=/Users/keisuke/go  # GOPATHにすると決めた場所
export PATH=$GOPATH/bin:$PATH

# other settings
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# settings of node.js
# eval "$(nodenv init -)"
# export PATH="$HOME/.nodenv/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH="$HOME/node_modules:$PATH"

# settings of terraform
export PATH="$HOME/.tfenv/bin:$PATH" 

# android SDK
export ANDROID_SDK=/Users/keisuke/Library/Android/sdk
export PATH=/Users/keisuke/Library/Android/sdk/platform-tools:$PATH

# react-native settings Special case of Expo (CRNA). src: https://github.com/jhen0409/react-native-debugger/blob/master/docs/getting-started.md#launch-by-cli-or-react-native-packager-macos-only
export REACT_DEBUGGER="unset ELECTRON_RUN_AS_NODE && open -g 'rndebugger://set-debugger-loc?port=19001' ||"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export PATH="$PATH:/usr/local/Cellar/binutils/2.34/bin/gobjdump"

# Haskell
export PATH="/usr/local/bin/stack:$PATH"
[ -f "/Users/keisuke/.ghcup/env" ] && source "/Users/keisuke/.ghcup/env" # ghcup-env


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH="/Users/keisuke/.local/bin:$PATH"

export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

# TODO: remove later
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
#         . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
#     else
#         export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

# for tfenv settings (https://github.com/tfutils/tfenv?tab=readme-ov-file#environment-variables)
TFENV_ARCH=arm64

# zprof # uncomment to see the detailed startup time

# Android Settings (https://docs.expo.dev/workflow/android-studio-emulator/)
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools