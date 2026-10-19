import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/core/theme/theme_provider.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';

class ParametersDialog extends ConsumerStatefulWidget {
  const ParametersDialog({super.key});

  static Future<void> show(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ParametersDialog(),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => const ParametersDialog(),
      );
    }
  }

  @override
  ConsumerState<ParametersDialog> createState() => _ParametersDialogState();
}

class _ParametersDialogState extends ConsumerState<ParametersDialog> {
  String _searchType = 'Contains';
  String _focusType = 'Search Control';
  bool _clearSearch = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return _buildMobileModal();
    }
    return _buildDesktopDialog();
  }

  Widget _buildMobileModal() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Products Search Type'),
                _buildDropdown(
                  ['Contains', 'Starts With', 'Exact Match'],
                  _searchType,
                  (v) {
                    setState(() => _searchType = v!);
                  },
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('After Inserting Line - Focus'),
                _buildDropdown(
                  ['Search Control', 'None', 'Qty Control'],
                  _focusType,
                  (v) {
                    setState(() => _focusType = v!);
                  },
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('App Theme'),
                _buildThemeDropdown(),
                const SizedBox(height: 24),
                _buildCheckboxRow(),
                const SizedBox(height: 32),
                _buildSaveButton(fullWidth: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 24,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Products Search Type'),
                  _buildDropdown(
                    ['Contains', 'Starts With', 'Exact Match'],
                    _searchType,
                    (v) {
                      setState(() => _searchType = v!);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('After Inserting Line - Focus'),
                  _buildDropdown(
                    ['Search Control', 'None', 'Qty Control'],
                    _focusType,
                    (v) {
                      setState(() => _focusType = v!);
                    },
                  ),
                  SizedBox(height: 20),
                  _buildFieldLabel('App Theme'),
                  _buildThemeDropdown(),
                  SizedBox(height: 24),
                  _buildCheckboxRow(),
                ],
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSaveButton(fullWidth: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.outline, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildThemeDropdown() {
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return _buildDropdown(
      [
        'Ocean Light', 'Emerald Health', 'Indigo Tech', 'Sunset Coral', 
        'Slate Executive', 'Midnight Dark', 'Soft Lavender', 'Cyan Modern', 
        'Warm Neutral', 'System (Auto)'
      ],
      _getThemeLabel(themeState.mode),
      (v) {
        if (v == 'Ocean Light') notifier.setThemeMode(AppThemeMode.ocean);
        if (v == 'Emerald Health') notifier.setThemeMode(AppThemeMode.emerald);
        if (v == 'Indigo Tech') notifier.setThemeMode(AppThemeMode.indigo);
        if (v == 'Sunset Coral') notifier.setThemeMode(AppThemeMode.sunset);
        if (v == 'Slate Executive') notifier.setThemeMode(AppThemeMode.slate);
        if (v == 'Midnight Dark') notifier.setThemeMode(AppThemeMode.midnight);
        if (v == 'Soft Lavender') notifier.setThemeMode(AppThemeMode.lavender);
        if (v == 'Cyan Modern') notifier.setThemeMode(AppThemeMode.cyan);
        if (v == 'Warm Neutral') notifier.setThemeMode(AppThemeMode.neutral);
        if (v == 'System (Auto)') notifier.setThemeMode(AppThemeMode.auto);
      },
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

  Widget _buildDropdown(
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _clearSearch,
            onChanged: (v) => setState(() => _clearSearch = v!),
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Clear Search After Insert Line',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton({required bool fullWidth}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Save logic
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parameters saved successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 32),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
