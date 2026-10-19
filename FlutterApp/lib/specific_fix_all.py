import os

specific_replacements = {
    'Color(0xFFEF4444)': 'Theme.of(context).colorScheme.error',
    'Color(0xFF00A3CC)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF3B82F6)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF2563EB)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF0288D1)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF0B77A9)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF0088CC)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF1976D2)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFFFF9800)': 'Theme.of(context).colorScheme.tertiary',
    'Color(0xFF991B1B)': 'Theme.of(context).colorScheme.error',
    'Color(0xFFB91C1C)': 'Theme.of(context).colorScheme.error',
    'Color(0xFFF0F4F8)': 'Theme.of(context).colorScheme.surfaceContainerHighest',
    'Color(0xFFF3F7FA)': 'Theme.of(context).colorScheme.surface',
}

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if not file.endswith('.dart'): continue
        if any(x in file for x in ['theme_provider', 'migrate_themes', 'fix_const', 'app_theme']): continue
        
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        new_content = content
        for k, v in specific_replacements.items():
            if k in new_content:
                # Check if it's in a theme definition line (protect them)
                # Quick check: does the line have 'AppThemeMode' or 'case '
                temp_lines = []
                for line in new_content.split('\n'):
                    if 'AppThemeMode' in line or 'case AppThemeMode.' in line:
                        temp_lines.append(line)
                    else:
                        nl = line.replace('const ' + k, v)
                        nl = nl.replace(k, v)
                        temp_lines.append(nl)
                new_content = '\n'.join(temp_lines)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Surgical fixed {filepath}")
