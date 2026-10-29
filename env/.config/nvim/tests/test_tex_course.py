"""Compile the reusable course template and check root detection without a GUI."""

import gzip
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / 'templates/tex-course'


class CourseTemplateTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix='tex-course-tests-')
        self.addCleanup(temp.cleanup)
        self.temp = Path(temp.name)
        self.course = self.temp / 'Course with spaces'
        shutil.copytree(TEMPLATE, self.course)
        self.env = {
            **os.environ,
            'TEXMFVAR': str(self.temp / 'texmf-var'),
            'TEXMFCONFIG': str(self.temp / 'texmf-config'),
            'XDG_CACHE_HOME': str(self.temp / 'cache'),
            'XDG_STATE_HOME': str(self.temp / 'state'),
            'NVIM_LOG_FILE': str(self.temp / 'nvim.log'),
        }

    def compile(self):
        result = subprocess.run(
            ['latexmk', '-pdf', '-synctex=1', '-interaction=nonstopmode', '-halt-on-error', 'main.tex'],
            cwd=self.course, env=self.env, text=True, capture_output=True, timeout=60,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertGreater((self.course / 'main.pdf').stat().st_size, 1000)
        log = (self.course / 'main.log').read_text()
        for warning in ('undefined references', 'multiply defined', 'destination with the same identifier',
                        'Undefined control sequence', 'Token not allowed in a PDF string'):
            self.assertNotIn(warning, log)
        return (self.course / 'main.aux').read_text()

    def label(self, aux, name):
        match = re.search(r'\\newlabel\{' + re.escape(name) + r'\}\{\{([^}]+)\}', aux)
        self.assertIsNotNone(match, f'Missing label {name}')
        return match.group(1)

    def test_template_compiles_with_resolved_references_and_synctex(self):
        aux = self.compile()
        self.assertEqual(self.label(aux, 'lec:probability'), '1')
        self.assertEqual(self.label(aux, 'def:indicator'), '1.1')
        self.assertEqual(self.label(aux, 'thm:markov'), '1.2')
        self.assertEqual(self.label(aux, 'eq:indicator-expectation'), '1.1')
        self.assertEqual(self.label(aux, 'alg:reservoir'), '1.1')
        self.assertIn('Probability basics', (self.course / 'main.toc').read_text())
        with gzip.open(self.course / 'main.synctex.gz', 'rt') as sync:
            self.assertIn('lecture-01.tex', sync.read())

    def test_numbering_resets_and_all_statement_environments_work(self):
        statements = ['theorem', 'lemma', 'proposition', 'corollary', 'claim',
                      'definition', 'example', 'exercise', 'remark']
        lines = [r'% !TeX root = ../main.tex', r'\lecture{2}{YYYY-MM-DD}{Second lecture}',
                 r'\label{lec:second}', r'Recall Theorem~\ref{thm:markov} from Lecture~\ref{lec:probability}.']
        for name in statements:
            lines += [rf'\begin{{{name}}}\label{{second:{name}}}A statement.\end{{{name}}}']
        lines += [
            r'\begin{proof}A proof.\end{proof}',
            r'\begin{equation}1=1\label{second:equation}\end{equation}',
            r'\begin{figure}[htbp]\centering\fbox{Figure placeholder}',
            r'\caption{A figure}\label{second:figure}\end{figure}',
            r'\begin{table}[htbp]\caption{A table}\label{second:table}',
            r'\centering\begin{tabular}{ll}\toprule Key & Value\\\midrule A & 1\\\bottomrule\end{tabular}\end{table}',
            r'\begin{algorithm}[htbp]\caption{A procedure}\label{second:algorithm}',
            r'\begin{algorithmic}[1]\State \Return $1$\end{algorithmic}\end{algorithm}',
        ]
        (self.course / 'lectures/lecture-02.tex').write_text('\n'.join(lines) + '\n')
        main = self.course / 'main.tex'
        main.write_text(main.read_text().replace(r'% \input{lectures/lecture-02}', r'\input{lectures/lecture-02}'))
        aux = self.compile()
        self.assertEqual(self.label(aux, 'lec:second'), '2')
        for number, name in enumerate(statements, 1):
            self.assertEqual(self.label(aux, f'second:{name}'), f'2.{number}')
        for name in ('equation', 'figure', 'table', 'algorithm'):
            self.assertEqual(self.label(aux, f'second:{name}'), '2.1')

    def test_opening_lecture_from_its_directory_targets_main_pdf(self):
        self.compile()
        script = self.temp / 'check-root.lua'
        script.write_text(r'''
local course = vim.env.TEX_COURSE_TEST_ROOT
local paths = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/vimtex', false, true)
assert(#paths > 0, 'Open your configured Neovim once to install VimTeX')
vim.opt.rtp = {paths[1], vim.env.VIMRUNTIME}
vim.g.vimtex_view_enabled = 0
vim.g.vimtex_cache_root = vim.env.TEX_COURSE_TEST_CACHE
vim.cmd('runtime plugin/vimtex.vim')
vim.cmd('filetype plugin indent on')
vim.cmd.edit('lecture-01.tex')
assert(vim.b.vimtex.tex == course .. '/main.tex', vim.inspect(vim.b.vimtex.tex))
assert(vim.fn.eval('b:vimtex.compiler.get_file("pdf")') == course .. '/main.pdf')
assert(vim.fn.eval('b:vimtex.compiler.is_running()') == false)
print('Lecture resolves to the main source and PDF')
vim.cmd('qa!')
''')
        env = {**self.env, 'TEX_COURSE_TEST_ROOT': str(self.course),
               'TEX_COURSE_TEST_CACHE': str(self.temp / 'vimtex')}
        result = subprocess.run(
            ['nvim', '--headless', '-u', 'NONE', '-i', 'NONE', '-l', str(script)],
            cwd=self.course / 'lectures', env=env, capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
