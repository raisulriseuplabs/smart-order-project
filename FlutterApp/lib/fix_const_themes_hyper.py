import os
import re

def process_file(filepath):
    if 'migrate_themes.py' in filepath or 'fix_const_themes' in filepath: return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match 'const' followed by an object instantiation [...] containing 'Theme.of(context)'
    # Stopping at the next semicolon or start of next statement.
    
    # Pattern: const <Type>( <anything including newlines> Theme.of(context) <anything> )
    # We'll use a non-greedy .*? and check if it contains Theme.of(context)
    
    def remove_const(match):
        text = match.group(0)
        if 'Theme.of(context)' in text:
            return text.replace('const ', '', 1)
        return text

    # Matches: const (capital word)(... until ;)
    new_content = re.sub(r'const\s+[A-Z][a-zA-Z0-9]*\s*\([^;]+', remove_const, content, flags=re.DOTALL)
    
    # Also handle list/map const
    new_content = re.sub(r'const\s+\[[^;]+', remove_const, new_content, flags=re.DOTALL)
    new_content = re.sub(r'const\s+\{[^;]+', remove_const, new_content, flags=re.DOTALL)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Hyper fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
