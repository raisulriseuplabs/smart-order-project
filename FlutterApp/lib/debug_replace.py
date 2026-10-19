import os

filepath = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\create_order_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

print(f"Content length: {len(content)}")
print(f"Does '0xFFEF4444' exist? {'0xFFEF4444' in content}")

new_content = content.replace('Color(0xFFEF4444)', 'Theme.of(context).colorScheme.error')
if new_content != content:
    print("Changed!")
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
else:
    print("No change.")
