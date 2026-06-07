import os
import re

def clean_dart_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove debugPrint statements: debugPrint(...);
    content = re.sub(r'^\s*debugPrint\(.*?\);\n', '', content, flags=re.MULTILINE)
    
    # 2. Remove line comments (lines that start with optional whitespace and //)
    # Be careful not to remove "///" which might be doc comments, though user said "remove comments".
    # Let's just remove // and /// lines unless they have code before them
    content = re.sub(r'^\s*//.*?\n', '\n', content, flags=re.MULTILINE)
    
    # 3. Handle block comments /* ... */
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    
    # 4. Remove extra blank lines (more than 2 consecutive newlines -> 2 newlines)
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    # 5. Organize imports (simple sort of import lines at the top)
    lines = content.split('\n')
    imports = []
    other_lines = []
    in_import_section = True
    for line in lines:
        if line.startswith('import '):
            imports.append(line)
        elif line.strip() == '' and in_import_section:
            continue # ignore empty lines in import section
        else:
            in_import_section = False
            other_lines.append(line)
            
    # Sort imports: package imports first, then relative
    package_imports = sorted([i for i in imports if 'package:' in i])
    dart_imports = sorted([i for i in imports if 'dart:' in i])
    relative_imports = sorted([i for i in imports if 'package:' not in i and 'dart:' not in i])
    
    sorted_imports = []
    if dart_imports:
        sorted_imports.extend(dart_imports)
        sorted_imports.append('')
    if package_imports:
        sorted_imports.extend(package_imports)
        sorted_imports.append('')
    if relative_imports:
        sorted_imports.extend(relative_imports)
        sorted_imports.append('')
        
    final_content = '\n'.join(sorted_imports) + '\n' + '\n'.join(other_lines)
    
    # Final strip of extra empty lines
    final_content = re.sub(r'\n{3,}', '\n\n', final_content).strip() + '\n'

    with open(filepath, 'w') as f:
        f.write(final_content)

def main():
    lib_dir = 'lib'
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                clean_dart_file(filepath)

if __name__ == '__main__':
    main()
