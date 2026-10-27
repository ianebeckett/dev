"""Test GNOME setup without changing desktop settings or installing extensions."""

from contextlib import redirect_stdout
import importlib.util
import io
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import patch


class BusError(Exception):
    pass


# The test suite remains runnable without the platform's PyGObject package.
repository = types.ModuleType('gi.repository')
repository.Gio = types.SimpleNamespace()
repository.GLib = types.SimpleNamespace(Error=BusError)
spec = importlib.util.spec_from_file_location('configure_tex', Path(__file__).resolve().parents[1] / 'lib/configure_tex.py')
config = importlib.util.module_from_spec(spec)
with patch.dict(sys.modules, {'gi': types.ModuleType('gi'), 'gi.repository': repository}):
    spec.loader.exec_module(config)


class Session:
    def __init__(self):
        self.extensions = {config.DING: {'state': 1}}
        self.calls = []
        self.install_result = 'successful'
        self.enable_result = True
        self.global_enabled = True
        self.interfaces_checked = False

    def extension(self, method, uuid, timeout=5000):
        self.calls.append((method, uuid))
        if method == 'GetExtensionInfo':
            return (self.extensions.get(uuid, {}).copy(),)
        if method == 'InstallRemoteExtension':
            if self.install_result == 'successful':
                self.extensions[uuid] = {'state': 1}
            return (self.install_result,)
        if method == 'EnableExtension':
            if self.enable_result:
                self.extensions[uuid] = {'state': 1}
            return (self.enable_result,)
        raise AssertionError(method)

    def shell_running(self):
        return True

    def user_extensions_enabled(self):
        return self.global_enabled

    def check_interfaces(self):
        self.interfaces_checked = True


class TexConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.session = Session()
        tools = patch.object(config.shutil, 'which', return_value='/usr/bin/tool')
        tools.start()
        self.addCleanup(tools.stop)
        output = redirect_stdout(io.StringIO())
        output.__enter__()
        self.addCleanup(output.__exit__, None, None, None)

    def configure(self, check_only=False):
        config.configure(self.session, check_only)

    def mutations(self):
        return [call for call in self.session.calls if call[0] != 'GetExtensionInfo']

    def test_fresh_install_and_repeat(self):
        self.configure()
        self.assertEqual(self.mutations(), [('InstallRemoteExtension', config.WINDOW_CALLS)])
        self.assertTrue(self.session.interfaces_checked)
        self.session.calls.clear()
        self.configure()
        self.assertEqual(self.mutations(), [])

    def test_installed_disabled_extensions_are_enabled_without_reinstall(self):
        self.session.extensions = {config.DING: {'state': 2}, config.WINDOW_CALLS: {'state': 2}}
        self.configure()
        self.assertEqual(self.mutations(), [('EnableExtension', config.DING),
                                           ('EnableExtension', config.WINDOW_CALLS)])

    def test_cancelled_install_can_be_retried(self):
        self.session.install_result = 'cancelled'
        with self.assertRaisesRegex(RuntimeError, 'cancelled'):
            self.configure()
        self.assertFalse(self.session.interfaces_checked)
        self.session.install_result = 'successful'
        self.configure()
        self.assertTrue(self.session.interfaces_checked)

    def test_new_system_extension_requires_session_restart(self):
        self.session.extensions.clear()
        with self.assertRaisesRegex(RuntimeError, 'log out and back in'):
            self.configure()
        self.assertEqual(self.mutations(), [])

    def test_global_disable_is_not_overridden(self):
        self.session.global_enabled = False
        with self.assertRaisesRegex(RuntimeError, 'globally disabled'):
            self.configure()
        self.assertEqual(self.session.calls, [])

    def test_incompatible_installed_extension_is_not_silently_upgraded(self):
        self.session.extensions[config.WINDOW_CALLS] = {'state': 4}
        with self.assertRaisesRegex(RuntimeError, 'incompatible'):
            self.configure()
        self.assertEqual(self.mutations(), [])

    def test_check_mode_never_installs_or_enables(self):
        with self.assertRaisesRegex(RuntimeError, 'missing'):
            self.configure(check_only=True)
        self.session.extensions[config.WINDOW_CALLS] = {'state': 2}
        with self.assertRaisesRegex(RuntimeError, 'not active'):
            self.configure(check_only=True)
        self.assertEqual(self.mutations(), [])
        self.session.extensions[config.WINDOW_CALLS] = {'state': 1}
        self.configure(check_only=True)
        self.assertTrue(self.session.interfaces_checked)
        self.assertEqual(self.mutations(), [])

    def test_enable_failure_is_reported(self):
        self.session.extensions[config.WINDOW_CALLS] = {'state': 2}
        self.session.enable_result = False
        with self.assertRaisesRegex(RuntimeError, 'could not enable'):
            self.configure()

    def test_missing_package_stops_before_extension_mutation(self):
        with patch.object(config.shutil, 'which', return_value=None):
            with self.assertRaisesRegex(RuntimeError, 'runs/install_packages'):
                self.configure()
        self.assertEqual(self.session.calls, [])

    def test_headless_setup_is_deferred_but_check_fails(self):
        with patch.dict(config.os.environ, XDG_CURRENT_DESKTOP=''), \
             patch.object(config, 'Session') as connect:
            with patch.object(sys, 'argv', ['configure_tex.py']):
                self.assertEqual(config.main(), 0)
            with patch.object(sys, 'argv', ['configure_tex.py', '--check']):
                self.assertEqual(config.main(), 1)
            connect.assert_not_called()

    def test_gnome_session_check_is_read_only(self):
        self.session.extensions[config.WINDOW_CALLS] = {'state': 1}
        with patch.dict(config.os.environ, XDG_CURRENT_DESKTOP='ubuntu:GNOME'), \
             patch.object(config, 'Session', return_value=self.session), \
             patch.object(sys, 'argv', ['configure_tex.py', '--check']):
            self.assertEqual(config.main(), 0)
        self.assertTrue(self.session.interfaces_checked)
        self.assertEqual(self.mutations(), [])


if __name__ == '__main__':
    unittest.main()
