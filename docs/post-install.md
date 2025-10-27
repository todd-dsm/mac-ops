# Post-Installation Manual Configuration Steps

These steps require manual configuration as they cannot be automated for various reasons. Apple has remov bits of automation from a system that was designed to be completely automated.

`mac-ops` configures about 95% of the macOS workstation. The remaining bits require manual configuration:

## Terminal Profile Import

**If you have a custom Terminal profile:**

1. Open Terminal
2. Navigate to Terminal > Preferences (⌘,)
3. Click "Profiles" tab
4. Click the gear icon at the bottom
5. Select "Import..."
6. Choose your saved `.terminal` profile file
7. Set as default if desired

**Note:** The Solarized theme has been cloned to `~/Downloads/solarized`. If you like something else, use that.

## THIS IS 100% PREFERENCE

I find the following configurations to be annoying so this is really a list of things I do. It may not apply to you at all.

### Finder Sidebar Favorites

**Issue:** Apple deprecated `sfltool add-item` functionality starting with macOS High Sierra.

**Manual Steps:**

1. Open Finder
2. Drag desired folders from their locations to the sidebar "Favorites" section
3. Personal favorites:
   - AirDrop
   - Downloads
   - Documents
   - Desktop
   - Music
   - Pictures
   - Movies
   - `$HOME`

**Current State:** The program [mysides] might be a solution.

### System Directory View Settings

User-space views are defaulted to List view.

**Issue:** macOS ***system*** directories are unaffected by user view preferences; make sense.

**Manual Steps:**

1. Navigate to `/Applications/` in Finder
2. Change view to List view (⌘2 or View menu)
3. Open View Options (⌘J)
4. Check "Always open in list view" (top)
5. Click "Use as defaults" (bottom)

***NOTE: Unfortunately, this needs to be repeated for each system directory.***

<!-- docs/refs -->

[mysides]:https://github.com/mosen/mysides
