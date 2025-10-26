#!/usr/bin/env bash
# Comprehensive validation script for macops-ansible automation
# shellcheck disable=SC2015

#set -x

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass() {
    echo -e "${GREEN}✓${NC} $*"
    ((PASS++))
}

fail() {
    echo -e "${RED}✗${NC} $*"
    ((FAIL++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*"
    ((WARN++))
}

header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$*"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

check_dir() {
    if [[ -d "$1" ]]; then
        pass "$2"
    else
        fail "$2 (missing: $1)"
    fi
}

check_file() {
    if [[ -f "$1" ]]; then
        pass "$2"
    else
        fail "$2 (missing: $1)"
    fi
}

check_cmd() {
    if command -v "$1" &>/dev/null; then
        pass "$2"
    else
        fail "$2 (command not found: $1)"
    fi
}

check_opt() {
    if [[ -e "$1" ]]; then
        pass "$2"
    else
        warn "$2 (missing: $1)"
    fi
}

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         MACOPS-ANSIBLE AUTOMATION VALIDATION                       ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo "Starting validation at $(date)"

# ============================================================================
header "FOUNDATION & PREREQUISITES"
check_dir "$HOME/.config/admin/logs" "Admin logs directory"
check_dir "$HOME/.config/admin/backup" "Admin backup directory"
check_dir "$HOME/.config/shell" "Shell config directory"
check_opt "$HOME/.ssh/known_hosts" "SSH known_hosts"
check_opt "$HOME/Downloads/solarized" "Solarized theme"

# ============================================================================
header "SHELL ENVIRONMENT"
if [[ "$SHELL" == "/bin/zsh" ]]; then
    pass "Default shell: ZSH"
else
    fail "Shell not ZSH: $SHELL"
fi

check_dir "$HOME/.oh-my-zsh" "Oh My ZSH"
check_file "$HOME/.zshrc" ".zshrc"
#check_opt "$HOME/.oh-my-zsh/custom/homebrew.zsh" "Homebrew config"
check_opt "$HOME/.oh-my-zsh/custom/aliases.zsh" "Custom aliases"
check_opt "$HOME/.oh-my-zsh/custom/functions.zsh" "Custom functions"

# ============================================================================
header "PROGRAMMING LANGUAGES"

# Rust
if command -v rustc &>/dev/null; then
    rust_version=$(rustc --version | cut -d' ' -f2)
    pass "Rust: $rust_version"
    check_dir "$HOME/.cargo/bin" "Cargo bin directory"
else
    fail "Rust not installed"
fi

# Go
if command -v go &>/dev/null; then
    go_version=$(go version | awk '{print $3}')
    pass "Go: $go_version"
    check_dir "$HOME/go/bin" "Go workspace bin"
else
    fail "Go not installed"
fi

# Node.js
if command -v node &>/dev/null; then
    node_version=$(node --version)
    pass "Node.js: $node_version"
    check_cmd npm "npm"
else
    fail "Node.js not installed"
fi

# Python
if command -v python3 &>/dev/null; then
    python_version=$(python3 --version | awk '{print $2}')
    pass "Python3: $python_version"
    check_cmd pip3 "pip3"
else
    fail "Python3 not installed"
fi

# ============================================================================
header "DEVELOPMENT TOOLS"

# AWS CLI
if command -v aws &>/dev/null; then
    aws_version=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
    pass "AWS CLI: $aws_version"
    check_opt "$HOME/.oh-my-zsh/custom/aws.zsh" "AWS config"
    check_opt "$HOME/.aws/cli/alias" "AWS CLI aliases"
else
    fail "AWS CLI not installed"
fi

# Terraform
if command -v terraform &>/dev/null; then
    tf_version=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    pass "Terraform: $tf_version"
    check_cmd tfenv "tfenv"
else
    fail "Terraform not installed"
fi

check_cmd packer "Packer"
check_cmd vault "Vault"

# Google Cloud SDK
if [[ -d "/opt/homebrew/Caskroom/gcloud-cli" ]]; then
    pass "Google Cloud SDK installed"
else
    warn "Google Cloud SDK not installed"
fi

# Ansible
if command -v ansible &>/dev/null; then
    ansible_version=$(ansible --version | head -1 | awk '{print $3}')
    pass "Ansible: $ansible_version"
    check_dir "$HOME/.ansible" "Ansible directory"
    check_file "$HOME/.ansible/ansible.cfg" "Ansible config"
else
    fail "Ansible not installed"
fi

# ============================================================================
header "CONTAINERIZATION"
check_cmd docker "Docker"
check_cmd pack "Buildpacks (pack)"
check_cmd dive "dive"

# ============================================================================
header "KUBERNETES ECOSYSTEM"
if command -v kubectl &>/dev/null; then
    kubectl_version=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"v[^"]*' | cut -d'"' -f4)
    pass "kubectl: $kubectl_version"
else
    fail "kubectl not installed"
fi

check_cmd helm "Helm"
check_cmd minikube "Minikube"
check_cmd k9s "k9s"
check_cmd eksctl "eksctl"
check_cmd kubectx "kubectx"
check_cmd kubens "kubens"
check_opt "$HOME/.ktx" "ktx function"
check_cmd istioctl "istioctl"
check_cmd linkerd "linkerd"
check_cmd cilium "cilium-cli"
check_cmd flux "Flux"
check_cmd argocd "ArgoCD"
check_cmd kubectl-krew "Krew"

# ============================================================================
header "GUI APPLICATIONS"
check_opt "/Applications/Google Chrome.app" "Google Chrome"
check_opt "/Applications/Firefox.app" "Firefox"
check_opt "/Applications/Slack.app" "Slack"
check_opt "/Applications/Discord.app" "Discord"
check_opt "/Applications/Cursor.app" "Cursor"
check_opt "/Applications/Postman.app" "Postman"
check_opt "/Applications/Wireshark.app" "Wireshark"

if fc-list 2>/dev/null | grep -qi "hack"; then
    pass "Hack font installed"
else
    warn "Hack font not found"
fi

# ============================================================================
header "SYSTEM UTILITIES"
check_cmd nmap "nmap"
check_cmd tree "tree"
check_cmd jq "jq"
check_cmd yq "yq"
check_cmd tmux "tmux"
check_cmd cmake "cmake"
check_cmd bazel "bazel"
check_cmd dockutil "dockutil"

# ============================================================================
header "MACOS CONFIGURATION"

viewStyle=$(defaults read com.apple.finder FXPreferredViewStyle 2>/dev/null || echo "")
if [[ "$viewStyle" == "Nlsv" ]]; then
    pass "Finder: List view"
else
    warn "Finder not List view: $viewStyle"
fi

showExt=$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || echo "0")
# 0 = default; 1 = show extensions
if [[ "$showExt" == "0" ]]; then
    pass "Show all extensions: enabled"
