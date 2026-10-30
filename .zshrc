# Import Pywal dynamic terminal colors
(cat ~/.cache/wal/sequences &)

# Lines added by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
export XCURSOR_THEME="Bibata-Modern-Ice"
export XCURSOR_SIZE=24

# Plugins (Arch official package paths)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Wrapper to reset terminal attributes and restore Pywal colors after nano exits
nano() {
    command nano "$@"
    printf '\e[0m'
    # Re-apply pywal sequences if pywal is active
    [ -f "$HOME/.cache/wal/sequences" ] && cat "$HOME/.cache/wal/sequences"
}

# Tab completion menu styling
autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Starship Prompt
eval "$(starship init zsh)"

# --- Standard Key Navigation ---
bindkey "^[[H" beginning-of-line       # Home
bindkey "^[[F" end-of-line             # End
bindkey "^[[3~" delete-char            # Delete
bindkey "^[[5~" up-line-or-history     # Page Up
bindkey "^[[6~" down-line-or-history   # Page Down

# --- Arrow Key Word Jumping (Ctrl) ---
bindkey "^[[1;5C" forward-word         # Ctrl + Right Arrow
bindkey "^[[1;5D" backward-word        # Ctrl + Left Arrow
bindkey "^[[1;5H" beginning-of-line    # Ctrl + Home
bindkey "^[[1;5F" end-of-line          # Ctrl + End

# --- Arrow Key Word Jumping (Alt) ---
bindkey "^[[1;3C" forward-word         # Alt + Right Arrow
bindkey "^[[1;3D" backward-word        # Alt + Left Arrow

# --- Word Deletion ---
bindkey "^[[3;5~" kill-word            # Ctrl + Delete (Delete word forward)
bindkey "^H" backward-kill-word        # Ctrl + Backspace (Delete word backward)

# --- Tab Completion ---
bindkey "^[[Z" reverse-menu-complete   # Shift + Tab (Cycle backwards in menu)

# --- History Search (Up/Down Arrows) ---
# This makes the Up/Down arrows search history based on what you already typed
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up Arrow
bindkey "^[[B" down-line-or-beginning-search # Down Arrow%  
