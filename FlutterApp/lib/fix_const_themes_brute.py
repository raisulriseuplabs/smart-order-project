import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Even simpler: search for 'Theme.of(context)' and remove 'const' from the preceding 200 characters if it's there.
    # This is a bit brute force but effective for these cases.
    
    def fix_block(match):
        pre = match.group(1)
        post = match.group(2)
        # Look for 'const ' in pre and remove it if it's not followed by a semicolon or other breaker
        # We'll just remove the last 'const ' found in pre.
        idx = pre.rfind('const ')
        if idx != -1:
            # Check if there's a breaker between const and the match
            breaker = False
            for b in [';', '}', ']', 'return']:
                if b in pre[idx:]:
                    breaker = True
                    break
            if not breaker:
                return pre[:idx] + pre[idx+6:] + 'Theme.of(context)' + post
        return match.group(0)

    # Find Theme.of(context) and fix its parent const
    new_content = re.sub(r'(.{1,200})Theme\.of\(context\)(.*)', fix_block, content, flags=re.DOTALL)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Brute fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
