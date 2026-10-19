import os

filepath = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\create_order_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

if '0xFF1A1F36' in content:
    print("Found 0xFF1A1F36 in create_order_screen.dart")
    new_content = content.replace('Color(0xFF1A1F36)', 'Theme.of(context).colorScheme.onSurface')
    new_content = new_content.replace('const Theme.of(context).colorScheme.onSurface', 'Theme.of(context).colorScheme.onSurface')
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Replaced.")
else:
    print("Not found.")
