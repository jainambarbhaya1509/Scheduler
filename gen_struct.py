import os

IGNORE_DIRS = {
    ".git",
    ".dart_tool",
    "build",
    ".idea",
    ".vscode",
    "ios",
    "android",
    "linux",
    "macos",
    "windows",
    "test"
}

def generate_tree(path, prefix=""):
    entries = [
        e for e in os.listdir(path)
        if e not in IGNORE_DIRS and not e.startswith(".")
    ]

    entries.sort()
    for index, entry in enumerate(entries):
        full_path = os.path.join(path, entry)
        connector = "└── " if index == len(entries) - 1 else "├── "

        print(prefix + connector + entry)

        if os.path.isdir(full_path):
            extension = "    " if index == len(entries) - 1 else "│   "
            generate_tree(full_path, prefix + extension)

def main():
    root = "lib"
    if not os.path.exists(root):
        print("❌ 'lib/' directory not found. Run this from Flutter project root.")
        return

    print("```text")
    print("lib/")
    generate_tree(root)
    print("```")

if __name__ == "__main__":
    main()
