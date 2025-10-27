# -------------------------------------|------------------------------------- #
#                                   Vault                                     #
# --------------------------------------------------------------------------- #
complete -o nospace -C /opt/homebrew/bin/vault vault
export VAULT_ADDR='http://localhost:8200'    # INIT
export VAULT_SKIP_VERIFY=true                # INIT
#export VAULT_NAMESPACE='admin'
#export VAULT_CLI_NO_COLOR=0
#export VAULT_CLUSTER_ADDR="https://127.0.0.1:8201"
#export VAULT_CACERT='/path/to/vault-ca.pem
#export VAULT_CLIENT_TIMEOUT="2m"
#export VAULT_LICENSE_PATH=/local/path/to/vault.hclic
#export VAULT_TLS_SERVER_NAME="hostname.domain"
#export VAULT_LOG_FORMAT='standard'
#export VAULT_LOG_LEVEL='info'	# <err|warn|info|debug|trace>
