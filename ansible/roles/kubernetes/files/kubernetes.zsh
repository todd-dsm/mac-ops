# -------------------------------------|------------------------------------- #
#                                 KUBERNETES                                  #
# --------------------------------------------------------------------------- #
alias kubes="$(whence kubectl)"
#source <(kubectl  completion bash | sed 's/kubectl/kubes/g')
#source <(minikube completion bash)
# --------------------------------------------------------------------------- #
#export "$HOME/.krew/bin"
source "$HOME/.ktx-completion.sh"
source "$HOME/.ktx"
# --------------------------------------------------------------------------- #
export MINIKUBE_IN_STYLE=false
source <(minikube completion zsh)
source "$HOME/.ktx"
source "$HOME/.ktx-completion.sh"
# --------------------------------------------------------------------------- #
export HELM_HOME="$HOME/.helm"
#source <(helm     completion bash)
