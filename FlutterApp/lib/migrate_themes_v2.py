import os
import re

# Mapping of hardcoded colors to ColorScheme tokens
color_map = {
    # Dark/Primary Text
    r'0xFF111827': 'onSurface',
    r'0xFF1A1F36': 'onSurface',
    r'0xFF1F2937': 'onSurface',
    r'0xFF374151': 'onSurface',
    r'0xFF0F172A': 'onSurface',
    
    # Muted/Secondary Text
    r'0xFF4B5563': 'onSurfaceVariant',
    r'0xFF4F5B76': 'onSurfaceVariant',
    r'0xFF6B7280': 'onSurfaceVariant',
    r'0xFF8792A2': 'onSurfaceVariant',
    r'0xFF94A3B8': 'outline',
    
    # Borders/Dividers
    r'0xFFE5E7EB': 'outlineVariant',
    r'0xFFE2E8F0': 'outlineVariant',
    r'0xFFCBD5E1': 'outlineVariant',
    r'0xFFD1D5DB': 'outlineVariant',
    
    # Backgrounds
    r'0xFFF9FAFB': 'surface',
    r'0xFFF3F4F6': 'surfaceContainerHighest',
    r'0xFFF1F5F9': 'surfaceContainerHighest',
    r'0xFFF8FAFC': 'surface',
}

def process_file(filepath):
    # Skip non-dart or utility files
    if not filepath.endswith('.dart'): return
    if any(x in filepath for x in ['migrate_themes', 'fix_const_themes']): return
    
    # Skip ThemeProvider itself
    if 'theme_provider.dart' in filepath: return

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return

    new_content = content
    
    # 3. Replace Hex codes
    for hex_code, token in color_map.items():
        pattern = r'(const\s+)?Color\(' + re.escape(hex_code) + r'\)'
        replacement = r'Theme.of(context).colorScheme.' + token
        new_content = re.sub(pattern, replacement, new_content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Refined themes in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
print(f"Scanning {root_dir}...")
for root, dirs, files in os.walk(root_dir):
    for file in files:
        process_file(os.path.join(root, file))
print("Done.")
