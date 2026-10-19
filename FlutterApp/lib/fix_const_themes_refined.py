import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find 'const ' and check if Theme.of(context) appears before the next ';' or '},' or '],'
    # We'll look for blocks of code.
    
    def remove_invalid_const(match):
        full_match = match.group(0)
        # Check if the block starting with const contains Theme.of(context)
        # We look ahead until a delimiter that usually ends a const expression
        if 'Theme.of(context)' in full_match:
            return full_match.replace('const ', '', 1)
        return full_match

    # Search for const followed by an object instantiation up to a reasonable length or a delimiter
    new_content = re.sub(r'const\s+[A-Z][a-zA-Z0-9]*\s*\([^;\}]+', remove_invalid_const, content, flags=re.DOTALL)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Refined hyper fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
