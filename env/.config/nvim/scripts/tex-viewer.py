"""Linux desktop helper for tex_viewer.lua; stdin EOF releases a viewer lease.

Requires Zathura, PyGObject, and the GNOME Window Calls and Desktop Icons NG
extensions (the latter supplies Ubuntu Dock margins and monitor geometry).
Neovim autocommands own the lifecycle; this helper handles desktop integration
and coordinates ownership between editor processes through the session bus.
"""

import contextlib
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import select
import signal
import subprocess
import sys
import time

from gi.repository import Gio, GLib

INTERFACE = "org.pwmt.zathura"
OBJECT = "/org/pwmt/zathura"


def run(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL, timeout=5).strip()


def identity(pid):
    """Include process start time so a recycled PID is never treated as an owner."""
    try:
        return Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[19]
    except (OSError, IndexError):
        return None


def live_leases(leases):
    return {pid: lease for pid, lease in leases.items() if identity(pid) == lease["start"]}


class Registry:
    def __init__(self, pdf):
        root = Path(os.environ.get("XDG_RUNTIME_DIR", f"/tmp/nvim-tex-viewer-{os.getuid()}"))
        root = root / "nvim-tex-viewer"
        root.mkdir(mode=0o700, parents=True, exist_ok=True)
        key = hashlib.sha256(os.fsencode(pdf)).hexdigest()
        self.path = root / (key + ".json")
        self.lock = root / (key + ".lock")

    @contextlib.contextmanager
    def edit(self):
        # Never unlink the lock: all editors must lock the same inode.
        with self.lock.open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            try:
                state = json.loads(self.path.read_text())
            except (FileNotFoundError, json.JSONDecodeError):
                state = {}
            state["leases"] = live_leases(state.get("leases", {}))
            try:
                yield state
            finally:
                self.path.write_text(json.dumps(state))


class Bus:
    def __init__(self):
        self.connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)

    def call(self, name, path, interface, method, parameters=None):
        return self.connection.call_sync(
            name, path, interface, method, parameters, None,
            Gio.DBusCallFlags.NONE, 1500, None,
        ).unpack()

    def owner(self, name):
        return self.call("org.freedesktop.DBus", "/org/freedesktop/DBus",
                         "org.freedesktop.DBus", "GetNameOwner", GLib.Variant("(s)", (name,)))[0]

    def filename(self, name):
        value = self.call(name, OBJECT, "org.freedesktop.DBus.Properties", "Get",
                          GLib.Variant("(ss)", (INTERFACE, "filename")))[0]
        return os.path.realpath(value) if value else ""

    def matches(self, state, pdf):
        try:
            return self.owner(state["name"]) == state["owner"] and self.filename(state["name"]) == pdf
        except (KeyError, GLib.Error):
            return False

    def find(self, pdf):
        names = self.call("org.freedesktop.DBus", "/org/freedesktop/DBus",
                          "org.freedesktop.DBus", "ListNames")[0]
        for name in names:
            if not name.startswith(INTERFACE + ".PID-"):
                continue
            try:
                if self.filename(name) == pdf:
                    return {"name": name, "owner": self.owner(name), "owned": False}
            except GLib.Error:
                pass  # A window may close while we enumerate it.
        return None


def ancestors(pid):
    result = set()
    while pid > 1 and pid not in result:
        result.add(pid)
        try:
            pid = int(Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[1])
        except (OSError, ValueError, IndexError):
            break
    return result


def editor_processes(editor_pid):
    result = ancestors(editor_pid)
    # A tmux server's process tree does not lead back to the terminal. Follow
    # only clients attached to this pane's session, not arbitrary terminals.
    pane = os.environ.get("TMUX_PANE")
    if pane:
        session = run("tmux", "display-message", "-p", "-t", pane, "#{session_id}")
        clients = run("tmux", "list-clients", "-t", session, "-F", "#{client_pid}")
        for pid in clients.splitlines():
            result.update(ancestors(int(pid)))
    return result


def choose_editor(windows, pids):
    candidates = [window for window in windows if window["pid"] in pids]
    focused = [window for window in candidates if window.get("focus")]
    if focused:
        return focused[0]
    visible = [window for window in candidates if window.get("in_current_workspace")]
    if len(visible) == 1:
        return visible[0]
    if len(candidates) == 1:
        return candidates[0]
    raise RuntimeError("Cannot uniquely identify the terminal hosting Neovim")


