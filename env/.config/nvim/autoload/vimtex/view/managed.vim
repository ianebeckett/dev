" Keep manual :VimtexView and automatic viewing on the same lifecycle.
function! vimtex#view#managed#new() abort
  return s:viewer.init()
endfunction

let s:viewer = vimtex#view#_template#new({'name': 'Managed Zathura'})

function! s:viewer._check() dict abort
  return executable('zathura')
endfunction

function! s:viewer._start(outfile) dict abort
  lua require('tex_viewer').view()
endfunction
