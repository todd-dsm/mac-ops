# Manual Configuration

Apple is removing bits of automation from a system that was designed to be completely automated.

The `mac-ops` automation configures about 95% of the macOS workstation. The remaining bits require manual configuration.

## THIS IS 100% PREFERENCE

I find the following configurations to be annoying so this is really a list of things I do. It may not apply to you at all.

### 1. Finder Sidebar Favorites

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

### 2. System Directory View Settings

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
