// ts_ls: enable with :lua vim.lsp.enable('ts_ls') if installed.
// Try hover, definition, references, and rename on greet.
function greet(name: string): string {
  return `Hello, ${name}`;
}

console.log(greet('world'));
console.log(greet(42)); // Diagnostic: argument must be string.
const count: number = 'three'; // Diagnostic: string cannot be assigned to number.

export {};
