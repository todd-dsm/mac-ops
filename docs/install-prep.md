# Install Prep

This simply prepares macOS for the `mac-ops` (Ansible) automation. Major configurations:

## Configure `sudo` *Properly*

```shell
 % sudo cat /etc/sudoers.d/jsmith
jsmith ALL=(ALL) NOPASSWD:ALL
```

## Install Homebrew

This is a by-the-book install of [Homebrew]. You can live life without it but I don't know why you'd want to.

## Install GNU Tools

We end up working on Linux occassionally. While this is becoming less true every day, it will always be true. There is no set of conditions where we don't need to create the occasional bash script. For those times, it's annoying to use the (slightly different) (BSD) UNIX variants that are on macOS, then watch them fail on Linux system that uses the GNU variants.

To correct for that, system changes are made:

1. The GNU variants of common programs are installed
   1. `sed`, `bash`, `find`, `awk`, etc.
2. `macOS` is configured to favor the GNU programs and manpages

Then, a script can be written on your `macOS` and it will do exactly what you programmed into it on the target Linux system.

## Install Ansible

The `mac-ops` config is all Ansible-ized... now. But, it makes system configuration idempotent and super easy to test.

## Install My ZSH

You're either using this or you're working too hard.

## Minor Configs

Out of the box, `macOS` has some old versions of programs; we're just installing the newer versions:

* rsync
* git (and configures it)
* then it saves some logs for auditing purposes, E.G:

```shell
% tree ~/.config/admin/logs
/Users/jsmith/.config/admin/logs
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

Afterwards, the `install-prep` log is saved with the other logs.

After that, the system is ready for the next step!

<!-- docs/refs -->

[Homebrew]:https://brew.sh/