def monitor_rectangles(bus, monitor):
    # DING exports GNOME's logical monitor coordinates and the dock/panel
    # margins together. Do not combine them with XWayland's global work area:
    # that area changes meaning when monitors are connected or disconnected.
    try:
        description = bus.call(
            "com.rastersoft.dingextension", "/com/rastersoft/dingextension/control",
            "org.gtk.Actions", "Describe", GLib.Variant("(s)", ("desktopGeometry",)),
        )[0]
    except GLib.Error as error:
        raise RuntimeError("Enable Desktop Icons NG to read GNOME's monitor and dock geometry") from error
    for area in description[2][0]:
        if area["monitorIndex"] != monitor:
            continue
        x, y, width, height = (round(area[key]) for key in ("x", "y", "width", "height"))
        midpoint = x + width // 2
        left = x + math.ceil(area["marginLeft"])
        top = y + math.ceil(area["marginTop"])
        right = x + width - math.ceil(area["marginRight"])
        bottom = y + height - math.ceil(area["marginBottom"])
        if not left < midpoint < right or bottom <= top:
            raise RuntimeError("The dock and panels leave no room for a two-window layout")
        return (
            dict(x=left, y=top, width=midpoint-left, height=bottom-top),
            dict(x=midpoint, y=top, width=right-midpoint, height=bottom-top),
        )
    raise RuntimeError("GNOME has not reported geometry for the terminal's monitor")


class Desktop:
    """Control native Wayland and XWayland windows through GNOME, by ID."""
    interface = "org.gnome.Shell.Extensions.Windows"
    path = "/org/gnome/Shell/Extensions/Windows"

    def __init__(self, bus, editor_pid):
        self.bus = bus
        try:
            windows = self.windows()
        except GLib.Error as error:
            raise RuntimeError("Enable the GNOME Window Calls extension to arrange the TeX windows") from error
        self.editor = choose_editor(windows, editor_processes(editor_pid))
        details = json.loads(self.call("Details", "(u)", self.editor["id"])[0])
        self.terminal_rect, self.viewer_rect = monitor_rectangles(bus, details["monitor"])
        # Different documents (or Neovim instances in tmux) can share a terminal.
        # Coordinate their layout separately from ownership of an individual PDF.
        shell_owner = bus.owner("org.gnome.Shell")
        self.layout = Registry(f"terminal:{shell_owner}:{self.editor['id']}:{self.editor['pid']}")
        self.layout_registered = False

    def call(self, method, signature=None, *values):
        parameters = GLib.Variant(signature, values) if signature else None
        return self.bus.call("org.gnome.Shell", self.path, self.interface, method, parameters)

    def windows(self):
        return json.loads(self.call("List")[0])

    def focus_editor(self):
        # IDs can disappear while a PDF builds. Never guess a replacement window.
        if any(w["id"] == self.editor["id"] and w["pid"] == self.editor["pid"] for w in self.windows()):
            self.call("Activate", "(u)", self.editor["id"])

    def arrange(self, viewer_pid):
        # Serialize arranging and restoring this terminal so an exiting helper
        # cannot maximize it over a new document's split layout.
        with self.layout.edit() as state:
            state["leases"][str(os.getpid())] = {"start": identity(os.getpid())}
            self.layout_registered = True
            self._arrange(viewer_pid)

    def restore_terminal(self):
        if not self.layout_registered:
            return
        with self.layout.edit() as state:
            state["leases"].pop(str(os.getpid()), None)
            if not state["leases"]:
                if any(w["id"] == self.editor["id"] and w["pid"] == self.editor["pid"] for w in self.windows()):
                    self.call("Maximize", "(u)", self.editor["id"])
                state.clear()
        self.layout_registered = False

    def _arrange(self, viewer_pid):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            windows = self.windows()
            viewer = next((w for w in windows if w["pid"] == viewer_pid), None)
            if viewer:
                if not any(w["id"] == self.editor["id"] and w["pid"] == self.editor["pid"] for w in windows):
                    raise RuntimeError("The originating terminal closed before the PDF opened")
                keys = ("x", "y", "width", "height")
                terminal = tuple(self.terminal_rect[key] for key in keys)
                target = self.viewer_rect
                pdf = tuple(target[key] for key in keys)
                self.call("MoveToWorkspace", "(uu)", viewer["id"], self.editor["workspace"])
                self.call("MoveResize", "(uiiuu)", self.editor["id"], *terminal)
                self.focus_editor()
                # A Wayland window is listed before GTK finishes mapping it and
                # restoring its saved size. Wait for two confirmed placements.
                stable = 0
                while time.monotonic() < deadline and stable < 2:
                    self.call("MoveResize", "(uiiuu)", viewer["id"], *pdf)
                    time.sleep(0.15)
                    actual = json.loads(self.call("GetFrameRect", "(u)", viewer["id"])[0])
                    stable = stable + 1 if actual == target else 0
                if stable < 2:
                    raise RuntimeError("GNOME could not place the PDF on the right half")
                # Catch the initial focus change without continuously fighting
                # a user's subsequent choice to focus another application.
                focused = next((w for w in self.windows() if w.get("focus")), None)
                if focused and focused["id"] == viewer["id"]:
                    self.focus_editor()
                return
            time.sleep(0.05)
        raise RuntimeError("Zathura opened, but GNOME did not expose its window")


