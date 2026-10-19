import os
import re

patterns = {
    # AppTheme Legacy
    r'AppTheme\.primaryBlue(Dark|Light)?': r'Theme.of(context).colorScheme.primary',
    r'AppTheme\.secondaryGreen': r'const Color(0xFF16A34A)',
    r'AppTheme\.secondaryRed': r'Theme.of(context).colorScheme.error',
    r'AppTheme\.secondaryOrange': r'const Color(0xFFF59E0B)',
    r'AppTheme\.statusActive': r'const Color(0xFF16A34A)',
    r'AppTheme\.statusCancelled': r'Theme.of(context).colorScheme.error',
    r'AppTheme\.statusPending': r'const Color(0xFFF59E0B)',
    r'AppTheme\.badgeAvailable': r'const Color(0xFF16A34A)',
    r'AppTheme\.badgeOutOfStock': r'Theme.of(context).colorScheme.error',
    r'AppTheme\.badgePromo': r'const Color(0xFF9C27B0)',
    r'AppTheme\.backgroundLight': r'Theme.of(context).colorScheme.surface',
    r'AppTheme\.backgroundWhite': r'Theme.of(context).colorScheme.surface',
    r'AppTheme\.backgroundGray': r'Theme.of(context).colorScheme.surfaceContainerHighest',
    r'AppTheme\.textPrimary': r'Theme.of(context).colorScheme.onSurface',
    r'AppTheme\.textSecondary': r'Theme.of(context).colorScheme.onSurfaceVariant',
    r'AppTheme\.textDisabled': r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)',
    r'AppTheme\.borderColor': r'Theme.of(context).colorScheme.outlineVariant',
    r'AppTheme\.dividerColor': r'Theme.of(context).colorScheme.outlineVariant',
}

def process_file(filepath):
    if 'migrate_themes.py' in filepath or 'fix_const_themes' in filepath: return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for pattern, replacement in patterns.items():
        new_content = re.sub(pattern, replacement, new_content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Migrated themes in {filepath}")

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
