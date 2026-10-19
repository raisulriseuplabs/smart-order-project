import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to find 'const' followed by something containing 'Theme.of(context)'
    # and remove that 'const'.
    # We look for 'const ' followed by some words, then '(', then some content that includes 'Theme.of(context)'
    # and ends with ')'. This is tricky with regex due to nested parens.
    
    # Simpler approach: find lines with 'const' AND 'Theme.of(context)' and remove 'const'
    # Or find patterns like 'const TextStyle(' and 'Theme.of(context)'
    
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'const' in line and 'Theme.of(context)' in line:
            new_line = line.replace('const ', '')
            new_lines.append(new_line)
        else:
            new_lines.append(line)
    
    new_content = '\n'.join(new_lines)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
