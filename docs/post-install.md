# Post-Installation Manual Configuration Steps

These steps require manual configuration as they cannot be automated due to macOS limitations or deprecated APIs.

## Terminal Profile Import

**If you have a custom Terminal profile:**

1. Open Terminal
2. Navigate to Terminal > Preferences (⌘,)
3. Click "Profiles" tab
4. Click the gear icon at the bottom
5. Select "Import..."
6. Choose your saved `.terminal` profile file
7. Set as default if desired

**Note:** The Solarized theme has been cloned to `~/Downloads/solarized`.

## 5. Reboot System

**Required for all changes to take full effect:**

```bash
# Close all applications first
sudo shutdown -r now
```
