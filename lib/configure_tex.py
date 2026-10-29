"""Configure the TeX viewer's GNOME dependencies in the current user's session."""

import argparse
import os
import shutil
import sys
import time

from gi.repository import Gio, GLib

SHELL = 'org.gnome.Shell'
EXTENSIONS = 'org.gnome.Shell.Extensions'
DING = 'ding@rastersoft.com'
WINDOW_CALLS = 'window-calls@domandoman.xyz'
RERUN = './runs/configure/tex'


class Session:
    def __init__(self):
        self.bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

    def call(self, destination, path, interface, method, signature=None, values=(), timeout=5000):
        arguments = GLib.Variant(signature, values) if signature else None
        return self.bus.call_sync(destination, path, interface, method, arguments, None,
                                  Gio.DBusCallFlags.NONE, timeout, None).unpack()

    def shell_running(self):
        return self.call('org.freedesktop.DBus', '/org/freedesktop/DBus',
                         'org.freedesktop.DBus', 'NameHasOwner', '(s)', (SHELL,))[0]

    def extension(self, method, uuid, timeout=5000):
        return self.call(SHELL, '/org/gnome/Shell', EXTENSIONS, method, '(s)', (uuid,), timeout)

    def user_extensions_enabled(self):
        return self.call(SHELL, '/org/gnome/Shell', 'org.freedesktop.DBus.Properties',
                         'Get', '(ss)', (EXTENSIONS, 'UserExtensionsEnabled'))[0]

    def check_interfaces(self):
        # Check the exact interfaces the viewer helper consumes, without changing windows.
        self.call(SHELL, '/org/gnome/Shell/Extensions/Windows',
                  'org.gnome.Shell.Extensions.Windows', 'List')
        description = self.call('com.rastersoft.dingextension', '/com/rastersoft/dingextension/control',
                                'org.gtk.Actions', 'Describe', '(s)', ('desktopGeometry',))[0]
        if not description[0] or not description[2] or not description[2][0]:
            raise RuntimeError('Desktop Icons NG has not reported monitor geometry yet; rerun ' + RERUN)


def ensure_extension(session, uuid, check_only=False):
    info = session.extension('GetExtensionInfo', uuid)[0]
    if not info:
        if check_only:
            raise RuntimeError(f'{uuid} is missing; run {RERUN}')
        if uuid == DING:
            raise RuntimeError('Desktop Icons NG was not discovered by GNOME. After installing the Ubuntu '
                               f'extension package, log out and back in, then rerun {RERUN}.')
        print('Installing Window Calls from extensions.gnome.org; accept GNOME’s installation dialog.', flush=True)
        result = session.extension('InstallRemoteExtension', uuid, timeout=180000)[0]
        if result != 'successful':
            raise RuntimeError(f'Window Calls installation returned {result!r}; rerun {RERUN} to retry')
        info = session.extension('GetExtensionInfo', uuid)[0]
    if info.get('state') == 1:
        print(f'{uuid}: enabled')
        return
    if info.get('state') == 4:
        raise RuntimeError(f'{uuid} is incompatible with this GNOME version; install a compatible release')
    if check_only:
        raise RuntimeError(f'{uuid} is not active; run {RERUN}')
    if not session.extension('EnableExtension', uuid)[0]:
        raise RuntimeError(f'GNOME could not enable {uuid}; log out and back in, then rerun {RERUN}')
    for _ in range(40):
        info = session.extension('GetExtensionInfo', uuid)[0]
        if info.get('state') == 1:
            print(f'{uuid}: enabled')
            return
        if info.get('state') in (3, 4):
            break
        time.sleep(0.25)
    raise RuntimeError(f'{uuid} did not become active: {info.get("error") or "check the GNOME Extensions app"}')


def configure(session, check_only=False):
    missing = [name for name in ('nvim', 'tmux', 'latexmk', 'pdflatex', 'zathura') if not shutil.which(name)]
    if missing:
        raise RuntimeError('Missing tools: ' + ', '.join(missing) + '; run ./runs/install_packages first')
    if not session.user_extensions_enabled():
        raise RuntimeError('GNOME user extensions are globally disabled. Enable them in the Extensions app, '
                           f'then rerun {RERUN}.')
    ensure_extension(session, DING, check_only)
    ensure_extension(session, WINDOW_CALLS, check_only)
    session.check_interfaces()
    print('TeX desktop setup ready: VimTeX/LuaSnip load from the linked Neovim config on first startup.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='check dependencies without installing or enabling extensions')
    args = parser.parse_args()
    desktops = os.environ.get('XDG_CURRENT_DESKTOP', '').lower().split(':')
    if 'gnome' not in desktops:
        print(f'TeX desktop setup deferred: log into GNOME and run {RERUN}.')
        return 1 if args.check else 0
    try:
        session = Session()
        if not session.shell_running():
            print(f'TeX desktop setup deferred: no running GNOME Shell; run {RERUN} in a GNOME session.')
            return 1 if args.check else 0
    except GLib.Error:
        print(f'TeX desktop setup deferred: no accessible session bus; run {RERUN} in a GNOME session.')
        return 1 if args.check else 0
    try:
        configure(session, args.check)
    except (RuntimeError, GLib.Error) as error:
        print(f'TeX desktop setup failed: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
