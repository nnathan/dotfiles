# always shfmt -i 2 this dealio

# i don't need to see my username
PS1='\h:\W \$ '

# so i can recursive glob to find files e.g. echo src/**/App.java for a java src tree
# only works in bash 4.x and later, while mac still supplies crummy bash 3
if shopt 2>&1 | grep -q globstar; then
  shopt -s globstar
fi

# so i can do: !(vendor) or !(vendor)/ to expand to all files
# that are not vendor (including directories) or directories only.
if shopt 2>&1 | grep -q extglob; then
  shopt -s extglob
fi

createcd() {
  mkdir -p wav
  for file in *.mp3; do lame --decode "$file" "wav/${file%.mp3}.wav"; done
  cd wav && {
    echo CD_DA
    for f in *.wav; do
      echo "TRACK AUDIO"
      echo "FILE \"$f\" 0"
    done
  } >toc
}

prargs() {
  OIFS="$IFS"
  IFS="$' \t'"
  printf "%b\n" "$0" "$@" | nl -v0
  IFS="$OIFS"
}

prargsq() {
  printf "%q\n" "$@" | nl
}

# start permanent history
# https://eli.thegreenplace.net/2013/06/11/keeping-persistent-history-in-bash
export HISTTIMEFORMAT="%F %T  "

log_bash_persistent_history() {
  local rc=$?
  [[ $(history 1) =~ ^\ *[0-9]+\ +([^\ ]+\ [^\ ]+)\ +(.*)$ ]]
  local date_part="${BASH_REMATCH[1]}"
  local command_part="${BASH_REMATCH[2]}"
  if [ "$command_part" != "$PERSISTENT_HISTORY_LAST" ]; then
    echo $date_part "|" "$command_part" >>~/.persistent_history
    export PERSISTENT_HISTORY_LAST="$command_part"
  fi
}

run_on_prompt_command() {
  log_bash_persistent_history
}

if [ "$PROMPT_COMMAND" = "" ]; then
  PROMPT_COMMAND="run_on_prompt_command"
else
  PROMPT_COMMAND="run_on_prompt_command; ""$PROMPT_COMMAND"
fi
# end permanent history

alias lg='cd $(git rev-parse --show-toplevel)'
alias lge='git rev-parse --show-toplevel'

# gnu guys are off their rockers
# see: https://www.gnu.org/software/coreutils/quotes.html
export QUOTING_STYLE=literal

export GREP_COLOR='00;38;5;157'
export EDITOR=vim
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/sbin:$HOME/.local/bin:$HOME/.local/sbin:${GOPATH//://bin:}/bin
if [ "$(uname -s)" = Darwin ]; then
  if [ -d "$HOME/Library/Android/sdk/platform-tools" ]
  then
    PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
  fi

  if [ -d "$HOME/Library/Python" ]
  then
    while read -r d
    do
      PATH=$PATH:$HOME/Library/Python/$d/bin
    done < <( cd "$HOME/Library/Python" || exit; printf -- "%s\n" * | sort -t "." -k1,1nr -k2,2nr )
  fi

  if [ "$(uname -p)" = arm -a -d /opt/homebrew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
alias phgrep='cat ~/.persistent_history|grep --color'

export EDITOR=vim
if type nvim >/dev/null 2>&1; then
  alias vim='nvim'
  export EDITOR=nvim
fi

if type rg >/dev/null 2>&1; then
  alias ag='rg'
fi

export JQ_COLORS="1;33:0;39:0;39:0;39:0;32:1;39:1;39"

if type keychain >/dev/null 2>&1; then
  keychain ~/.ssh/id*[!.][!p][!u][!b]
  # shellcheck source=/dev/null # this is a linter directive
  . ~/.keychain/"${HOSTNAME}"-sh
fi

if type zoxide >/dev/null 2>&1
then
  eval "$(zoxide init bash --cmd j)"
fi

if [[ -r "/etc/profile.d/bash_completion.sh" ]]
then
  # shellcheck disable=SC1091
  . "/etc/profile.d/bash_completion.sh"
elif [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]
then
  # shellcheck disable=SC1091
  . "/usr/local/etc/profile.d/bash_completion.sh"
elif [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]
then
  # shellcheck disable=SC1091
  . "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

# bash completion 2 only - for some reason completion breaks when using 2.
#export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

if [ -f ~/.fzf.bash ]; then
  # shellcheck source=/dev/null # this is a linter directive
  source ~/.fzf.bash
  # remove keybinding seems necessary otherwise bash seems to cry
  bind -r "\C-t"
  bind '"\C-t": transpose-chars'
  export FZF_DEFAULT_OPTS='--height=60% --border --inline-info --prompt="🥑 "'
fi

if shopt -q login_shell; then
    [ -d ~/.fortune ] && fortune ~/.fortune
fi
