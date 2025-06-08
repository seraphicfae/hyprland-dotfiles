# Set Zsh config directory
export ZDOTDIR="$HOME/.config/zsh"

# History settings
HISTFILE="$ZDOTDIR/history"
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history
setopt append_history
setopt inc_append_history

# Plugins location
ZSH_PLUGINS="$ZDOTDIR/plugins"

# Source plugins
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
fpath+="$ZSH_PLUGINS/zsh-completions/src"

# Init completions
autoload -Uz compinit
compinit

# Keybinds
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Ctrl+F to jump to recent dirs
fzf-smart-cd-widget() {
  local dir
  local zoxide_list fd_list combined
  zoxide_list=$(zoxide query -ls 2>/dev/null)
  fd_list=$(fd --type d --max-depth 3 --hidden --exclude .git . "$HOME" 2>/dev/null)
  zoxide_paths=$(echo "$zoxide_list" | awk '{ print $2 }')
  fd_only=$(comm -23 <(echo "$fd_list" | sort) <(echo "$zoxide_paths" | sort))
  combined=$(printf "%s\n%s" "$zoxide_paths" "$fd_only")
  dir=$(echo "$combined" | fzf --height=40% --reverse --border --prompt="📁 Jump to dir: ")

  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi

  zle reset-prompt
}
zle -N fzf-smart-cd-widget
bindkey '^F' fzf-smart-cd-widget

# Evals
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"