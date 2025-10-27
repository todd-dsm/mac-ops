# Info, et al.

## Automation Logs and Reports

These are a collection of logs that recorded the state of the system before the automation (`pre`) then again, using the same scripts, after the automation (`post`). This should make for a clean diff file1

```shell
% tree ~/.config/admin/logs
/Users/$USER/.config/admin/logs
├── apps-find-all-post-install.log
├── apps-find-all-pre-install.log
├── apps-home-dot-dirs-post-install.log
├── apps-home-dot-dirs-pre-install.log
├── apps-homebrew-post-install.log
├── apps-paid-post-install.log
├── apps-paid-pre-install.log
├── apps-pkgutil-post-install.log
├── apps-pkgutil-pre-install.log
├── libs-pip-post-install.log
├── libs-pip3-post-install.log
└── mac-ops-config.out
```

---

## Additional Resources

- **Testing Notes:** [docs/testing/notes.md](testing/notes.md)
- **Technical Gotchas:** [docs/dev/gotchas.md](dev/gotchas.md)
- **Project README:** [README.md](../README.md)

---

## Troubleshooting

**If settings didn't apply:**

1. Check automation logs for errors
2. Verify you ran with appropriate permissions
3. Some settings require logout/login or reboot
4. Re-run specific roles: `./bootstrap.sh --tags "macos"`

**For additional help:**

- Review the project wiki (if available)
- Check GitHub issues
