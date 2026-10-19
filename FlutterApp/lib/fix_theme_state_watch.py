import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace ref.watch(themeProvider) with ref.watch(themeProvider).mode where it's used as a theme mode
    # But wait, some places might NEED ThemeState.
    # In LandingScreen, I already fixed it to use themeState.mode.
    
    # In account_screen.dart:
    content = content.replace('_getThemeLabel(ref.watch(themeProvider))', '_getThemeLabel(ref.watch(themeProvider).mode)')
    
    # In any other place?
    # LandingScreen was already updated manually.
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
