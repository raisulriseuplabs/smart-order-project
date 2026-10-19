import os
import re

# Mapping of hardcoded colors to ColorScheme tokens
color_map = {
    # Red / Error
    r'0xFFEF4444': 'error',
    r'0xFF991B1B': 'error',
    r'0xFFB91C1C': 'error',
    
    # Blue / Primary
    r'0xFF00A3CC': 'primary',
    r'0xFF3B82F6': 'primary',
    r'0xFF2563EB': 'primary',
    r'0xFF0288D1': 'primary',
    r'0xFF0B77A9': 'primary',
    r'0xFF0088CC': 'primary',
    r'0xFF0369A1': 'primary',
    
    # Secondary/Alternate Backgrounds
    r'0xFFF0F4F8': 'surfaceContainerHighest',
    r'0xFFF3F7FA': 'surface',
}

def process_file(filepath):
    if not filepath.endswith('.dart'): return
    if any(x in filepath for x in ['theme_provider', 'migrate_themes', 'fix_const', 'app_theme', 'test_replace']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    changed = False
    
    # Search for preset definition blocks and protect them
    # A simple way is to find the presets array or lines and skip them.
    # But those are usually only in landing_screen and account_screen.
    
    for hex_code, token in color_map.items():
        # Match Color(0xFF...) and ignore if preceded by 'const' in some cases or just use non-const replacement
        # We'll use a regex that matches the whole Color(0xFF...)
        pattern = r'(const\s+)?Color\(' + re.escape(hex_code) + r'\)'
        replacement = r'Theme.of(context).colorScheme.' + token
        
        # Avoid replacing presets: check if the line contains 'AppThemeMode'
        # This is easier with a loop over lines
        
    lines = new_content.split('\n')
    fixed_lines = []
    for line in lines:
        if 'AppThemeMode' in line and ('const Color(' in line or '0xFF' in line):
            fixed_lines.append(line)
            continue
            
        new_line = line
        for hex_code, token in color_map.items():
            pat = r'(const\s+)?Color\(' + re.escape(hex_code) + r'\)'
            if re.search(pat, new_line):
                new_line = re.sub(pat, 'Theme.of(context).colorScheme.' + token, new_line)
                changed = True
        fixed_lines.append(new_line)

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(fixed_lines))
        print(f"Migrated more colors in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        process_file(os.path.join(root, file))
