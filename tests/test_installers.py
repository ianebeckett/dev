"""Exercise installers with fake package managers and an isolated child-process home.

Run with: python3 -m unittest discover -s tests -v
No downloads, sudo commands, or real package installations are performed.
"""

import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
MOCK = r'''
import json
import os
from pathlib import Path
import shutil
import sys

root = Path(os.environ['DEV_TEST_ROOT'])
state_file = root / 'state.json'
state = json.loads(state_file.read_text())
name = Path(sys.argv[0]).name
args = sys.argv[1:]
with (root / 'calls').open('a') as log:
    log.write(json.dumps([name, *args]) + '\n')
if os.environ.get('DEV_TEST_FAIL') == name:
    sys.exit(42)

def save():
    state_file.write_text(json.dumps(state))

def executable(name, directory=None):
    target = (directory or root / 'bin') / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(root / 'mock', target)
    target.chmod(0o755)

def install(package):
    if package in state['packages']:
        return
    state['packages'].append(package)
    commands = {
        'nodejs': ['node'], 'node': ['node', 'npm'], 'npm': ['npm'],
        'ruby': ['ruby', 'gem'], 'python3': ['python3'], 'python': ['python3'],
        'clangd': ['clangd'], 'llvm': ['clangd'], 'uv': ['uv'],
        'lua-language-server': ['lua-language-server'],
    }
    for command in commands.get(package, []):
        executable(command)
    save()

if name == 'sudo':
    if args[0] == 'apt-get' and args[1] == 'install':
        assert args[2:4] == ['-y', '--no-upgrade']
        for package in args[4:]:
            install(package)
    elif args[:2] != ['apt-get', 'update'] and args[0] != 'sed':
        raise RuntimeError(args)
elif name == 'brew':
    assert args[0] in ('install', 'update')
    if args[0] == 'install':
        assert os.environ['HOMEBREW_NO_INSTALL_UPGRADE'] == '1'
        for package in args[1:]:
            install(package)
elif name == 'uname':
    print(os.environ.get('DEV_TEST_ARCH', 'x86_64'))
elif name == 'curl':
    if os.environ.get('DEV_TEST_FAIL') == 'download':
        sys.exit(22)
    url = next(arg for arg in args if arg.startswith('https://'))
    if 'Homebrew' in url:
        print('#!/bin/sh\nexec "$DEV_TEST_ROOT/bin/installer" brew')
    else:
        target = Path(args[args.index('-o') + 1])
        if url.endswith('uv/install.sh'):
            target.write_text('#!/bin/sh\nexec "$DEV_TEST_ROOT/bin/installer" uv\n')
        else:
            shutil.copyfile(root / 'luals.tar.gz', target)
elif name == 'installer':
    if args[0] == 'uv':
        assert os.environ['UV_NO_MODIFY_PATH'] == '1'
        executable('uv', Path(os.environ['UV_INSTALL_DIR']))
    else:
        assert os.environ['NONINTERACTIVE'] == '1'
        executable('brew')
elif name == 'sha256sum':
    checksum = sys.stdin.read().split()[0]
    expected = {
        'x86_64': 'e9235d2d72ef55bc41cf8c99cda2ed64777682024b4bb81f5dea425060c5cbb8',
        'aarch64': 'abd2572e8fc929dc838a81ffb8473c5bce0bf39bfe8edb4b120b3b623176ce83',
    }
    assert checksum == expected[os.environ.get('DEV_TEST_ARCH', 'x86_64')]
    sys.exit(1 if os.environ.get('DEV_TEST_FAIL') == 'checksum' else 0)
elif name == 'npm':
    assert args[:2] == ['install', '--global']
    assert args[-2:] == ['vscode-langservers-extracted@4.10.0', 'quick-lint-js@3.2.0']
    executable('vscode-json-language-server', Path(args[args.index('--prefix') + 1]) / 'bin')
    executable('quick-lint-js', Path(args[args.index('--prefix') + 1]) / 'bin')
    state['json_server'] = args[-2]
    state['quick_lint_js'] = args[-1]
    save()
elif name == 'gem':
    assert args[:2] == ['install', 'ruby-lsp']
    assert all(flag in args for flag in ('--conservative', '--user-install', '--no-document'))
    if not state.get('ruby_lsp'):
        executable('ruby-lsp', Path(args[args.index('--bindir') + 1]))
        state['ruby_lsp'] = True
        save()
elif name == 'uv':
    assert args == ['tool', 'install', 'basedpyright']
    if not state.get('basedpyright'):
        executable('basedpyright-langserver', Path(os.environ['UV_TOOL_BIN_DIR']))
        state['basedpyright'] = True
        save()
elif name == 'ruby':
    print('ruby 3.3.0')
'''


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dev-installer-tests-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = {
            'HOME': str(self.root / 'home'),
            'PATH': str(self.bin),
            'TMPDIR': str(self.root),
            'DEV_TEST_ROOT': str(self.root),
            'OSTYPE': 'linux-gnu',
        }
        (self.root / 'state.json').write_text(json.dumps({'packages': []}))
        (self.root / 'calls').touch()
        (self.root / 'mock').write_text(f'#!{sys.executable}\n' + MOCK)
        for command in ('sudo', 'uname', 'curl', 'installer', 'sha256sum'):
            self.mock(command)
        for command in ('bash', 'sh', 'dirname', 'mkdir', 'mktemp', 'rm', 'cp', 'tar', 'gzip'):
            (self.bin / command).symlink_to(shutil.which(command))
        with tarfile.open(self.root / 'luals.tar.gz', 'w:gz') as archive:
            contents = b'#!/bin/sh\necho "LuaLS test release"\n'
            entry = tarfile.TarInfo('bin/lua-language-server')
            entry.mode = 0o755
            entry.size = len(contents)
            archive.addfile(entry, io.BytesIO(contents))

    def mock(self, command):
        shutil.copyfile(self.root / 'mock', self.bin / command)
        (self.bin / command).chmod(0o755)

    def run_script(self, script, *args, success=True):
        result = subprocess.run(
            ['/bin/bash', str(REPO / script), *args], env=self.env,
            cwd=self.root, capture_output=True, text=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def calls(self):
        return [json.loads(line) for line in (self.root / 'calls').read_text().splitlines()]

    def clear_calls(self):
        (self.root / 'calls').write_text('')

    def assert_repeat_install(self):
        state_before = (self.root / 'state.json').read_text()
        self.clear_calls()
        self.run_script('runs/install_packages')
        self.run_script('runs/install_language_servers')
        self.assertEqual((self.root / 'state.json').read_text(), state_before)
        self.assertFalse(any(c[0] == 'curl' for c in self.calls()))
        # Repeated invocations delegate installed-state decisions to each manager.
        for command in ('npm', 'gem', 'uv'):
            self.assertEqual(sum(c[0] == command for c in self.calls()), 1)
        system_installs = [
            c for c in self.calls()
            if c[:3] == ['sudo', 'apt-get', 'install'] or c[:2] == ['brew', 'install']
        ]
        self.assertEqual(len(system_installs), 1)

    def test_fresh_ubuntu_and_repeat(self):
        self.run_script('runs/install_packages')
        self.run_script('runs/install_language_servers')
        calls = self.calls()
        self.assertTrue(any(c[:3] == ['sudo', 'apt-get', 'install'] for c in calls))
        for command in ('npm', 'gem', 'uv'):
            self.assertTrue(any(c[0] == command and 'install' in c for c in calls))
        self.assertTrue((self.root / 'home/.local/lua-language-server/bin/lua-language-server').is_file())
        self.assert_repeat_install()

    def test_linux_arm64_release(self):
        self.env['DEV_TEST_ARCH'] = 'aarch64'
        self.run_script('runs/install_packages')
        self.run_script('runs/install_language_servers')
        self.assertTrue(any('linux-arm64.tar.gz' in ' '.join(c) for c in self.calls()))

    def test_download_failure_is_retryable(self):
        self.run_script('runs/install_packages')
        self.env['DEV_TEST_FAIL'] = 'download'
        self.run_script('runs/install_language_servers', success=False)
        self.assertFalse(any(c[0] in ('npm', 'gem', 'uv') for c in self.calls()))
        del self.env['DEV_TEST_FAIL']
        self.run_script('runs/install_language_servers')
        self.assertFalse(list(self.root.glob('dev-language-servers.*')))

    def test_bad_checksum_does_not_install_luals(self):
        self.run_script('runs/install_packages')
        self.env['DEV_TEST_FAIL'] = 'checksum'
        self.run_script('runs/install_language_servers', success=False)
        self.assertFalse((self.root / 'home/.local/lua-language-server').exists())
        self.assertFalse(any(c[0] == 'npm' for c in self.calls()))

    def test_package_manager_failure_stops_later_installs(self):
        self.run_script('runs/install_packages')
        self.env['DEV_TEST_FAIL'] = 'npm'
        result = self.run_script('runs/install_language_servers', success=False)
        self.assertEqual(result.returncode, 42)
        self.assertFalse(any(c[0] in ('gem', 'uv') for c in self.calls()))

    def test_changed_ruby_installs_gem_again(self):
        self.run_script('runs/install_packages')
        self.run_script('runs/install_language_servers')
        state_file = self.root / 'state.json'
        state = json.loads(state_file.read_text())
        state['ruby_lsp'] = False
        state_file.write_text(json.dumps(state))
        self.clear_calls()
        self.run_script('runs/install_language_servers')
        self.assertTrue(json.loads(state_file.read_text())['ruby_lsp'])
        self.assertTrue(any(c[:3] == ['gem', 'install', 'ruby-lsp'] for c in self.calls()))

    def test_macos_bootstrap_and_repeat(self):
        self.env['OSTYPE'] = 'darwin'
        self.run_script('runs/install_packages')
        self.run_script('runs/install_language_servers')
        packages = json.loads((self.root / 'state.json').read_text())['packages']
        for package in ('node', 'ruby', 'uv', 'llvm', 'lua-language-server', 'fd'):
            self.assertIn(package, packages)
        self.assertNotIn('clang', packages)
        self.assertNotIn('fd-find', packages)
        self.assert_repeat_install()

    def test_runner_dry_run_from_other_directory(self):
        result = self.run_script('runner', '--dry-run')
        self.assertIn('Would run: ./runs/install_language_servers', result.stdout)
        self.assertIn('Would run: ./runs/configure/neovim', result.stdout)
        self.assertEqual(self.calls(), [])

    def test_macos_arm64_bootstrap_and_repeat(self):
        self.env['DEV_TEST_ARCH'] = 'arm64'
        self.test_macos_bootstrap_and_repeat()

    def runner_fixture(self):
        checkout = self.root / 'checkout'
        (checkout / 'env/.config/zsh').mkdir(parents=True)
        (checkout / 'env/.config/zsh/.zshenv').write_text('')
        shutil.copyfile(REPO / 'runner', checkout / 'runner')
        scripts = [
            'runs/install_packages', 'runs/install_language_servers',
            'runs/configure/neovim',
        ]
        for script in scripts:
            path = checkout / script
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(
                '#!/bin/bash\n'
                f'echo "{script}" >> "$DEV_TEST_ROOT/order"\n'
                f'if [[ "${{DEV_TEST_FAIL_STEP:-}}" == "{script}" ]]; then exit 42; fi\n'
            )
            path.chmod(0o755)
        return checkout / 'runner', scripts

    def test_runner_installs_before_configuring(self):
        runner, scripts = self.runner_fixture()
        self.run_script(runner)
        self.assertEqual((self.root / 'order').read_text().splitlines(), scripts)

    def test_runner_stops_after_install_failure(self):
        runner, scripts = self.runner_fixture()
        self.env['DEV_TEST_FAIL_STEP'] = 'runs/install_language_servers'
        result = self.run_script(runner, success=False)
        self.assertEqual(result.returncode, 42)
        self.assertEqual((self.root / 'order').read_text().splitlines(), scripts[:2])


if __name__ == '__main__':
    unittest.main()
