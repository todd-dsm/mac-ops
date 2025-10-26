# Testing and Usage Guide

```shell
% ./bootstrap.sh --tags "base"

Options:

-v ... -vvvv # verbosity
--check # for dry runs
```

This seems to be a sensible ordering of tests:

```shell
* base
* facts
* foundation
* gui
* utils
# -apps---------------
* rust
* golang
* nodejs
* awscli
* tfenv
* packer
* vault
* gcp
* containers
* kubes
# -system-------------
* macos
* cleanup
```

## Command Examples

Test specific tags or tools in isolation:

```bash

# Check what base setup would do
% ./bootstrap.sh --tags "base" --check

# Test Rust installation with verbosity
% ./bootstrap.sh --tags "rust" -vv
```

### Group Testing

Test combinations of roles:

```bash
% ./bootstrap.sh --tags "foundation,development-tools"
```

### Full System Testing

```bash
# Full system configuration, simple:
% ./bootstrap.sh
```

## Ansible Syntax and Validation

### Syntax Checking

Verify YAML syntax and playbook structure before running:

```bash
# Check syntax of entire playbook
% cd ansible
% ansible-playbook site.yml --syntax-check

# Check specific playbook
% ansible-playbook playbooks/development-tools.yml --syntax-check
```

### List Available Tags

See all available tags across the automation:

```bash
% cd ansible
% ansible-playbook site.yml --list-tags
```

## Understanding --check Mode

The `--check` flag runs Ansible in **"dry run" mode**:

- **Shows what would change** without making actual changes
- **Safe to run** on any system - no modifications occur
- **Useful for validation** before running the real automation
- **Reports "changed" status** for actions that would be taken
- **Files are not created** or modified in check mode

**Example check output:**

```yaml
TASK [Install Rust] ****************************************************
changed: [localhost]  # This would install Rust (but doesn't in check mode)

TASK [Configure Rust system path] *************************************
changed: [localhost]  # This would modify /etc/paths (but doesn't in check mode)
```

## Troubleshooting

### Common Issues

```bash
# Permission errors - may need elevated privileges
% ./bootstrap.sh --tags "terraform" --ask-become-pass

# Clear Ansible cache if roles aren't found
% rm -rf ~/.ansible/cp/

# Force role refresh
% cd ansible && ansible-galaxy install --force -r requirements.yml
```
