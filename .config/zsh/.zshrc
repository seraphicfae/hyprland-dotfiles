# ─── Paths ──────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── Plugin Manager ─────────────────────────────────────
source "${HOME}/.config/zsh/antidote/antidote.zsh"
antidote load "${HOME}/.config/zsh/.zsh_plugins.txt"

# ─── Zsh Options ────────────────────────────────────────
autoload -Uz compinit && compinit
setopt autocd
setopt prompt_subst
setopt correct
setopt hist_ignore_dups
setopt share_history
setopt menucomplete

# ─── History ────────────────────────────────────────────
HISTFILE="${HOME}/.config/zsh/zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

# ─── Widgets ────────────────────────────────────────────
if [[ -o interactive ]]; then
  fzf-cd() {
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

  zle -N fzf-cd
  bindkey '^F' fzf-cd
fi

# ─── Evals ────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ─── Aliases ────────────────────────────────────
alias fastfetch=' clear && fastfetch'
alias vs='vscodium'