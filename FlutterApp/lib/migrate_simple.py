import os

color_map = {
    'Color(0xFFEF4444)': 'Theme.of(context).colorScheme.error',
    'Color(0xFF00A3CC)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF3B82F6)': 'Theme.of(context).colorScheme.primary',
}

root_dir = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib'
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if not file.endswith('.dart'): continue
        filepath = os.path.join(root, file)
        
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        new_content = content
        for k, v in color_map.items():
            if k in new_content:
                new_content = new_content.replace('const ' + k, v)
                new_content = new_content.replace(k, v)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Simple fixed {filepath}")
