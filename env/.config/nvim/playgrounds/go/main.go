// gopls: enable with :lua vim.lsp.enable('gopls') if installed.
// Try hover, definition, references, and rename on greet.
package main

import "fmt"

func greet(name string) string {
	return "Hello, " + name
}

func main() {
	fmt.Println(greet("world"))
	fmt.Println(greet(42)) // Diagnostic: argument must be string.
}
