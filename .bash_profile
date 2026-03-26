# vim: ts=2 sts=2 sw=2 et foldmethod=marker foldmarker={{{,}}}
# always shfmt -i 2 this dealio

# {{{ ghostty stuff
GHOSTTY_SHELL_INTEGRATION_NO_CURSOR="1"
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

if [ -f /opt/homebrew/etc/bash_completion.d/ghostty ]; then
  builtin source /opt/homebrew/etc/bash_completion.d/ghostty
fi
# }}}

# {{{ PS1 && Linux network namespace stuff
netns_name() {
  ip netns identify $$ 2>/dev/null
}

if [ "$(uname -s)" = "Linux" ] && [ -n "$(netns_name)" ]; then
  PS1='(ns:$(netns_name)) \h:\W \$ '
elif [ "$(uname -s)" = "Darwin" ]; then
  PS1="$(scutil --get ComputerName):\W \$ "
else
  PS1='\h:\W \$ '
fi
# }}}

# {{{ globstar
# so i can recursive glob to find files e.g. echo src/**/App.java for a java src tree
# only works in bash 4.x and later, while mac still supplies crummy bash 3
if shopt 2>&1 | grep -q globstar; then
  shopt -s globstar
fi
# }}}

# {{{ extglob
# so i can do: !(vendor) or !(vendor)/ to expand to all files
# that are not vendor (including directories) or directories only.
if shopt 2>&1 | grep -q extglob; then
  shopt -s extglob
fi
# }}}

# {{{ createcd
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
# }}}

# {{{ prargs and prargsq
prargs() {
  OIFS="$IFS"
  IFS="$' \t'"
  printf "%b\n" "$0" "$@" | nl -v0
  IFS="$OIFS"
}

prargsq() {
  printf "%q\n" "$@" | nl
}
# }}}

# {{{ permanent history
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

alias phgrep='cat ~/.persistent_history|grep --color'
# }}}

# {{{ setupmac
setupmac() {
  # Prompt for sudo upfront so it doesn't interrupt the rest of the run
  echo "calling sudo upfront to pre-cache credentials"
  sudo -v

  # --- Dock ---
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 2.0
  defaults write com.apple.dock autohide-time-modifier -float 0.5

  if type dockutil >/dev/null 2>&1; then
    dockutil --remove all --no-restart
  else
    echo "dockutil not found — skipping dock entry removal"
  fi

  # --- Trackpad ---
  # Tap to click
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Full acceleration
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0

  # Bottom-right corner secondary click
  defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool false
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool false

  # Non-natural scroll
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # --- Finder ---
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # --- Appearance / Animations / Motion ---
  # Dark mode
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

  # Reduce Motion (Accessibility → Display)
  defaults write com.apple.universalaccess reduceMotion -bool true

  # Reduce Transparency (usually want this alongside reduce motion)
  defaults write com.apple.universalaccess reduceTransparency -bool true

  # Disable window open/close animations
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

  # --- Accessibility Zoom ---
  # Enable zoom
  defaults write com.apple.universalaccess closeViewZoomNewWindowEnabled -bool true

  # Use keyboard shortcuts to zoom (Command+Option+= / Command+Option+-)
  defaults write com.apple.universalaccess closeViewHotkeysEnabled -bool true

  # Smooth images while zoomed
  defaults write com.apple.universalaccess closeViewSmoothImages -bool true

  # Disable the click on desktop to show desktop
  defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

  # --- Lock Screen Message ---
  obscured_string="SWYgZm91bmQgcGxlYXNlIHJldHVybiB0byBOYXZlZW4gTmF0aGFuOiBmYWNlYm9vayB1c2VybmFtZSAtIG5hdmVlbi5uYXRoYW47IHBob25lIGFuZCB3aGF0c2FwcCBhbmQgc2lnbmFsICs2MS00MDMtODMxLTY2MDsgb3IgZW1haWwgbmF2ZWVuQGxhc3RuaW5qYS5uZXQK"

  echo 'calling sudo to set lockscreen message text'
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText \
    -string "$(base64 -d <<<$obscured_string)"

  # Restart affected services
  killall Dock
  killall Finder
  killall SystemUIServer
  killall cfprefsd

  # --- File associations ---
  if type duti >/dev/null 2>&1; then
    local video_types=(.avi .mkv .mp4 .mov .wmv .flv .webm .mpg .mpeg)
    for ext in "${video_types[@]}"; do
      duti -s org.videolan.vlc "$ext" all
    done
  else
    echo "duti not found — skipping file associations"
  fi

  # --- VLC ---
  mkdir -p ~/Library/Preferences/org.videolan.vlc/

  # avoiding heredoc because you can't do it with leading whitespace
  printf '%s\n' \
    "[macosx] # Mac OS X interface" \
    "macosx-interfacestyle=1" \
    "macosx-recentitems=0" \
    >~/Library/Preferences/org.videolan.vlc/vlcrc

  # --- Touch ID for sudo ---
  if ! grep -q 'pam_tid.so' /etc/pam.d/sudo; then
    echo "calling sudo to setup touch id for sudo..."
    sudo sed -i '' '1s/^/auth       sufficient     pam_tid.so\n/' /etc/pam.d/sudo
    echo "Touch ID enabled for sudo"
  fi
}
# }}}

