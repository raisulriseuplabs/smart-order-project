import os
import re

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
results = []

for root, dirs, files in os.walk(root_dir):
    for file in files:
        if not file.endswith('.dart'): continue
        if any(x in file for x in ['theme_provider', 'migrate_themes', 'fix_const', 'app_theme']): continue
        
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
        matches = re.findall(r'Color\(0xFF[0-9A-Fa-f]{6}\)', content)
        if matches:
            results.append(f"{filepath}: {matches}")

for r in results:
    print(r)
