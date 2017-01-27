myMac
=====

Automation to build a great MBP Desktop with a base configurtion for DevOps enthusiasts.

This is just my take on the Mac OS X setup. If you find value in it, please feel free to use it.

***

##Documentation
Before jumping in, you should probably check the [wiki] first. This may not be for you.

***

##Pre-Game
Prep the macOS by installing:

* The latest updates,
* Xcode CLI Tools, and
* Saving some details about apps that are currently installed.

```bash
curl -Lo- https://goo.gl/j2y1Dn | bash | tee /tmp/install-prep.out
```


***

##Kick-off
To auto-magically configure your new Mac OS X, just

```sh
curl -Lo- http://tiny.cc/sxzh0x | bash | tee -ai mac-conf.log
```

***

##Post-Game
 * Close all Terminal windows and re-open them; you'll have access to the GNU programs.
 * Import your Terminal profile, if you have one.
 * Un-tar your .vimrc and .vim/, if you have that.

Then you're ready to start.


[wiki]:https://github.com/todd-dsm/myMac/wiki/System-Modifications
[Packer]:https://packer.io/downloads.html
[Vagrant]:http://www.vagrantup.com/downloads

