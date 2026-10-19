import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find ALL instances of const Widget(...) and remove const if Widget contains Theme.of(context)
    # We will use a counting parenthesis approach to find the end of the block.
    
    new_content = content
    
    def find_and_remove_const(text):
        pos = 0
        while True:
            match = re.search(r'const\s+([A-Z][a-zA-Z0-9]*)\(', text[pos:])
            if not match:
                break
            
            const_start = pos + match.start()
            paren_start = pos + match.end() - 1
            
            # Find matching close paren
            depth = 1
            close_paren = -1
            for i in range(paren_start + 1, len(text)):
                if text[i] == '(': depth += 1
                elif text[i] == ')': depth -= 1
                
                if depth == 0:
                    close_paren = i
                    break
            
            if close_paren != -1:
                block = text[const_start:close_paren+1]
                if 'Theme.of(context)' in block:
                    text = text[:const_start] + block.replace('const ', '', 1) + text[close_paren+1:]
                    # don't increment pos, re-check from start since we modified string
                    pos = const_start + 1 
                else:
                    pos = paren_start + 1
            else:
                pos = paren_start + 1
        return text

    new_content = find_and_remove_const(new_content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Parenthesis fixed const in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
