# --------------------------------------------------------------------------- #
#                                   ALIASES                                   #
# -------------------------------------|------------------------------------- #
#                                conveniences                                 #
# --------------------------------------------------------------------------- #
alias -g zshrc='vi ~/.zshrc'
alias ckad="cd $HOME/code/edu/kubernetes-udemy/ckad-stuff"

# --------------------------------------------------------------------------- #
#                                  coreutils                                  #
# --------------------------------------------------------------------------- #
alias hist='history | cut -c 8-'
alias ll="ls -l  --color=always"
alias la="ls -la --color=always"
alias ld="ls -ld --color=always"
alias lh="ls -lh --color=always"
alias cp='cp -rfvp'
alias mv='mv -v'

# --------------------------------------------------------------------------- #
#                                    utils                                    #
# --------------------------------------------------------------------------- #
#alias cat='bat --style=plain' 2>/dev/null
alias grep='grep --color=auto' 2>/dev/null
alias kube="$(whence kubectl)"

