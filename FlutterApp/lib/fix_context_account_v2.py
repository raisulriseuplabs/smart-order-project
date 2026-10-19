import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Generic fix for methods in classes that need context
    # _buildSection(context, ...
    content = re.sub(r'(_buildSection\s*\()', r'\1context, ', content)
    content = re.sub(r'(_buildSettingTile\s*\()', r'\1context, ', content)
    content = re.sub(r'(_buildActionTile\s*\()', r'\1context, ', content)
    
    # But wait, definitions also got the 'context,' added!
    # Widget _buildSection(context, String title, ...) -> INVALID
    # We need to fix the definitions to have the type 'BuildContext context'.
    
    content = content.replace('context, String title', 'BuildContext context, String title')
    content = content.replace('context, IconData icon', 'BuildContext context, IconData icon')
    
    # Avoid double context in usage
    content = content.replace('context, context,', 'context,')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file(r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\account\screens\account_screen.dart')
