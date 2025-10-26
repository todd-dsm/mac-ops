# Technical Gotchas and Lessons Learned

> *AKA: stuff I don't want to forget.*

## SSH Host Key Management

**Old Approach (Complex):**

```yaml
- name: Scan GitHub SSH key
  shell: ssh-keyscan -t rsa {{ host }}
- name: Add to known_hosts
  known_hosts: ...
```

**New Approach (Elegant):**

```yaml
- name: Clone repository
  ansible.builtin.git:
    repo: "{{ repo_url }}"
    dest: "{{ destination }}"
    accept_hostkey: yes  # Handles SSH keys automatically
```

**Lesson:** Ansible's built-in `accept_hostkey: yes` eliminates complex SSH key validation while maintaining security.

## System Restart Requirements

### Menu Bar Changes

**Issue:** Battery percentage and clock format changes don't appear immediately.

**Solution:**

```yaml
- name: Restart SystemUIServer
  ansible.builtin.command: killall SystemUIServer
  ignore_errors: yes
```

## Application Installation

### HashiCorp Tools

**Issue:** Direct Homebrew installation of Terraform conflicts with tfenv.

**Pattern:**

```yaml
- name: Add HashiCorp tap
  homebrew_tap:
    name: hashicorp/tap
- name: Install from tap
  homebrew:
    name: hashicorp/tap/packer
```

**Applications requiring taps:**

- HashiCorp tools: `hashicorp/tap`
- Fonts: `homebrew/cask-fonts`
- Buildpacks: `buildpacks/tap`

## Path Management

### System Path Modifications

**Issue:** Environment variables don't work in `/etc/paths`.

**Wrong:**

```yaml
line: "$HOME/.cargo/bin"  # Variables not expanded
```

**Correct:**

```yaml
line: "{{ ansible_env.HOME }}/.cargo/bin"  # Literal path
```

**Pattern for path additions:**

```yaml
- name: Add to system path
  lineinfile:
    path: /etc/paths
    insertbefore: '^/usr/local/bin$'
    line: "/literal/path/to/binary"
  become: yes
```

## macOS Preferences

### Data Type Sensitivity

**Issue:** macOS defaults are strict about data types.

**Common Type Errors:**

- Font size as int vs string
- Boolean vs integer values
- Domain-specific type requirements

**Discovery Pattern:**

```bash
# Check existing type
defaults read domain.name key

# Set with explicit type
defaults write domain.name key -string "value"
defaults write domain.name key -int 1
defaults write domain.name key -bool true
```

**Error Message Pattern:**

```shell
Type mismatch. Type in defaults: int
```

Solution: Match the existing type exactly.

## Sandboxed Applications

### Container Preference Storage

**Discovery:** Modern apps store preferences in containers, not global locations.

**Pattern:**

```bash
# Global (doesn't work for sandboxed apps)
defaults write NSGlobalDomain key value

# Sandboxed (actual location)
defaults write ~/Library/Containers/app.bundle.id/Data/Library/Preferences/app.bundle.id key value
```

**Impact:** Global system preferences may not affect sandboxed applications.

## Loop Optimizations

### Efficient Batch Operations

**Before (inefficient):**

```yaml
- name: Add dock item
  shell: "dockutil --add {{ item }}"
  # Dock restarts after each item
```

**After (efficient):**

```yaml
- name: Add dock items
  shell: "dockutil --add {{ item }} --no-restart"
- name: Restart dock once
  command: killall Dock
```

**Pattern:** Use `--no-restart` flags when available, then manually restart once.

## Deprecation Discoveries

### Apple Tool Deprecations

**Deprecated Tools:**

- `sfltool add-item` (removed High Sierra)
- `atsutil` (deprecated macOS 14+)
- Font cache management (automatic now)

**Replacement Pattern:**

- Research community alternatives (`mysides` for sfltool)
- Use modern Ansible modules when available
- Document manual steps when no alternative exists

## Error Handling

### Clean Failure Patterns

**Robust Error Handling:**

```yaml
- name: Optional operation
  shell: "command_that_might_fail"
  register: result
  failed_when: false
  changed_when: result.rc == 0
```

**Benefits:**

- No spurious failures on optional operations
- Proper change detection
- Clean log output

## Validation Patterns

### Simplified Assertions

**Before (complex):**

```yaml
- name: Check something
  stat: path="{{ path }}"
  register: check
- name: Validate
  fail: msg="Error"
  when: not check.stat.exists
```

**After (clean):**

```yaml
- name: Validate exists
  assert:
    that: path_check.stat.exists
    fail_msg: "Clear error message"
    success_msg: "Success confirmation"
```

**Benefits:** Single task, clear messaging, automatic exit on failure.

### The PostScript Name Requirement

**Issue:** Font family names don't work for macOS application preferences.

**Discovery Method:**

```bash
fc-query ~/Library/Fonts/Hack-Regular.ttf | grep "postscriptname"
```

**Examples:**

- Wrong: `"Hack"` (display name)
- Correct: `"Hack-Regular"` (PostScript name)
- Wrong: `"Source Code Pro"` (display name)
- Correct: `"SourceCodePro-Regular"` (PostScript name)

**Impact:** Applications like TextEdit will ignore font preferences unless the exact PostScript name is used.

**Pattern for Discovery:**

1. Install font via Homebrew or manual installation
2. Use `fc-query` to discover PostScript name
3. Use PostScript name in preference configuration
4. Test with actual application to verify

## Key Principles Learned

1. **Test with actual applications** - preferences may not take effect as expected
2. **Use PostScript names for fonts** - display names don't work
3. **Leverage Ansible's built-in capabilities** - `accept_hostkey`, error handling
4. **Expect Apple deprecations** - have alternatives ready
5. **System restarts matter** - some changes require service restarts
6. **Sandboxed apps are different** - check container preferences
7. **Match existing data types** - macOS defaults are type-strict
8. **Batch operations efficiently** - minimize service restarts

These discoveries represent real-world edge cases that aren't well-documented elsewhere and would typically require hours of debugging to identify.
