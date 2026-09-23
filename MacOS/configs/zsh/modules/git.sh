# Append git-scripts to $PATH -- https://github.com/jwiegley/git-scripts
# path_append "$HOME/.git-scripts"

export GIT_EDITOR='nvim'

# Git aliases
alias lg="lazygit"
alias gg="lg"
alias gst="git status"
alias gco="git checkout"
alias gfa="git fetch --all"
alias gl="git pull --ff-only"
alias gp="git push origin HEAD"
alias ga="git add"
alias gap="git add -p"
alias gcm="git commit -m"
alias gcam="git commit --amend"
alias gcamn="git commit --amend --no-edit"
alias glg="git log"
alias glgg="git log --graph"
alias gstsz="git_status_size"
alias gdhh="git diff HEAD^ HEAD"
alias grh="git reset --hard"

git_status_size(){
    git status --porcelain | awk '{print $2}' | xargs ls -hl | sort -r -h | awk '{print $5 "\t" $9}'
}
