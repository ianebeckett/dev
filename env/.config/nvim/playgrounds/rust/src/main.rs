// rust-analyzer: enable with :lua vim.lsp.enable('rust-analyzer') if installed.
// Try hover, definition, references, and rename on greet.
fn greet(name: &str) -> String {
    format!("Hello, {name}")
}

fn main() {
    println!("{}", greet("world"));
    println!("{}", greet(42)); // Diagnostic: argument must be &str.
}
