import os
import re

def process_file(filepath):
    if any(x in filepath for x in ['migrate_themes.py', 'fix_const_themes']): return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern: a helper method in a class that calls Theme.of(context) but doesn't have context.
    # We will look for methods that call Theme.of(context) and check if 'context' is in their signature.
    
    # This is complex, but we can do a targeted fix for create_order_screen.dart specifically or any similar ones.
    
    # For _AgeAnalysisPanelContent._buildBuckets:
    if '_AgeAnalysisPanelContent' in content:
        content = content.replace('_buildBuckets(data![\'buckets\'] ?? {})', '_buildBuckets(context, data![\'buckets\'] ?? {})')
        content = content.replace('List<Widget> _buildBuckets(Map<String, dynamic> buckets) {', 'List<Widget> _buildBuckets(BuildContext context, Map<String, dynamic> buckets) {')

    if content != content: # This check is always false if I use 'content = ...'
        pass 
    
    # Actually I'll just write the fix for create_order_screen.dart
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file(r'C:\Users\ASUS\Desktop\New folder\SmartOrder\lib\features\orders\screens\create_order_screen.dart')
