import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/features/auth/state/auth_state.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';
import 'package:smart_orders_desktop/core/theme/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:smart_orders_desktop/features/auth/screens/change_password_dialog.dart';

import 'package:smart_orders_desktop/features/auth/screens/change_password_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        final newUser = user.copyWith(imageUrl: image.path);
        ref.read(authNotifierProvider.notifier).updateUser(newUser);
      }
    }
  }

  ImageProvider _getProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const NetworkImage('https://i.pravatar.cc/150?u=john');
    }
    if (kIsWeb || imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
    return FileImage(File(imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surface,
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: user?.imageUrl != null
                                    ? NetworkImage(user!.imageUrl!)
                                    : const NetworkImage('https://i.pravatar.cc/150?u=john'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Loading...',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showProfileDialog(context, user),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: const Text('View Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user?.imageUrl != null
                                ? NetworkImage(user!.imageUrl!)
                                : const NetworkImage('https://i.pravatar.cc/150?u=john'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              user?.status?.toUpperCase() ?? 'ACTIVE ACCOUNT',
                              style: TextStyle(
                                color: user?.status == 'Blocked' ? Colors.red : const Color(0xFF166534),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showProfileDialog(context, user),
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text('View Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 24),

          // Settings Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildSection(context, 
                  'Security',
                  [
                    _buildSettingTile(context, 
                      Icons.lock_outline,
                      'Change Password',
                      'Update your login password',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangePasswordDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(context, 
                  'Notifications',
                  [
                    _buildSettingTile(context, 
                      Icons.notifications_none_outlined,
                      'Push Notifications',
                      'Receive alerts about your orders',
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                    _buildSettingTile(context, 
                      Icons.email_outlined,
                      'Email Reports',
                      'Get daily order summaries via email',
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(context, 
                  'Preferences',
                  [
                    _buildSettingTile(context, 
                      Icons.language_outlined,
                      'Language',
                      'English (United States)',
                      onTap: () {},
                    ),
                    _buildSettingTile(context, 
                      Icons.dark_mode_outlined,
                      'Appearance',
                      _getThemeLabel(ref.watch(themeProvider).mode),
                      onTap: () => _showThemePicker(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Danger Zone
                _buildSection(context, 
                  'Danger Zone',
                  [
                    _buildSettingTile(context, 
                      Icons.delete_outline,
                      'Deactivate Account',
                      'Temporarily disable your login accessibility',
                      color: Colors.red,
                      onTap: () {},
                    ),
                  ],
                  isDanger: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.ocean: return 'Ocean Light';
      case AppThemeMode.emerald: return 'Emerald Health';
      case AppThemeMode.indigo: return 'Indigo Tech';
      case AppThemeMode.sunset: return 'Sunset Coral';
      case AppThemeMode.slate: return 'Slate Executive';
      case AppThemeMode.midnight: return 'Midnight Dark';
      case AppThemeMode.lavender: return 'Soft Lavender';
      case AppThemeMode.cyan: return 'Cyan Modern';
      case AppThemeMode.neutral: return 'Warm Neutral';
      case AppThemeMode.auto: return 'System (Auto)';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select App Theme'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(context, AppThemeMode.ocean, 'Ocean Light', const Color(0xFF0F6E8C), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.emerald, 'Emerald Health', const Color(0xFF1E7F5C), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.indigo, 'Indigo Tech', const Color(0xFF3F51B5), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.sunset, 'Sunset Coral', const Color(0xFFFF6B6B), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.slate, 'Slate Executive', const Color(0xFF475569), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.midnight, 'Midnight Dark', const Color(0xFF1E293B), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.lavender, 'Soft Lavender', const Color(0xFF8B5CF6), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.cyan, 'Cyan Modern', const Color(0xFF0891B2), themeState.mode, notifier),
                _buildThemeOption(context, AppThemeMode.neutral, 'Warm Neutral', const Color(0xFF737373), themeState.mode, notifier),
                const Divider(height: 32),
                _buildThemeOption(context, AppThemeMode.auto, 'Use System Default', Colors.grey, themeState.mode, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildThemeOption(
    BuildContext context,
    AppThemeMode mode,
    String label,
    Color color,
    AppThemeMode current,
    ThemeNotifier notifier,
  ) {
    final isSelected = current == mode;
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: () {
        notifier.setThemeMode(mode);
        Navigator.pop(context);
      },
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary, size: 20) : null,
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children, {bool isDanger = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, 
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.outlineVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Profile'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileInfoRow('Name', user?.name ?? 'N/A'),
            _buildProfileInfoRow('Email', user?.email ?? 'N/A'),
            _buildProfileInfoRow('Phone', user?.phone ?? 'N/A'),
            _buildProfileInfoRow('Branch', user?.branch ?? 'N/A'),
            _buildProfileInfoRow('Accounts', user?.account ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Close')
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
