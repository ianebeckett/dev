# basedpyright: try hover, definition, references, and rename on greet.
def greet(name: str) -> str:
    return "Hello, " + name


print(greet("world"))
print(greet(42))  # Diagnostic: argument must be str.
count: int = "three"  # Diagnostic: str cannot be assigned to int.
