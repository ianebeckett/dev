local find_server = function()
        --prefer local binary
        if os.execute("command -v " .. "rust-analyzer" .. " > /dev/null 2>&1") then
            return { 'rust-analyzer' }
        end
        --fall back to rustup version
        return { "rustup", "run", "stable", "rust-analyzer" }
    end

return {
    cmd = find_server(),
    root_markers = {{ 'Cargo.toml', '.git' }},
    filetypes = { 'rust' },
}
