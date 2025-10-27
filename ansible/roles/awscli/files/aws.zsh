# -------------------------------------|------------------------------------- #
#                                    Amazon                                   #
# --------------------------------------------------------------------------- #
#source /usr/local/bin/aws_zsh_completer.sh
#complete -C "$(type -P aws_completer)" aws
export AWS_CONFIG_FILE="$HOME/.aws/config"
export AWS_PAGER='cat'
export AWS_PROFILE='thomas'
#export AWS_DEFAULT_REGION='us-east-1'
