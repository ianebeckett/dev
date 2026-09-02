# Dev Repo Backlog

## Improvements to Implement

### 4. Missing installs Script Integration
**Status:** Partially done
**Description:** `runs/installs` exists and works, but `setup` doesn't call it explicitly. It's only called if `runner` happens to run it before other scripts.

**Tasks:**
- [ ] Add explicit `$HOME/dev/runs/installs` call to `setup` BEFORE calling `runner`
- [ ] Remove old static `installs` file (no longer needed)
- [ ] Test that packages are installed before configs are linked

---

### 5. No Dependency Between Run Scripts ⚠️ CRITICAL
**Status:** Not started
**Description:** Run scripts have no ordering guarantees. If `runs/tmux` runs before `runs/installs`, it will fail. Currently no way to specify dependencies.

**Tasks:**
- [ ] Ensure `runs/installs` ALWAYS runs first (add to top of `setup`)
- [ ] Document script dependencies (which scripts need what installed)
- [ ] Option A: Hard-code install-first approach in `setup`
  - [ ] Call `runs/installs` explicitly at start
  - [ ] Then call `runner` for all config scripts
- [ ] Option B: Add dependency tracking to `runner` script
  - [ ] Create a manifest of script dependencies
  - [ ] Make `runner` execute in dependency order
- [ ] Test on both Linux and macOS

---

### 6. Error Recovery
**Status:** Not started
**Description:** If a run script fails halfway through, there's no way to know which step failed or how to resume. Setup just stops.

**Tasks:**
- [ ] Add better logging to `setup` and `runner` scripts
- [ ] Log which script failed and at what line
- [ ] Provide guidance on how to resume or fix
- [ ] Consider creating a `setup.log` file for debugging
- [ ] Add checkpoints or resume capability

---

### 7. No Uninstall/Cleanup Script
**Status:** Not started
**Description:** If you need to remove all the symlinks cleanly, there's no tool for it. You'd have to manually delete them.

**Tasks:**
- [ ] Create `runs/cleanup` script that:
  - [ ] Removes all symlinks created by other `runs/` scripts
  - [ ] Asks before removing (safety check)
  - [ ] Logs what was removed
  - [ ] Leaves git repo intact (don't delete `$HOME/dev`)
- [ ] Add `./runner --cleanup` option
- [ ] Test that re-running setup after cleanup works

---

### 8. Missing Config Files
**Status:** Not started
**Description:** The `runs/` scripts link to configs that may not exist in `env/.config/`. No validation that they're there before linking.

**Tasks:**
- [ ] Add pre-link validation to all `runs/*` scripts
- [ ] Check that config files/directories exist before symlinking
- [ ] Provide helpful error message if missing
- [ ] List which configs are expected vs. missing
- [ ] Consider creating placeholder configs if needed

---

### 9. Dry-run Output Could Be Better
**Status:** Not started
**Description:** `runner --dry-run` works but doesn't show what files would be linked or what the final state would be.

**Tasks:**
- [ ] Update `runner --dry-run` to show:
  - [ ] What configs would be linked
  - [ ] Source and destination paths for each symlink
  - [ ] Whether config files exist
  - [ ] What would be created vs. skipped
- [ ] Make output clear and actionable
- [ ] Add summary at end of dry-run

---

## Completed ✅
- [x] Documentation (README.md exists)
- [x] macOS support (Linux + macOS both working)
- [x] OS detection (Linux and macOS with architecture detection)
