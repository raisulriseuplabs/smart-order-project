import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find ALL 'const Icon(', 'const TextStyle(', 'const BoxDecoration(' etc.
    # and remove 'const' if the following text until '),' has Theme.of(context)
    
    patterns = [
        r'const\s+([A-Z][a-zA-Z0-9]*\s*\([^;\}]*Theme\.of\(context\)[^;\}]*)',
    ]
    
    new_content = content
    # Repeat a few times to handle nested ones
    for _ in range(3):
        new_content = re.sub(r'const\s+([A-Z][a-zA-Z0-9]*\s*\([^;\}]+)', 
                             lambda m: m.group(1) if 'Theme.of(context)' in m.group(0) else m.group(0), 
                             new_content, flags=re.DOTALL)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Target fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
