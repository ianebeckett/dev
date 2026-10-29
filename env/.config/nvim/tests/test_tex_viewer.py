"""Geometry regressions; run with python3 -B -m unittest discover -s tests."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location(
    'tex_viewer', Path(__file__).resolve().parents[1] / 'scripts' / 'tex-viewer.py')
viewer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(viewer)


def monitor(index, x, y, width, height, left=0, top=0, right=0, bottom=0, scale=1):
    return dict(monitorIndex=index, x=x, y=y, width=width, height=height,
                marginLeft=left, marginTop=top, marginRight=right,
                marginBottom=bottom, scaleFactor=scale)


class DesktopBus:
    def __init__(self, monitors, selected, workarea):
        self.monitors = monitors
        self.monitor = next(m for m in monitors if m['monitorIndex'] == selected)
        self.workarea = workarea
        self.frames = {}
        self.focus = 1
        self.maximized = []
        self.windows = [dict(id=1, pid=100, workspace=0, in_current_workspace=True),
                        dict(id=2, pid=200, workspace=0, in_current_workspace=True)]

    def owner(self, name):
        return ':shell.test'

    def call(self, destination, path, interface, method, parameters=None):
        args = parameters.unpack() if parameters else ()
        if method == 'List':
            return (json.dumps([{**w, 'focus': w['id'] == self.focus} for w in self.windows]),)
        if method == 'Details':
            m = self.monitor
            return (json.dumps(dict(monitor=m['monitorIndex'],
                                    **{k: m[k] for k in ('x', 'y', 'width', 'height')})),)
        if method == 'Describe':
            return ((True, 'av', [self.monitors]),)
        if method == 'MoveResize':
            self.frames[args[0]] = dict(zip(('x', 'y', 'width', 'height'), args[1:]))
        elif method == 'GetFrameRect':
            return (json.dumps(self.frames[args[0]]),)
        elif method == 'Activate':
            self.focus = args[0]
        elif method == 'Maximize':
            self.maximized.append(args[0])
        elif method != 'MoveToWorkspace':
            raise AssertionError(method)
        return ()

    def run(self, *args):
        if args[0] == 'xrandr':
            return '\n'.join(f" {i}: +DP {m['width']}/310x{m['height']}/170{m['x']:+}{m['y']:+} DP"
                             for i, m in enumerate(self.monitors))
        if args[-1] == '_NET_WORKAREA':
            return '_NET_WORKAREA(CARDINAL) = ' + ', '.join(map(str, self.workarea))
        raise AssertionError(args)


class ViewerTestCase(unittest.TestCase):
    def setUp(self):
        runtime = tempfile.TemporaryDirectory(prefix='tex-viewer-tests-')
        self.addCleanup(runtime.cleanup)
        environment = patch.dict(viewer.os.environ, XDG_RUNTIME_DIR=runtime.name)
        environment.start()
        self.addCleanup(environment.stop)
        self.dock_settings = Mock()
        self.dock_settings.get_boolean.return_value = True
        self.dock_settings.get_string.return_value = 'LEFT'
        schemas = patch.object(viewer.Gio.SettingsSchemaSource, 'get_default')
        self.schemas = schemas.start().return_value
        self.addCleanup(schemas.stop)
        settings = patch.object(viewer.Gio.Settings, 'new_full', return_value=self.dock_settings)
        settings.start()
        self.addCleanup(settings.stop)


class LayoutTests(ViewerTestCase):
    def check_layout(self, monitors, selected, workarea, terminal, pdf):
        bus = DesktopBus(monitors, selected, workarea)
        with patch.object(viewer, 'editor_processes', return_value={100}), \
             patch.object(viewer, 'run', side_effect=bus.run), \
             patch.object(viewer.time, 'sleep'):
            viewer.Desktop(bus, 100).arrange(200)
        self.assertEqual(bus.frames[1], dict(zip(('x', 'y', 'width', 'height'), terminal)))
        self.assertEqual(bus.frames[2], dict(zip(('x', 'y', 'width', 'height'), pdf)))
        self.assertEqual(bus.focus, 1)

    def test_undocked_laptop_keeps_physical_midpoint(self):
        # Captured after undocking: the global work area includes the dock.
        self.check_layout([monitor(0, 0, 0, 1920, 1080, left=67, top=32)], 0,
                          (67, 32, 1853, 1048), (67, 32, 893, 1048), (960, 32, 960, 1048))

    def test_docked_external_uses_its_own_offset_and_dock(self):
        # Captured while docked: GNOME index 0 is the monitor on the right.
        monitors = [monitor(0, 1920, 0, 1920, 1080, left=67, top=32),
                    monitor(1, 0, 0, 1920, 1080)]
        self.check_layout(monitors, 0, (0, 32, 3840, 1048),
                          (1987, 32, 893, 1048), (2880, 32, 960, 1048))

    def test_docked_laptop_does_not_inherit_external_panel(self):
        monitors = [monitor(0, 1920, 0, 1920, 1080, left=67, top=32),
                    monitor(1, 0, 0, 1920, 1080)]
        self.check_layout(monitors, 1, (0, 32, 3840, 1048),
                          (0, 0, 960, 1080), (960, 0, 960, 1080))

    def test_changed_monitor_ids_resolution_and_scale(self):
        monitors = [monitor(7, -1600, 200, 1600, 900, left=51, top=28, scale=2),
                    monitor(3, 0, 0, 2560, 1440)]
        self.check_layout(monitors, 7, (-1600, 0, 4160, 1440),
                          (-1549, 228, 749, 872), (-800, 228, 800, 872))

    def test_hidden_left_dock_uses_screen_edge_and_preserves_panel(self):
        self.dock_settings.get_boolean.return_value = False
        self.check_layout([monitor(0, 0, 0, 1920, 1080, left=70, top=32)], 0,
                          (0, 32, 1920, 1048), (0, 32, 960, 1048), (960, 32, 960, 1048))

    def test_hidden_dock_on_offset_monitor_uses_its_own_edge(self):
        self.dock_settings.get_boolean.return_value = False
        monitors = [monitor(0, 1920, 0, 1920, 1080, left=70, top=32),
                    monitor(1, 0, 0, 1920, 1080)]
        self.check_layout(monitors, 0, (0, 32, 3840, 1048),
                          (1920, 32, 960, 1048), (2880, 32, 960, 1048))
        self.check_layout(monitors, 1, (0, 32, 3840, 1048),
                          (0, 0, 960, 1080), (960, 0, 960, 1080))

    def test_hidden_right_and_bottom_docks(self):
        self.dock_settings.get_boolean.return_value = False
        for side in ('RIGHT', 'BOTTOM'):
            with self.subTest(side=side):
                self.dock_settings.get_string.return_value = side
                margins = {side.lower(): 70, 'top': 32}
                self.check_layout([monitor(0, 0, 0, 1920, 1080, **margins)], 0,
                                  (), (0, 32, 960, 1048), (960, 32, 960, 1048))

    def test_top_panel_margin_is_not_discarded(self):
        self.dock_settings.get_boolean.return_value = False
        self.dock_settings.get_string.return_value = 'TOP'
        self.check_layout([monitor(0, 0, 0, 1920, 1080, top=70)], 0,
                          (), (0, 70, 960, 1010), (960, 70, 960, 1010))

    def test_missing_dock_schema_preserves_reported_margins(self):
        self.schemas.lookup.return_value = None
        self.check_layout([monitor(0, 0, 0, 1920, 1080, left=67, top=32)], 0,
                          (), (67, 32, 893, 1048), (960, 32, 960, 1048))


class TerminalCleanupTests(ViewerTestCase):
    def make_desktop(self, bus, pid):
        with patch.object(viewer, 'editor_processes', return_value={100}), \
             patch.object(viewer.os, 'getpid', return_value=pid), \
             patch.object(viewer.time, 'sleep'):
            desktop = viewer.Desktop(bus, 100)
            desktop.arrange(200)
            return desktop

    def bus(self):
        return DesktopBus([monitor(0, 0, 0, 1920, 1080, left=67, top=32)], 0, ())

    def test_only_last_document_restores_terminal(self):
        bus = self.bus()
        with patch.object(viewer, 'identity', return_value='live'):
            first = self.make_desktop(bus, 11)
            second = self.make_desktop(bus, 12)
            with patch.object(viewer.os, 'getpid', return_value=11):
                first.restore_terminal()
            self.assertEqual(bus.maximized, [])
            with patch.object(viewer.os, 'getpid', return_value=12):
                second.restore_terminal()
                second.restore_terminal()
            self.assertEqual(bus.maximized, [1])

    def test_closed_terminal_is_not_replaced_with_another_window(self):
        bus = self.bus()
        with patch.object(viewer, 'identity', return_value='live'):
            desktop = self.make_desktop(bus, 11)
            bus.windows[0]['pid'] = 999  # The captured terminal is gone.
            with patch.object(viewer.os, 'getpid', return_value=11):
                desktop.restore_terminal()
            self.assertEqual(bus.maximized, [])

    def test_dead_helper_does_not_prevent_restoration(self):
        bus = self.bus()
        with patch.object(viewer, 'identity', return_value='live'):
            first = self.make_desktop(bus, 11)
            self.make_desktop(bus, 12)
        with patch.object(viewer, 'identity', side_effect=lambda pid: 'live' if str(pid) == '11' else None), \
             patch.object(viewer.os, 'getpid', return_value=11):
            first.restore_terminal()
        self.assertEqual(bus.maximized, [1])


if __name__ == '__main__':
    unittest.main()
