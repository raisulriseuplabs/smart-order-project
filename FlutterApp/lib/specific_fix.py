import os

# Manual mappings based on find_colors.py for create_order_screen.dart
specific_replacements = {
    'Color(0xFFEF4444)': 'Theme.of(context).colorScheme.error',
    'Color(0xFF10B981)': 'const Color(0xFF10B981)', # Specialized Green, keep if no better token
    'Color(0xFF00A3CC)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFFE0F2FE)': 'Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)',
    'Color(0xFFBAE6FD)': 'Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4)',
    'Color(0xFF0369A1)': 'Theme.of(context).colorScheme.primary',
    'Color(0xFF059669)': 'const Color(0xFF059669)', # Success Green
    'Color(0xFF16A34A)': 'const Color(0xFF16A34A)', # Success Green
    'Color(0xFFFEE2E2)': 'Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2)',
    'Color(0xFF991B1B)': 'Theme.of(context).colorScheme.error',
}

filepath = r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\create_order_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

new_content = content
for k, v in specific_replacements.items():
    if k in new_content:
        # Replace occurrences and handle const
        new_content = new_content.replace('const ' + k, v)
        new_content = new_content.replace(k, v)

if new_content != content:
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Specifically updated create_order_screen.dart")
else:
    print("No matches in create_order_screen.dart")
