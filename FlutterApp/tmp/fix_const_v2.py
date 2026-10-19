import os
import re

def fix_const_errors(directory):
    files_to_fix = [
        'lib/features/auth/screens/splash_screen.dart',
        'lib/features/auth/screens/register_screen.dart',
        'lib/features/auth/screens/forgot_password_screen.dart',
        'lib/features/landing/screens/landing_screen.dart',
        'lib/features/orders/screens/create_order_screen.dart',
        'lib/features/orders/screens/order_history_screen.dart',
        'lib/features/reports/screens/reports_screen.dart',
        'lib/features/landing/screens/update_dialog.dart',
        'lib/features/auth/screens/change_password_dialog.dart',
        'lib/core/theme/app_theme.dart'
    ]
    
    for relative_path in files_to_fix:
        absolute_path = os.path.join(directory, relative_path.replace('/', os.sep))
        if not os.path.exists(absolute_path):
            continue
            
        with open(absolute_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # More aggressive: Find 'const' and see if 'AppTheme' appears before the next ';' or '}' or a few lines later
        # Actually, let's just find and remove 'const' if it's followed by a widget/style name and 'AppTheme' is nearby.
        
        # This matches 'const WidgetName(' and then we look ahead for 'AppTheme'
        pattern = r'const\s+([A-Z][a-zA-Z0-9]+)\s*\('
        
        def replacement(match):
            widget_start = match.start()
            # Look ahead up to 500 characters or until the next ';' or '}'
            lookahead = content[widget_start:widget_start + 500]
            if 'AppTheme' in lookahead or 'textPrimary' in lookahead or 'background' in lookahead:
                 return match.group(1) + '('
            return match.group(0)

        new_content = re.sub(pattern, replacement, content)
        
        # Also handle static const -> static final
        new_content = new_content.replace('static const', 'static final')
        
        if new_content != content:
            with open(absolute_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Refined {relative_path}")

if __name__ == "__main__":
    fix_const_errors(os.getcwd())
