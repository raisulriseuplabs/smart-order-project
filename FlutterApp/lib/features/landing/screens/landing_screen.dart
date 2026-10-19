import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/features/auth/state/auth_state.dart';
import 'package:smart_orders_desktop/features/orders/screens/create_order_screen.dart';
import 'package:smart_orders_desktop/features/orders/screens/order_history_screen.dart';
import 'package:smart_orders_desktop/features/reports/screens/reports_screen.dart';
import 'package:smart_orders_desktop/features/account/screens/account_screen.dart';
import 'package:smart_orders_desktop/features/account/screens/parameters_screen.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_orders_desktop/features/landing/screens/update_dialog.dart';
import 'package:smart_orders_desktop/core/theme/theme_provider.dart';
import 'package:smart_orders_desktop/features/auth/screens/change_password_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

enum DeviceMode { desktop, tablet, phone }

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final List<AppTab> _tabs = [];
  int _selectedTabIndex = 0;
  DeviceMode _selectedMode = DeviceMode.desktop;
  bool _isBootstrapping = true;
  bool _hasConnectionError = false;

  @override
  void initState() {
    super.initState();
    // Welcome page is shown when no tabs are open
  }

  void _openTab(String title, IconData icon, Widget widget) {
    // Check if tab already exists
    final existingIndex = _tabs.indexWhere((t) => t.title == title);
    if (existingIndex != -1) {
      setState(() {
        _selectedTabIndex = existingIndex;
      });
      return;
    }

    // Create new tab
    setState(() {
      _tabs.add(
        AppTab(id: const Uuid().v4(), title: title, icon: icon, widget: widget),
      );
      _selectedTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    if (!_tabs[index].canClose) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Close Tab', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to close "${_tabs[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _tabs.removeAt(index);
                if (_selectedTabIndex >= _tabs.length) {
                  _selectedTabIndex = _tabs.isEmpty ? 0 : _tabs.length - 1;
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = Responsive.isMobile(context);
    
            if (isMobile) {
              return _buildMobileShell();
            }
    
            return _buildDesktopShell();
          },
        ),
        if (_isBootstrapping)
          _BootstrapOverlay(
            onComplete: () => setState(() => _isBootstrapping = false),
            onError: () => setState(() => _hasConnectionError = true),
          ),
        if (_hasConnectionError)
          _ConnectionErrorOverlay(
            onRetry: () {
              setState(() {
                _hasConnectionError = false;
                _isBootstrapping = true;
              });
            },
          ),
      ],
    );
  }

  Widget _buildMobileShell() {
    final user = ref.watch(currentUserProvider);

    final List<Widget> mobileScreens = [
      const CreateOrderScreen(),
      OrderHistoryScreen(),
      ReportsScreen(),
    ];

    // Map the current active desktop tab to the appropriate mobile index
    int displayIndex = 0;
    if (_tabs.isNotEmpty && _selectedTabIndex < _tabs.length) {
      final currentTab = _tabs[_selectedTabIndex];
      if (currentTab.title == 'Order History') {
        displayIndex = 1;
      } else if (currentTab.title == 'Reports') {
        displayIndex = 2;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Smart Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          user.when(
            data: (userData) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildProfileUserMenu(userData, isCompact: true),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      body: IndexedStack(index: displayIndex, children: mobileScreens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: displayIndex,
        onTap: (index) {
          if (index == 0) {
            _openTab(
              'Create Order',
              Icons.add_shopping_cart_outlined,
              CreateOrderScreen(),
            );
          } else if (index == 1) {
            _openTab(
              'Order History',
              Icons.history_outlined,
              OrderHistoryScreen(),
            );
          } else if (index == 2) {
            _openTab(
              'Reports',
              Icons.assessment_outlined,
              ReportsScreen(),
            );
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.outline,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_outlined),
            activeIcon: Icon(Icons.add_shopping_cart),
            label: 'Create order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Order history',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopShell() {
    final user = ref.watch(currentUserProvider);
    final isCompact = Responsive.isCompact(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Smart Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: isCompact ? 16 : 48),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuButton(
                          isCompact ? 'New Order' : 'Create Order',
                          Icons.add_shopping_cart_outlined,
                          () => _openTab(
                            'Create Order',
                            Icons.add_shopping_cart_outlined,
                            CreateOrderScreen(),
                          ),
                        ),
                        _buildMenuButton(
                          isCompact ? 'History' : 'Order History',
                          Icons.history_outlined,
                          () => _openTab(
                            'Order History',
                            Icons.history_outlined,
                            OrderHistoryScreen(),
                          ),
                        ),
                        _buildMenuButton(
                          'Reports',
                          Icons.assessment_outlined,
                          () => _openTab(
                            'Reports',
                            Icons.assessment_outlined,
                            const ReportsScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                user.when(
                  data: (userData) => Row(
                    children: [
                      _buildDeviceSelector(),
                      const SizedBox(width: 8),
                      _buildThemeSelector(),
                      const SizedBox(width: 16),
                      _buildProfileUserMenu(userData, isCompact: isCompact),
                    ],
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => SizedBox(),
                ),
              ],
            ),
          ),

          // Tabs Bar
          if (_tabs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              height: 48,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final tab = _tabs.removeAt(oldIndex);
                    _tabs.insert(newIndex, tab);

                    // Update selected index
                    if (_selectedTabIndex == oldIndex) {
                      _selectedTabIndex = newIndex;
                    } else if (oldIndex < _selectedTabIndex &&
                        newIndex >= _selectedTabIndex) {
                      _selectedTabIndex -= 1;
                    } else if (oldIndex > _selectedTabIndex &&
                        newIndex <= _selectedTabIndex) {
                      _selectedTabIndex += 1;
                    }
                  });
                },
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = index == _selectedTabIndex;

                  return ReorderableDragStartListener(
                    key: ValueKey(tab.id),
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: Material(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tab.icon,
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  tab.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (tab.canClose) ...[
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _closeTab(index),
                                    borderRadius: BorderRadius.circular(3),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Content Area
          Expanded(
            child: _tabs.isEmpty || _selectedTabIndex >= _tabs.length
                ? const WelcomeTab()
                : _tabs[_selectedTabIndex].widget,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUserMenu(dynamic userData, {required bool isCompact}) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData?.name ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                    Text(
                      userData?.email ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            if (!isCompact) SizedBox(width: 12),
            if (!isCompact)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            if (!isCompact) SizedBox(width: 12),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(18),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: _getProfileImage(userData?.imageUrl),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: _getProfileImage(userData?.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userData?.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _buildPopupItem('parameters', Icons.tune_outlined, 'Parameters'),
        _buildPopupItem('profile', Icons.person_outline, 'My Profile'),
        _buildPopupItem(
          'change_password',
          Icons.key_outlined,
          'Change Password',
        ),
        _buildPopupItem(
          'check_updates',
          Icons.refresh_outlined,
          'Check Updates',
        ),
        const PopupMenuDivider(),
        _buildPopupItem('logout', Icons.logout_outlined, 'Logout'),
        _buildPopupItem('exit', Icons.cancel_outlined, 'Exit'),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          await ref.read(authNotifierProvider.notifier).logout();
        } else if (value == 'change_password') {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => const ChangePasswordDialog(),
          );
        } else if (value == 'parameters') {
          ParametersDialog.show(context);
        } else if (value == 'profile') {
          _openTab(
            'Account Settings',
            Icons.person_outline,
            const AccountScreen(),
          );
        } else if (value == 'check_updates') {
          UpdateDialog.show(context);
        }
      },
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final theme = Theme.of(context);

    return PopupMenuButton<AppThemeMode>(
      offset: const Offset(0, 45),
      tooltip: 'Select theme',
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.palette_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            'THEME PRESETS',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildThemeItem(AppThemeMode.ocean, 'Ocean Light', const Color(0xFF0F6E8C)),
        _buildThemeItem(AppThemeMode.emerald, 'Emerald health', const Color(0xFF1E7F5C)),
        _buildThemeItem(AppThemeMode.indigo, 'Indigo Tech', const Color(0xFF3F51B5)),
        _buildThemeItem(AppThemeMode.sunset, 'Sunset Coral', const Color(0xFFFF6B6B)),
        _buildThemeItem(AppThemeMode.slate, 'Slate Executive', const Color(0xFF475569)),
        _buildThemeItem(AppThemeMode.midnight, 'Midnight Dark', const Color(0xFF1E293B)),
        _buildThemeItem(AppThemeMode.lavender, 'Soft Lavender', const Color(0xFF8B5CF6)),
        _buildThemeItem(AppThemeMode.cyan, 'Cyan Modern', const Color(0xFF0891B2)),
        _buildThemeItem(AppThemeMode.neutral, 'Warm Neutral', const Color(0xFF737373)),

        const PopupMenuDivider(),
        _buildThemeItem(AppThemeMode.auto, 'Use System Default', Colors.grey),
      ],
      onSelected: (mode) {
        notifier.setThemeMode(mode);
      },
    );
  }



  PopupMenuItem<AppThemeMode> _buildThemeItem(AppThemeMode mode, String label, Color color) {
    final themeState = ref.watch(themeProvider);
    final isSelected = themeState.mode == mode;
    final theme = Theme.of(context);

    return PopupMenuItem<AppThemeMode>(
      value: mode,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return PopupMenuButton<DeviceMode>(
      offset: Offset(0, 45),
      tooltip: 'Select screen size',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _selectedMode != DeviceMode.desktop
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getDeviceIconByMode(_selectedMode),
          size: 20,
          color: _selectedMode != DeviceMode.desktop
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onSelected: (mode) async {
        setState(() {
          _selectedMode = mode;
        });

        if (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          switch (mode) {
            case DeviceMode.phone:
              await windowManager.unmaximize();
              await windowManager.setSize(const Size(450, 850));
              await windowManager.center();
              break;
            case DeviceMode.tablet:
              await windowManager.unmaximize();
              await windowManager.setSize(const Size(950, 900));
              await windowManager.center();
              break;
            case DeviceMode.desktop:
              await windowManager.maximize();
              break;
          }
        }
      },
      itemBuilder: (context) => [
        _buildDeviceMenuItem(
          DeviceMode.desktop,
          Icons.desktop_windows_outlined,
          'Desktop size',
        ),
        _buildDeviceMenuItem(
          DeviceMode.tablet,
          Icons.tablet_mac,
          'Tablet size',
        ),
        _buildDeviceMenuItem(DeviceMode.phone, Icons.smartphone, 'Phone size'),
      ],
    );
  }

  PopupMenuItem<DeviceMode> _buildDeviceMenuItem(
    DeviceMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedMode == mode;
    return PopupMenuItem<DeviceMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isSelected) ...[
            Spacer(),
            Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
          ],
        ],
      ),
    );
  }

  IconData _getDeviceIconByMode(DeviceMode mode) {
    switch (mode) {
      case DeviceMode.phone:
        return Icons.smartphone;
      case DeviceMode.tablet:
        return Icons.tablet_mac;
      case DeviceMode.desktop:
        return Icons.desktop_windows_outlined;
    }
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _BootstrapOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onError;
  const _BootstrapOverlay({required this.onComplete, required this.onError});

  @override
  State<_BootstrapOverlay> createState() => _BootstrapOverlayState();
}

class _BootstrapOverlayState extends State<_BootstrapOverlay> {
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startBootstrapping();
  }

  Future<void> _startBootstrapping() async {
    setState(() { _progress = 0; _hasError = false; });
    try {
      // Simulate real updates with a chance of failure
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (Random().nextInt(20) == 0) throw Exception("Timeout");
        if (mounted) setState(() => _progress = i / 10.0);
      }
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        // If it's a persistent error, we can show the full connectivity screen
        if (Random().nextBool()) widget.onError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Updating Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (_hasError) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Update Failed', style: TextStyle(color: Colors.red)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: widget.onComplete, child: const Text('Close')),
                    ElevatedButton(onPressed: _startBootstrapping, child: const Text('Retry')),
                  ],
                ),
              ] else ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionErrorOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  const _ConnectionErrorOverlay({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 64, color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 32),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please check your network settings and try again. Connection timed out while reaching the servers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTab {
  final String id;
  final String title;
  final IconData icon;
  final Widget widget;
  final bool canClose;

  AppTab({
    required this.id,
    required this.title,
    required this.icon,
    required this.widget,
    this.canClose = true,
  });
}

class WelcomeTab extends StatelessWidget {
  const WelcomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: Theme.of(context).colorScheme.surface,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Smart Orders',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an option from the menu above to get started',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}