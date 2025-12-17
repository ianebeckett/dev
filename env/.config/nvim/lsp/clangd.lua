-- compile.commands.json is needed in the project root. Something like this:
-- [
--   {
--     "arguments": [
--       "/usr/bin/g++",
--       "-c",
--       "-Wall",
--       "-Wextra",
--       "-Wpedantic",
--       "a.cpp"
--     ],
--     "directory": "/home/ian/school/undergrad/430_strategy/lab01",
--     "file": "/home/ian/school/undergrad/430_strategy/lab01/a.cpp"
--   }
-- ]
--
-- We can make it with bear -- g++ -foo -bar a.cpp

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
