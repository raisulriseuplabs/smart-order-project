import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    
    # Replace background colors
    new_content = new_content.replace('color: Colors.white,', 'color: Theme.of(context).colorScheme.surface,')
    new_content = new_content.replace('color: Colors.white}', 'color: Theme.of(context).colorScheme.surface}')
    new_content = new_content.replace('backgroundColor: Colors.white,', 'backgroundColor: Theme.of(context).colorScheme.surface,')
    
    # 2. Fix the ProductCard background logic specifically
    # old: color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.white,
    # new: color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surfaceContainerLow,
    new_content = new_content.replace('isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.white', 
                              'isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerLow')
    new_content = new_content.replace('isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerLow', 
                              'isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerLow')

    # Common badge background fix
    new_content = new_content.replace('badgeBackground = const Color(0xFFDCFCE7);', 'badgeBackground = Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2);')
    new_content = new_content.replace('badgeColor = const Color(0xFF166534);', 'badgeColor = Theme.of(context).colorScheme.primary;')
    new_content = new_content.replace('badgeBackground = Color(0xFFDCFCE7);', 'badgeBackground = Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2);')
    new_content = new_content.replace('badgeColor = Color(0xFF166534);', 'badgeColor = Theme.of(context).colorScheme.primary;')
    
    new_content = new_content.replace('badgeBackground = Colors.orange[50]!;', 'badgeBackground = Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2);')
    new_content = new_content.replace('badgeColor = Colors.orange[900]!;', 'badgeColor = Theme.of(context).colorScheme.tertiary;')

    # Fix hardcoded text colors
    new_content = re.sub(r'color: Color\(0xFF1A1F36\)', r'color: Theme.of(context).colorScheme.onSurface', new_content)
    new_content = re.sub(r'color: Color\(0xFF111827\)', r'color: Theme.of(context).colorScheme.onSurface', new_content)

    # Fix shadow colors
    new_content = new_content.replace('Colors.black.withValues(alpha: 0.03)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03)')
    new_content = new_content.replace('Colors.black.withValues(alpha: 0.02)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.02)')
    new_content = new_content.replace('Colors.black.withValues(alpha: 0.1)', 'Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1)')

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Processed {filepath}")

def main():
    root_dir = r'c:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features'
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
