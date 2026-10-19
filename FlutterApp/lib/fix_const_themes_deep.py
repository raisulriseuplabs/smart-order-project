import os
import re

def process_file(filepath):
    if 'migrate_themes.py' in filepath or 'fix_const_themes.py' in filepath: return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match 'const' followed by something containing 'Theme.of(context)'
    # We use a non-greedy catch for content between parens or till end of expression.
    # A common one is const TextStyle(...) where inside is Theme.of(context)
    
    # We will search for 'const' that precedes any block containing 'Theme.of(context)'
    # and remove it if it's invalid.
    
    # Let's find all 'const ' occurrences and check their context.
    # Or just remove EVERY 'const' that is followed by anything containing 'Theme.of(context)'
    # before the next ';' or ')' or '},'
    
    # Regex to find: const [Something]( ... Theme.of(context) ... )
    # This is hard to do with regex for nesting, but we can try common ones.
    patterns = [
        r'const\s+TextStyle\s*\([^)]*Theme\.of\(context\)[^)]*\)',
        r'const\s+BoxDecoration\s*\([^)]*Theme\.of\(context\)[^)]*\)',
        r'const\s+EdgeInsets\s*\([^)]*Theme\.of\(context\)[^)]*\)', # unlikely but anyway
        r'const\s+OutlineInputBorder\s*\([^)]*Theme\.of\(context\)[^)]*\)',
        r'const\s+BorderSide\s*\([^)]*Theme\.of\(context\)[^)]*\)',
        r'const\s+BoxShadow\s*\([^)]*Theme\.of\(context\)[^)]*\)',
    ]
    
    new_content = content
    for p in patterns:
        new_content = re.sub(p, lambda m: m.group(0).replace('const ', ''), new_content, flags=re.DOTALL)
    
    # Also handle the 'const [Widget](' pattern where a named parameter uses Theme.of(context)
    # This is very broad, so we'll do it carefully.
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Deep fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