else
    warn "Show extensions disabled"
fi

tileSize=$(defaults read com.apple.dock tilesize 2>/dev/null || echo "0")
if [[ "$tileSize" == "42" ]]; then
    pass "Dock size: 42px"
else
    warn "Dock not 42px: $tileSize"
fi

screenshotDir=$(defaults read com.apple.screencapture location 2>/dev/null || echo "")
if [[ "$screenshotDir" == "$HOME/Pictures/screens" ]]; then
    pass "Screenshot location configured"
else
    warn "Screenshot location not set"
fi

check_dir "$HOME/Pictures/screens" "Screenshots directory"

if [[ -L "$HOME/Desktop/screens" ]]; then
    pass "Desktop screenshots symlink"
else
    warn "Desktop symlink missing"
fi

richText=$(defaults read com.apple.TextEdit RichText 2>/dev/null || echo "1")
if [[ "$richText" == "0" ]]; then
    pass "TextEdit: Plain text mode"
else
    warn "TextEdit not plain text mode"
fi

font=$(defaults read com.apple.TextEdit NSFixedPitchFont 2>/dev/null || echo "")
if [[ "$font" == "Hack-Regular" ]]; then
    pass "TextEdit font: Hack-Regular"
else
    warn "TextEdit font not Hack: $font"
fi

guestLogin=$(sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null || echo "1")
if [[ "$guestLogin" == "0" ]]; then
    pass "Guest login: disabled"
else
    warn "Guest login not disabled"
fi

# ============================================================================
header "VALIDATION SUMMARY"

TOTAL=$((PASS + FAIL + WARN))
echo ""
echo "Results:"
echo -e "  ${GREEN}✓ Passed:${NC}  $PASS/$TOTAL"
echo -e "  ${RED}✗ Failed:${NC}  $FAIL/$TOTAL"
echo -e "  ${YELLOW}⚠ Warnings:${NC} $WARN/$TOTAL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ AUTOMATION VALIDATION SUCCESSFUL                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ AUTOMATION VALIDATION FAILED - Review failures above            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
