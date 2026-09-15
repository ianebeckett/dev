# Dev Repo Backlog

## First Milestone

### 4. Installer Integration
**Status:** Completed

- [x] Make the dispatcher and platform installers executable.
- [x] Keep platform helpers under `runs/installers/`, outside runner discovery.
- [x] Run the selected dispatcher first; Neovim installation lives in the platform installer.
- [x] Remove the old static `installs` file.

---

### 5. Execution Order
**Status:** Completed

- [x] Load `.zshenv` before any run script, with no per-script XDG fallbacks.
- [x] Run installation first when selected, followed by configuration scripts in filename order.
- [x] Preserve targeted configuration runs that skip installation.
- [x] Cover ordering and platform dispatch with stub installers in `tests/smoke.sh`.

---

### 6. Error Recovery
**Status:** Basic handling completed; further diagnostics pending

- [x] Stop at the first failed script, report its path, and return its exit status.
- [x] Document full and filtered retries in `README.md`.
- [x] Cover failure propagation in the smoke check.
- [ ] Add line-level diagnostics or a persistent setup log if needed.
- [ ] Consider checkpoints if targeted retries become insufficient.

---

### 7. No Uninstall/Cleanup Script
**Status:** Not started

- [ ] Add an explicit cleanup command outside auto-discovered `runs/` scripts.
- [ ] Remove only expected repository-owned symlinks and report what was removed.
- [ ] Preserve the checkout and unrelated user configuration.
- [ ] Verify setup can recreate links after cleanup.

---

### 8. Configuration Linking
**Status:** Completed

- [x] Validate sources and create destination parents through `lib/links.sh`.
- [x] Skip correct links, replace stale symlinks, and report real-file/directory conflicts.
- [x] Link `~/.zshenv` for shell startup.
- [x] Keep runtime caches outside the checkout and stop tracking cache placeholders.
- [x] Cover fresh-home configuration and reruns in the smoke check.

---

### 9. Dry-run Output Could Be Better
**Status:** Script-level preview completed; link-level preview pending

- [x] Show selected scripts in execution order without running their bodies.
- [x] Cover dry-run filtering in the smoke check.
- [ ] Show source/destination paths and missing sources or destination conflicts.
- [ ] Report what would be created, replaced, or skipped, with a summary.

---

## Remaining Platform and Dependency Work

- [ ] Validate full package installation on a clean Ubuntu machine.
- [ ] Inventory dependencies used by shell/editor integrations, including `delta`,
  `trash-put`, `rbenv`, and configured language servers.
- [ ] Add a read-only dependency/configuration `doctor` command.
- [ ] Improve macOS compatibility and verify installation there; currently best-effort.

## Completed Documentation and Bootstrap Work

- [x] Document installation, selective runs, environment initialization, retries, and checks.
- [x] Detect Linux/macOS and macOS architecture during bootstrap.
