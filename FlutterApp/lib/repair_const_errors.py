import os
import re

def remove_bad_const(content):
    # Regex to find 'const ' followed by dynamic markers like 'Theme.of(context)'
    # on the same line or nearby. This could be multiple.
    
    # We'll use a several-pass approach.
    dynamic_markers = [
        r'Theme\.of\(context\)',
        r'colorScheme\.',
        r'ref\.',
        r'MediaQuery\.',
        r'withValues\(',
        r'withOpacity\('
    ]
    
    changed = False
    
    # Simple regex to remove 'const ' if it's followed by a name and '('
    # then containing any of the dynamic_markers.
    # We'll just look for 'const ' and if it's on a line that has the marker,
    # or if the block it's in has the marker.
    
    # To be safe, we'll implement the parenthetical check as it was better.
    
    i = 0
    new_content = []
    
    while i < len(content):
        if content.startswith('const ', i):
            # Look for the current expression scope (roughly until the next outer-matching close paren or next sibling)
            # Find the first '('
            
            # Skip past whitespaces or potential identifier
            # e.g. "const   BoxDecoration("
            match = re.search(r'const\s+([A-Z][a-zA-Z0-9_\.]*\s*)?\(', content[i:])
            if match and match.start() == 0:
                # Parenthesis-based object instantiation
                paren_start = content.find('(', i)
                depth = 1
                j = paren_start + 1
                while j < len(content) and depth > 0:
                    if content[j] == '(': depth += 1
                    elif content[j] == ')': depth -= 1
                    j += 1
                
                scope = content[i : j]
                if any(re.search(marker, scope) for marker in dynamic_markers):
                    # Found dynamic marker inside const scope. Removing 'const '
                    # Remove only the 'const ' part which is basically content[i : i+6]
                    # Since we want to keep the rest.
                    new_content.append(content[i+6:j])
                    i = j
                    changed = True
                    continue
            
            # Also handle simple 'const iconColor = Theme.of(context).colorScheme.primary;' style assignments
            # Or "const Color(0x...)" replaced with "Theme.of(context).colorScheme..."
            # Let's find end of statement (semicolon or comma/closing paren at higher level)
            stmt_end = i
            depth = 0
            while stmt_end < len(content):
                if content[stmt_end] in [';', ','] and depth == 0:
                    break
                if content[stmt_end] == '(': depth += 1
                elif content[stmt_end] == ')': 
                    if depth == 0: break # Part of outer context
                    depth -= 1
                stmt_end += 1
            
            scope = content[i : stmt_end]
            if any(re.search(marker, scope) for marker in dynamic_markers):
                # Remove just the 'const '
                new_content.append(content[i+6 : stmt_end])
                i = stmt_end
                changed = True
                continue
                
        new_content.append(content[i])
        i += 1
        
    final_content = "".join(new_content)
    
    # One more general cleanup for cases like "const const " or "const const const "
    while "const const " in final_content:
        final_content = final_content.replace("const const ", "const ")
        changed = True

    return final_content, changed

def main():
    root_dir = r"C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features"
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    new_content, changed = remove_bad_const(content)
                    
                    if changed:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"Repaired const issues in {filepath}")
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")

if __name__ == "__main__":
    main()
