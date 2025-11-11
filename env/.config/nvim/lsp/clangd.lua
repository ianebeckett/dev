return {
  cmd = { 'clangd', '--clang-tidy', '--background-index' },
  root_markers = { { 'compile_commands.json', 'compile_flags.txt' }, },
  filetypes = { 'c', 'cpp', 'h', 'hpp' },
}
