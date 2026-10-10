// clangd: try hover, definition, references, and rename on double_value.
int double_value(int value) {
    return value * 2;
}

int main(void) {
    int result = double_value(21);
    return result + missing; // Diagnostic: undeclared identifier.
}
