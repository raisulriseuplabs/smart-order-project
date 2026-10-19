import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';

enum UpdateState {
  checking,
  available,
  installing,
  upToDate,
  failed,
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  static bool _isChecking = false;

  static void show(BuildContext context) {
    if (_isChecking) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UpdateDialog(),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  UpdateState _state = UpdateState.checking;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    UpdateDialog._isChecking = true;
    _startChecking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    UpdateDialog._isChecking = false;
    super.dispose();
  }

  void _startChecking() {
    setState(() {
      _state = UpdateState.checking;
      _progress = 0.0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          timer.cancel();
          _onCheckingComplete();
        }
      });
    });
  }

  void _onCheckingComplete() {
    // For demonstration, alternate between states or pick one
    // In a real app, this would call an API
    setState(() {
      // 80% chance for update available, 20% for up to date
      _state = DateTime.now().second % 5 == 0 ? UpdateState.upToDate : UpdateState.available;
    });
  }

  void _startInstalling() {
    setState(() {
      _state = UpdateState.installing;
      _progress = 0.0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          timer.cancel();
          _state = UpdateState.upToDate;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: _buildContent(),
            ),
            if (_state != UpdateState.checking && _state != UpdateState.installing)
              _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    switch (_state) {
      case UpdateState.checking:
        title = 'Checking for Updates';
        break;
      case UpdateState.available:
        title = 'Update Available';
        break;
      case UpdateState.installing:
        title = 'Installing Update';
        break;
      case UpdateState.upToDate:
        title = "You're Up to Date";
        break;
      case UpdateState.failed:
        title = 'Update Check Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (_state != UpdateState.installing)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case UpdateState.checking:
        return _buildProgressContent('Searching for updates...', showLoader: true);
      case UpdateState.available:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.system_update_alt_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 24),
            Text(
              'A new version is available for installation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, 
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _VersionInfo(label: 'CURRENT', version: '1.0.2'),
                  Container(
                    width: 1,
                    height: 30,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  _VersionInfo(label: 'AVAILABLE', version: '1.1.0'),
                ],
              ),
            ),
          ],
        );
      case UpdateState.installing:
        return _buildProgressContent('Installing, please wait...', showLoader: false);
      case UpdateState.upToDate:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF106E3F)),
            ),
            SizedBox(height: 24),
            Text(
              'Your application is running the latest version.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, 
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Software version: v1.0.2',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        );
      case UpdateState.failed:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            ),
            SizedBox(height: 24),
            Text(
              'Update Check Failed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Unable to check for updates. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        );
    }
  }

  Widget _buildProgressContent(String message, {required bool showLoader}) {
    return Column(
      children: [
        if (showLoader)
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5, 
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        Text(
          message,
          style: TextStyle(
            fontSize: 15, 
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_state == UpdateState.available || _state == UpdateState.failed)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if (_state == UpdateState.available) {
                _startInstalling();
              } else if (_state == UpdateState.failed) {
                _startChecking();
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _state == UpdateState.failed ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(_state == UpdateState.available 
                ? 'Install Update' 
                : _state == UpdateState.failed 
                    ? 'Retry' 
                    : 'OK'),
          ),
        ],
      ),
    );
  }
}

class _VersionInfo extends StatelessWidget {
  final String label;
  final String version;

  const _VersionInfo({required this.label, required this.version});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10, 
            color: Theme.of(context).colorScheme.outline, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          version,
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}