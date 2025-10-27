# -------------------------------------|------------------------------------- #
#                                  Terraform                                  #
# --------------------------------------------------------------------------- #
alias tf="$(whence -p terraform)"
export TF_LOG='DEBUG'
export TF_LOG_PATH='/tmp/terraform.log'
#export TFLINT_CONFIG_FILE="$HOME/.config/tf"
