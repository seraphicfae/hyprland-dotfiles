# Path to Oh My Zsh
export ZSH="$HOME/.config/zsh/.oh-my-zsh"

# Starship prompt
eval "$(starship init zsh)"

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Show dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Set history file path in config directory
export HISTFILE="$HOME/.config/zsh/.zsh_history"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Custom Aliases
alias zshconfig="code ~/.config/zsh/.zshrc"
alias ohmyzsh="code ~/.config/zsh/.oh-my-zsh"