let g:vimtex_imaps_enabled = 0
let g:vimtex_syntax_conceal_disable = 1

" Default is 500 lines and lags on missed key presses
let g:vimtex_delim_stopline = 5

" Don't open quickfix for warning messages if no errors are present
let g:vimtex_quickfix_open_on_warning = 0

" Filter out some compilation warning messages from QuickFix display
let g:vimtex_quickfix_ignore_filters = [
      \ 'Underfull \\hbox',
      \ 'Overfull \\hbox',
      \ 'LaTeX Warning: .\+ float specifier changed to',
      \ 'LaTeX hooks Warning',
      \ 'Package siunitx Warning: Detected the "physics" package:',
      \ 'Package hyperref Warning: Token not allowed in a PDF string',
      \]

"let g:vimtex_view_method = 'zathura'
"try this if the above is not working on wayland
let g:vimtex_view_method = 'zathura_simple'
"refs:
"https://ejmastnak.com/tutorials/vim-latex/pdf-reader/#zathura
"https://github.com/lervag/vimtex/pull/2639

" Don't automatically open PDF viewer after first compilation
let g:vimtex_view_automatic = 0

let g:vimtex_compiler_latexmk = {
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 0,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