def acquire(bus, registry, pdf, server):
    with registry.edit() as state:
        if not bus.matches(state, pdf):
            existing = bus.find(pdf)
            state.clear()
            state["leases"] = {}
            if existing:
                state.update(existing)
            else:
                process = subprocess.Popen(
                    ["zathura", pdf],
                    stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                    start_new_session=True,
                )
                name = f"{INTERFACE}.PID-{process.pid}"
                try:
                    deadline = time.monotonic() + 8
                    while True:
                        if process.poll() is not None:
                            raise RuntimeError(f"Zathura exited with status {process.returncode}")
                        try:
                            if bus.filename(name) == pdf:
                                break
                        except GLib.Error:
                            pass
                        if time.monotonic() >= deadline:
                            raise RuntimeError("Zathura did not open the PDF within 8 seconds")
                        time.sleep(0.05)
                    state.update(name=name, owner=bus.owner(name), owned=True)
                except BaseException:
                    if process.poll() is None:
                        process.terminate()
                    process.wait(timeout=5)
                    raise
        state["leases"][str(os.getpid())] = {"start": identity(os.getpid()), "server": server}
        return state.copy()


def release(bus, registry, pdf):
    with registry.edit() as state:
        state["leases"].pop(str(os.getpid()), None)
        if not state["leases"]:
            # Never close a viewer the user opened independently, or one repurposed
            # to show another document. The D-Bus owner also guards against PID reuse.
            if state.get("owned") and bus.matches(state, pdf):
                bus.call(state["name"], OBJECT, INTERFACE, "ExecuteCommand", GLib.Variant("(s)", ("quit",)))
            state.clear()


def watch(pdf, server, nvim, editor_pid):
    bus = Bus()
    desktop = Desktop(bus, editor_pid)
    registry = Registry(pdf)
    state = acquire(bus, registry, pdf, server)
    try:
        desktop.arrange(int(state["name"].rsplit("-", 1)[1]))
        print("READY", flush=True)

        def inverse(_connection, _sender, _path, _interface, _signal, parameters, _data):
            # Multiple Neovim instances may share this PDF. Route inverse search
            # to the most recently attached live editor, without shell interpolation.
            with registry.edit() as current:
                leases = list(current["leases"].values())
                if not leases or leases[-1]["server"] != server:
                    return
            filename, line, column = parameters.unpack()
            expression = f"vimtex#view#inverse_search({line}, '{filename.replace(chr(39), chr(39) * 2)}', {column})"
            subprocess.run([nvim, "--server", server, "--remote-expr", expression],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
            desktop.focus_editor()

        if state["owned"]:
            bus.connection.signal_subscribe(state["name"], INTERFACE, "Edit", OBJECT, None,
                                            Gio.DBusSignalFlags.NONE, inverse, None)
        context = GLib.MainContext.default()
        last_check = time.monotonic()
        pending = b""
        while True:
            while context.pending():
                context.iteration(False)
            ready, _, _ = select.select([sys.stdin], [], [], 0.1)
            if ready:
                chunk = os.read(sys.stdin.fileno(), 65536)
                if not chunk:
                    break
                pending += chunk
                while b"\n" in pending:
                    line, pending = pending.split(b"\n", 1)
                    position = json.loads(line)
                    bus.call(state["name"], OBJECT, INTERFACE, "SynctexView", GLib.Variant(
                        "(suu)", (position["file"], position["line"], position["column"])))
                    desktop.focus_editor()
            if time.monotonic() - last_check >= 1:
                last_check = time.monotonic()
                if not bus.matches(state, pdf):
                    break
    finally:
        try:
            release(bus, registry, pdf)
        finally:
            desktop.restore_terminal()


if __name__ == "__main__":
    def terminate(_signal, _frame):
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, terminate)
    signal.signal(signal.SIGHUP, terminate)
    try:
        watch(os.path.realpath(sys.argv[1]), sys.argv[2], sys.argv[3], int(sys.argv[4]))
    except (RuntimeError, OSError, GLib.Error, subprocess.SubprocessError) as error:
        print(f"TeX viewer: {error}", file=sys.stderr)
        sys.exit(1)
