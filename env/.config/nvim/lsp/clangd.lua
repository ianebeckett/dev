return {
    cmd = {
        'clangd',
        '--clang-tidy',
        '--background-index',
        "--query-driver=/usr/bin/g++"
    },
    root_markers = {{
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git'
    }},
    filetypes = { 'c', 'cpp', 'h', 'hpp' },
}
