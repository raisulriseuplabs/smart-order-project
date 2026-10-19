import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # For AccountScreen:
    if 'AccountScreen' in content:
        # _buildSection
        content = content.replace('_buildSection(title,', '_buildSection(context, title,') # usage
        content = content.replace('_buildSection(String title,', '_buildSection(BuildContext context, String title,') # definition
        
        # _buildSettingTile
        content = content.replace('_buildSettingTile(icon,', '_buildSettingTile(context, icon,') # usage
        content = content.replace('_buildSettingTile(IconData icon,', '_buildSettingTile(BuildContext context, IconData icon,') # definition
        
        # _buildActionTile
        content = content.replace('_buildActionTile(icon,', '_buildActionTile(context, icon,') # usage
        content = content.replace('_buildActionTile(IconData icon,', '_buildActionTile(BuildContext context, IconData icon,') # definition

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file(r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\account\screens\account_screen.dart')
