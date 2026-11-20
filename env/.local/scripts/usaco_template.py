import sys

sys.setrecursionlimit(2000)
input = sys.stdin.buffer.readline
INF = 10**18


def set_io(file_name: str=""):
    if file_name:
        sys.stdin = open(f"{file_name}.in", "r")
        sys.stdout = open(f"{file_name}.out", "w")


def solve():
    # Process logic here


def main():
    set_io()
    solve()


if __name__ == "__main__":
    main()

