import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace Colors.white with themed surface
    # We need to be careful not to replace text color that SHOULD be white (like onPrimary)
    # But usually Colors.white is used for backgrounds.
    
    # Replace background colors
    # color: Colors.white -> color: Theme.of(context).colorScheme.surface
    content = content.replace('color: Colors.white,', 'color: Theme.of(context).colorScheme.surface,')
    content = content.replace('color: Colors.white}', 'color: Theme.of(context).colorScheme.surface}')
    content = content.replace('backgroundColor: Colors.white,', 'backgroundColor: Theme.of(context).colorScheme.surface,')
    
    # Common badge colors fix in ProductCard
    content = content.replace('badgeBackground = const Color(0xFFDCFCE7);', 'badgeBackground = Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2);')
    content = content.replace('badgeColor = const Color(0xFF166534);', 'badgeColor = Theme.of(context).colorScheme.primary;')
    content = content.replace('badgeBackground = Colors.orange[50]!;', 'badgeBackground = Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2);')
    content = content.replace('badgeColor = Colors.orange[900]!;', 'badgeColor = Theme.of(context).colorScheme.tertiary;')
    
    # Fix the ProductCard background logic specifically
    # old: color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.white,
    # new: color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surfaceContainerLow,
    content = content.replace('isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.white', 
                              'isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerLow')

    # Fix hardcoded text colors if any
    # color: Color(0xFF1A1F36) -> color: Theme.of(context).colorScheme.onSurface
    content = re.sub(r'color: Color\(0xFF1A1F36\)', r'color: Theme.of(context).colorScheme.onSurface', content)
    
    # Fix shadow colors
    content = content.replace('Colors.black.withValues(alpha: 0.03)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03)')
    content = content.replace('Colors.black.withValues(alpha: 0.02)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.02)')
    content = content.replace('Colors.black.withValues(alpha: 0.1)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1)')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed {filepath}")

# Process key files
files_to_fix = [
    r'c:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\create_order_screen.dart',
    r'c:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\order_history_screen.dart',
]

for f in files_to_fix:
    if os.path.exists(f):
        process_file(f)
