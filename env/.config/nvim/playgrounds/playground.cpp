// clangd: try hover, definition, references, and rename on double_value.
int double_value(int value) {
    return value * 2;
}

int main() {
    int result = double_value(21);
    int broken = "three"; // Diagnostic: cannot initialize int from a string.
    return result + broken;
}