# {{{ ls colours
export LS_COLORS='di=1;38;2;100;200;255:fi=0:ln=38;2;0;200;180:ex=38;2;100;220;100:or=38;2;220;80;80'

if [ "$(uname -s)" = "Darwin" ] && type gls >/dev/null 2>&1; then
  alias ls='gls --color=auto'
elif [ "$(uname -s)" = "Linux" ]; then
  alias ls='ls --color=auto'
fi
# }}}

# {{{ git aliases
alias lg='cd $(git rev-parse --show-toplevel)'
alias lge='git rev-parse --show-toplevel'
# }}}

# {{{ env vars and aliases
# gnu guys are off their rockers
# see: https://www.gnu.org/software/coreutils/quotes.html
export QUOTING_STYLE=literal

export GREP_COLOR='00;38;5;157'
export EDITOR=vim
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/sbin:$HOME/.local/bin:$HOME/.local/sbin:${GOPATH//://bin:}/bin
if [ "$(uname -s)" = Darwin ]; then
  export PATH=/Applications/Ghostty.app/Contents/MacOS:$PATH

  if [ -d "$HOME/Library/Android/sdk/platform-tools" ]; then
    PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
  fi

  if [ -d "$HOME/Library/Python" ]; then
    while read -r d; do
      PATH=$PATH:$HOME/Library/Python/$d/bin
    done < <(
      cd "$HOME/Library/Python" || exit
      printf -- "%s\n" * | sort -t "." -k1,1nr -k2,2nr
    )
  fi

  if [ "$(uname -p)" = arm -a -d /opt/homebrew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

export EDITOR=vim
if type nvim >/dev/null 2>&1; then
  alias vim='nvim'
  export EDITOR=nvim
fi

if type rg >/dev/null 2>&1; then
  alias ag='rg'
fi

export JQ_COLORS="1;33:0;39:0;39:0;39:0;32:1;39:1;39"
# }}}

# {{{ netstat
if [ "$(uname -s)" = "Darwin" ]; then
  netstat() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      command netstat -w "$@"
    else
      command netstat "$@"
    fi
  }
fi
# }}}

# {{{ keychain
if type keychain >/dev/null 2>&1 && ! grep -qE '^\s+IdentityAgent.*com.1password.*agent.sock' ~/.ssh/config; then
  keychain ~/.ssh/id*[!.][!p][!u][!b]
  # shellcheck source=/dev/null # this is a linter directive
  . ~/.keychain/"${HOSTNAME}"-sh
fi
# }}}

# {{{ zoxide
if type zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd j)"
fi
# }}}

# {{{ load bash_completion
if [ "$(uname -s)" != "Darwin" ]; then
  if [[ -r "/usr/share/bash-completion/bash_completion" ]]; then
    # shellcheck disable=SC1091
    . "/usr/share/bash-completion/bash_completion"
  elif [[ -r "/etc/profile.d/bash_completion.sh" ]]; then
    # shellcheck disable=SC1091
    . "/etc/profile.d/bash_completion.sh"
  elif [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    # shellcheck disable=SC1091
    . "/usr/local/etc/profile.d/bash_completion.sh"
  fi
else
  if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    # shellcheck disable=SC1091
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
  fi
fi
# }}}

# {{{ fzf bash
fzf_loaded=1

if [ -f /usr/share/fzf/key-bindings.bash ]; then
  # shellcheck source=/dev/null # this is a linter directive
  source /usr/share/fzf/key-bindings.bash
elif [ -f /opt/homebrew/Cellar/fzf/*/shell/key-bindings.bash ]; then
  # shellcheck source=/dev/null # this is a linter directive
  source /opt/homebrew/Cellar/fzf/*/shell/key-bindings.bash
elif [ -f ~/.fzf.bash ]; then
  # shellcheck source=/dev/null # this is a linter directive
  source ~/.fzf.bash
else
  fzf_loaded=''
fi

if [ x$fzf_loaded != x ]; then
  # remove keybinding seems necessary otherwise bash seems to cry
  bind -r "\C-t"
  bind '"\C-t": transpose-chars'
  export FZF_DEFAULT_OPTS='--height=60% --border --inline-info --prompt="🥑 "'
fi
# }}}

# {{{ cargo
if [ -d $HOME/.cargo ]; then
  source "$HOME/.cargo/env"
fi
# }}}
