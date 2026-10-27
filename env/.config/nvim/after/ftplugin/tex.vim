" Only load this plugin it has not yet been loaded for this buffer
" Note that using b:did_ftplugin would disable vimtex
if exists("b:did_mytexplugin")
  finish
endif
let b:did_mytexplugin = 1

let g:tex_flavor = 'latex'  " recognize tex files as latex

" set indentation
setlocal expandtab
setlocal autoindent
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" Turn off automatic indenting in enumerated environments
let g:tex_indent_items=0

" Compilation
noremap <buffer> <leader><CR> <Cmd>update<CR><Cmd>VimtexCompileSS<CR>

" DEFINE MAPPINGS
" ---------------------------------------------
nmap <buffer> dse <plug>(vimtex-env-delete)
nmap <buffer> dsc <plug>(vimtex-cmd-delete)
nmap <buffer> dsm <plug>(vimtex-env-delete-math)
nmap <buffer> dsd <plug>(vimtex-delim-delete)
nmap <buffer> cse <plug>(vimtex-env-change)
nmap <buffer> csc <plug>(vimtex-cmd-change)
nmap <buffer> csm <plug>(vimtex-env-change-math)
nmap <buffer> csd <plug>(vimtex-delim-change-math)
nmap <buffer> tsf <plug>(vimtex-cmd-toggle-frac)
nmap <buffer> tsc <plug>(vimtex-cmd-toggle-star)
nmap <buffer> tse <plug>(vimtex-env-toggle-star)
nmap <buffer> tsd <plug>(vimtex-delim-toggle-modifier)
nmap <buffer> tsD <plug>(vimtex-delim-toggle-modifier-reverse)
imap <buffer> ]] <plug>(vimtex-delim-close)

" Text objects in operator-pending mode
" Buffer-local mappings override the global Tree-sitter mappings.
omap <buffer> ac <plug>(vimtex-ac)
xmap <buffer> ac <plug>(vimtex-ac)
omap <buffer> ic <plug>(vimtex-ic)
xmap <buffer> ic <plug>(vimtex-ic)

omap <buffer> ad <plug>(vimtex-ad)
xmap <buffer> ad <plug>(vimtex-ad)
omap <buffer> id <plug>(vimtex-id)
xmap <buffer> id <plug>(vimtex-id)

omap <buffer> ae <plug>(vimtex-ae)
xmap <buffer> ae <plug>(vimtex-ae)
omap <buffer> ie <plug>(vimtex-ie)
xmap <buffer> ie <plug>(vimtex-ie)

omap <buffer> am <plug>(vimtex-a$)
xmap <buffer> am <plug>(vimtex-a$)
omap <buffer> im <plug>(vimtex-i$)
xmap <buffer> im <plug>(vimtex-i$)

omap <buffer> aP <plug>(vimtex-aP)
xmap <buffer> aP <plug>(vimtex-aP)
omap <buffer> iP <plug>(vimtex-iP)
xmap <buffer> iP <plug>(vimtex-iP)

omap <buffer> ai <plug>(vimtex-am)
xmap <buffer> ai <plug>(vimtex-am)
omap <buffer> ii <plug>(vimtex-im)
xmap <buffer> ii <plug>(vimtex-im)

" nvo mode mappings
map <buffer> %  <plug>(vimtex-%)
map <buffer> ]] <plug>(vimtex-]])
map <buffer> ][ <plug>(vimtex-][)
map <buffer> [] <plug>(vimtex-[])
map <buffer> [[ <plug>(vimtex-[[)

map <buffer> ]m <plug>(vimtex-]m)
map <buffer> ]M <plug>(vimtex-]M)
map <buffer> [m <plug>(vimtex-[m)
map <buffer> [M <plug>(vimtex-[M)

map <buffer> ]n <plug>(vimtex-]n)
map <buffer> ]N <plug>(vimtex-]N)
map <buffer> [n <plug>(vimtex-[n)
map <buffer> [N <plug>(vimtex-[N)

map <buffer> ]r <plug>(vimtex-]r)
map <buffer> ]R <plug>(vimtex-]R)
map <buffer> [r <plug>(vimtex-[r)
map <buffer> [R <plug>(vimtex-[R)

map <buffer> ]/ <plug>(vimtex-]/)
map <buffer> ]* <plug>(vimtex-]*)
map <buffer> [/ <plug>(vimtex-[/)
map <buffer> [* <plug>(vimtex-[*)
