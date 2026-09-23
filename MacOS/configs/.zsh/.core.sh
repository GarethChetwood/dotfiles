export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

# Source aliases
alias reSource="source ~/.zshrc"
alias editSource="vim $ZSH_CONFIG_DIR/.core.sh"
alias editPlSource="vim ~/.p10k.zsh"

# Directories
alias ll='ls -lG'
alias gohome="cd $HOME"
alias ~="gohome"
alias ..="cd ../"
alias ...="cd ../../"

# Sounds
alias chime="afplay /System/Library/Sounds/Glass.aiff"
alias bonk="afplay /System/Library/Sounds/Submarine.aiff"

# Neovim
alias vim="nvim"
alias vi="nvim"

# Terminal prompt
source $ZSH_CONFIG_DIR/.p10kinit.sh

# Path
source $ZSH_CONFIG_DIR/.path.sh

# Git aliases
source $ZSH_CONFIG_DIR/.git.sh

# typescript/javascript stuff
source $ZSH_CONFIG_DIR/.typescript.sh

# Chetwood apps
source $ZSH_CONFIG_DIR/.cwapps.sh

# Mise (pnpm)
eval "$(/opt/homebrew/bin/mise activate zsh)"
