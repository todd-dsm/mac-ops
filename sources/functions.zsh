# ~/.oh-my-zsh/custom/functions.zsh
#-------------------------------------------------------------------------------
# Make and traverse into a new directory
# FIX: https://github.com/ohmyzsh/ohmyzsh/issues/1895
mcd () {
    [[ -n "$1" ]] && mkdir -p "$1" && cd "$1" || true
}

compdef _mkdir mcd

#-------------------------------------------------------------------------------
# FIXME
# Easily find stuff on the system; EX: findsys /var hosts
function findSystemStuff()   {
    set -x
    findDir="$1"
    findFSO="$2"
    sudo find "$findDir" -name 'cores' -prune , -name 'dev' -prune , -name 'net' -prune , -name 'Library' -prune , -name "$findFSO"
    set +x
}
alias findsys=findSystemStuff

#-------------------------------------------------------------------------------
# Easily file stuff in your home directory: findmy d Downloads
function findMyStuff()   {
    findType="$1"
    findFSO="$2"
    find "$HOME" -type "$findType" -name 'Library' -prune , -name '.Trash' -prune , -name "$findFSO"
}
alias findmy=findMyStuff

#-------------------------------------------------------------------------------

function ll { ls --color -l   "$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function la { ls --color -al  "$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function ld { ls --color -ld  "$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function lh { ls --color -alh "$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }

#-------------------------------------------------------------------------------
