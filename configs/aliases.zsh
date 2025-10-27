# --------------------------------------------------------------------------- #
#                                  FUNCTIONS                                  #
# --------------------------------------------------------------------------- #

# Make and traverse into a new directory
# Reference: https://github.com/ohmyzsh/ohmyzsh/issues/1895
mcd() {
    mkdir "$@" && cd "$@" || return
}
compdef _mkdir mcd

# Clone new repo and move into it
gclonecd() {
    git clone "$1" && cd "$(basename "$1" .git)" || return
}

# Fetch all origin (remote) branches
branch_fetch() {
    git branch -r | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read -r remote; do 
        git branch --track "${remote#origin/}" "$remote"
    done
    git fetch --all
    git pull --all
}
alias fetchall=branch_fetch

# Find stuff in system directories
# Usage: findsys /var hosts
findSystemStuff() {
    local findDir="$1"
    local findFSO="$2"
    sudo find "$findDir" -name 'Library' -prune , -name 'System' -prune , \
        -name 'dev' -prune , -name 'var' -prune , -name "$findFSO"
}
alias findsys=findSystemStuff

# Find stuff in home directory
# Usage: findmy d Downloads
findMyStuff() {
    local findType="$1"
    local findFSO="$2"
    find "$HOME" -type "$findType" -name 'Library' -prune , \
        -name '.Trash' -prune , -name "$findFSO"
}
alias findmy=findMyStuff
