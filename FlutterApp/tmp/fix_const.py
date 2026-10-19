import os
import re

def fix_const_errors(directory):
    # Pattern to find 'const' followed by something that looks like a widget/constructor using AppTheme
    # We want to remove 'const' if the expression contains AppTheme.<something>
    # This is a bit tricky with regex, but we can try to find lines that have 'const' and 'AppTheme.'
    
    # List of files from the error log
    files_to_fix = [
        'lib/features/auth/screens/splash_screen.dart',
        'lib/features/auth/screens/register_screen.dart',
        'lib/features/auth/screens/forgot_password_screen.dart',
        'lib/features/landing/screens/landing_screen.dart',
        'lib/features/orders/screens/create_order_screen.dart',
        'lib/features/orders/screens/order_history_screen.dart',
        'lib/features/reports/screens/reports_screen.dart',
        'lib/features/landing/screens/update_dialog.dart',
        'lib/features/auth/screens/change_password_dialog.dart'
    ]
    
    for relative_path in files_to_fix:
        absolute_path = os.path.join(directory, relative_path.replace('/', os.sep))
        if not os.path.exists(absolute_path):
            print(f"File not found: {absolute_path}")
            continue
            
        with open(absolute_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Regex to find 'const ' followed by some word and potential arguments using AppTheme.
        # We'll look for lines that have 'const' and 'AppTheme.' and try to remove the 'const'.
        # A simple approach: remove 'const ' if the line contains 'AppTheme.'
        # but only if it's not a variable declaration like 'const foo = ...' (which would now be 'final' or 'var')
        
        lines = content.splitlines()
        new_lines = []
        for line in lines:
            if 'AppTheme.' in line and 'const ' in line:
                # Check if it's a variable declaration
                # e.g. "static const Color foo = AppTheme.bar;" -> "static final Color foo = AppTheme.bar;"
                if 'static const' in line:
                    line = line.replace('static const', 'static final')
                elif 'const ' in line:
                    # Generic removal of const prefix for expressions
                    # e.g. "color: const Color(AppTheme.foo)" -> "color: Color(AppTheme.foo)"
                    # e.g. "decoration: const BoxDecoration(...AppTheme.foo...)" -> "decoration: BoxDecoration(...)"
                    line = line.replace('const ', '')
            new_lines.append(line)
            
        new_content = '\n'.join(new_lines)
        
        if new_content != content:
            with open(absolute_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed {relative_path}")
        else:
            print(f"No changes for {relative_path}")

if __name__ == "__main__":
    fix_const_errors(os.getcwd())
