import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/core/api/mock_api_service.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';
import 'package:smart_orders_desktop/features/auth/state/auth_state.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final MockApiService _api = MockApiService();

  // State
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orderLines = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showAgeAnalysis = false;
  Map<String, dynamic>? _ageAnalysisData;
  bool _isAgeAnalysisLoading = false;
  String? _selectedProductId;
  bool _showPromotionsOnly = false;
  bool _showInStockOnly = false;
  String _sortBy = 'Name (A-Z)';
  bool _isOrderSummaryExpanded = false;
  bool _isSidebarExpanded = true;
  double? _lastWidth;
  final ScrollController _horizontalScrollController = ScrollController();

  final String _selectedCustomerCategory = 'Pharmacy Retail';

  // Order totals
  double _totalSaving = 0.0;
  double _totalVat = 0.0;
  double _totalInclusive = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _fetchAgeAnalysis();
    _initializeMockOrder();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _initializeMockOrder() {
    // Start with empty order lines as requested
    _orderLines = [];
    _recalculateTotals();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getProducts();
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _products = response.data!.items.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditLineDialog(
    Map<String, dynamic> product, {
    int? existingQuantity,
    int? lineIndex,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _MobileOrderLineSheet(
          product: product,
          quantity: existingQuantity ?? 1,
          isEditing: lineIndex != null,
          onSave: (quantity) {
            _updateOrderLines(product, quantity, lineIndex);
            Navigator.pop(context);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _EditOrderLineDialog(
          product: product,
          quantity: existingQuantity ?? 1,
          isEditing: lineIndex != null,
          onSave: (quantity) {
            _updateOrderLines(product, quantity, lineIndex);
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _updateOrderLines(
    Map<String, dynamic> product,
    int quantity,
    int? lineIndex,
  ) {
    setState(() {
      if (lineIndex != null) {
        // Update existing line
        final line = _orderLines[lineIndex];
        line['quantity'] = quantity;
        line['totalExcl'] = quantity * line['price'];
        line['vat'] = quantity * line['price'] * 0.05;
        line['totalIncl'] = quantity * line['price'] * 1.05;
      } else {
        // Insert new line
        _orderLines.add({
          'id': DateTime.now().toString(),
          'productId': product['id'],
          'description': product['name'],
          'quantity': quantity,
          'free': 0,
          'price': product['price'],
          'totalExcl': quantity * product['price'],
          'vat': quantity * product['price'] * 0.05,
          'totalIncl': quantity * product['price'] * 1.05,
          'saving': 0.00,
          'sku': product['sku'],
          'supplier': product['supplier'],
        });
      }
      _recalculateTotals();
    });
  }

  void _removeOrderLine(int index) {
    _showConfirmationDialog(
      title: 'Delete Item?',
      message: 'Are you sure you want to delete this item from your current order? This action cannot be undone.',
      confirmLabel: 'Yes, Delete Item',
      icon: Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
      onConfirm: () {
        setState(() {
          _orderLines.removeAt(index);
          _recalculateTotals();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from the order'),
            backgroundColor: const Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(confirmLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recalculateTotals() {
    double saving = 0;
    double vat = 0;
    double totalIncl = 0;

    for (var line in _orderLines) {
      saving += line['saving'] as double;
      vat += line['vat'] as double;
      totalIncl += line['totalIncl'] as double;
    }

    setState(() {
      _totalSaving = saving;
      _totalVat = vat;
      _totalInclusive = totalIncl;
    });
  }

  Future<void> _fetchAgeAnalysis() async {
    setState(() => _isAgeAnalysisLoading = true);
    try {
      final response = await _api.getAgeAnalysis();
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _ageAnalysisData = response.data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading age analysis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAgeAnalysisLoading = false);
      }
    }
  }

  Future<void> _downloadAgeAnalysis() async {
    if (_ageAnalysisData == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final buckets = _ageAnalysisData!['buckets'] as Map<String, dynamic>;

          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Age Analysis Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#005696'),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'City Medical - Smart Orders',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      DateTime.now().toString().split(' ')[0],
                      style: const pw.TextStyle(color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  _ageAnalysisData!['accountCode'] ?? '',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _ageAnalysisData!['accountName'] ?? '',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#EFF4F8'),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: buckets.entries.map((entry) {
                      final key = entry.key;
                      final value = (entry.value as num).toDouble();
                      final isTotal = key == 'Total';

                      return pw.Column(
                        children: [
                          if (isTotal) pw.SizedBox(height: 10),
                          if (isTotal)
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: pw.Divider(
                                color: PdfColors.grey400,
                                thickness: 0.5,
                              ),
                            ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 6),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  key,
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: isTotal
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                    color: isTotal
                                        ? PdfColors.black
                                        : PdfColors.grey800,
                                  ),
                                ),
                                pw.Text(
                                  'R${value.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: isTotal
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                    color: isTotal
                                        ? PdfColors.black
                                        : PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey200),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'This is a system generated document.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Age_Analysis_${_ageAnalysisData!['accountCode']}.pdf',
    );
  }

  Future<bool> _sendOrder() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).value;
      final response = await _api.createOrder(
        customerCategory: _selectedCustomerCategory,
        customerRoute: 'North - Zone A',
        items: _orderLines,
        userStatus: user?.status ?? 'Active',
      );

      if (response.success) {
        if (mounted) {
          setState(() {
            _orderLines.clear();
            _recalculateTotals();
          });
          return true;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to create order'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isCompact = Responsive.isCompact(context) && !isMobile;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Auto-collapse sidebar based on width
        if (_lastWidth == null) {
          // Initial check on load
          if (width < 1100) {
            _isSidebarExpanded = false;
          }
        } else if (_lastWidth! >= 1100 && width < 1100 && _isSidebarExpanded) {
          // Transitioned from large to small
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isSidebarExpanded) {
              setState(() => _isSidebarExpanded = false);
            }
          });
        }
        _lastWidth = width;

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(isCompact: isCompact),
        );
      },
    );
  }

  Widget _buildDesktopLayout({bool isCompact = false}) {
    final panelWidth = isCompact ? 260.0 : 320.0;
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSidebarExpanded ? panelWidth : 0,
              child: ClipRect(
                child: OverflowBox(
                  minWidth: panelWidth,
                  maxWidth: panelWidth,
                  alignment: Alignment.centerLeft,
                  child: _buildLeftPanel(isCompact: isCompact),
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(child: _buildMainContent(isCompact: isCompact)),
          ],
        ),

        // Sidebar Collapse Toggle Button
        Positioned(
          left: _isSidebarExpanded ? panelWidth - 16 : 0,
          top: 150,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),

        // Age Analysis Overlay for compact desktop
        if (isCompact && _showAgeAnalysis)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showAgeAnalysis = false),
              child: Container(
                color: Colors.black54,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(
                        context,
                      ).size.width.clamp(0.0, 320.0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 20,
                              bottom: 12,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Theme.of(context).colorScheme.surface,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      setState(() => _showAgeAnalysis = false),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Age Analysis',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _AgeAnalysisPanelContent(
                                isLoading: _isAgeAnalysisLoading,
                                data: _ageAnalysisData,
                                onRefresh: _fetchAgeAnalysis,
                                onDownload: _downloadAgeAnalysis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Column(
          children: [
            // Custom Sub-header for Mobile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surface,
              child: Text(
                '$_selectedCustomerCategory · 7 ZONE A'.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Search & Filters (Mobile optimized)
            _buildSearchAndFiltersMobile(),

            // Product List
            Expanded(child: _buildProductsList()),
          ],
        ),

        // "AGE ANALYSIS" Vertical Side Tab
        Positioned(
          left: 0,
          top: 320,
          child: GestureDetector(
            onTap: () => setState(() => _showAgeAnalysis = !_showAgeAnalysis),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'AGE ANALYSIS',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Age Analysis Panel Overlay
        if (_showAgeAnalysis)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showAgeAnalysis = false),
              child: Container(
                color: Colors.black54,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(
                        context,
                      ).size.width.clamp(0.0, 320.0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: 12,
                              right: 20,
                              bottom: 12,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Theme.of(context).colorScheme.surface,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      setState(() => _showAgeAnalysis = false),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Age Analysis',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _AgeAnalysisPanelContent(
                                isLoading: _isAgeAnalysisLoading,
                                data: _ageAnalysisData,
                                onRefresh: _fetchAgeAnalysis,
                                onDownload: _downloadAgeAnalysis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Order Summary Card (Mobile)
        if (_orderLines.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMobileOrderSummary(),
          ),
      ],
    );
  }

  Widget _buildMobileOrderSummary() {
    if (!_isOrderSummaryExpanded) {
      return _buildCollapsedSendButton();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle / Indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with count and collapse
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_orderLines.length} products added',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _isOrderSummaryExpanded = false),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.outline,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _orderLines.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                indent: 0,
                endIndent: 0,
              ),
              itemBuilder: (context, index) {
                final line = _orderLines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line['description'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${line['sku']} • R ${line['price'].toStringAsFixed(2)}/unit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            _buildQtyBtn(Icons.remove, () {
                              if (line['quantity'] > 1) {
                                setState(() {
                                  line['quantity']--;
                                  line['totalExcl'] =
                                      line['quantity'] * line['price'];
                                  line['vat'] =
                                      line['quantity'] * line['price'] * 0.05;
                                  line['totalIncl'] =
                                      line['quantity'] * line['price'] * 1.05;
                                  _recalculateTotals();
                                });
                              }
                            }),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                '${line['quantity']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _buildQtyBtn(Icons.add, () {
                              setState(() {
                                line['quantity']++;
                                line['totalExcl'] =
                                    line['quantity'] * line['price'];
                                line['vat'] =
                                    line['quantity'] * line['price'] * 0.05;
                                line['totalIncl'] =
                                    line['quantity'] * line['price'] * 1.05;
                                _recalculateTotals();
                              });
                            }),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.outlineVariant,
                          size: 20,
                        ),
                        onPressed: () => _removeOrderLine(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),

          // Totals and Send Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Subtotal',
                  'R ${(_totalInclusive - _totalVat).toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'VAT (15%)',
                  'R ${_totalVat.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Savings',
                  '-R ${_totalSaving.toStringAsFixed(2)}',
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total inclusive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'R ${_totalInclusive.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _confirmSendOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shadowColor: Color(
                        0xFF00A3CC,
                      ).withValues(alpha: 0.3),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.send, size: 20),
                      ],
                    ),
                  ),
                ),
                // Padding for notch/gesture bar
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  Widget _buildCollapsedSendButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Row
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                '${_orderLines.length} products added',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Spacer(),
              Text(
                _totalInclusive.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Action Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmSendOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _isOrderSummaryExpanded = true),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.outline),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _confirmSendOrder() {
    _showConfirmationDialog(
      title: 'Send Order?',
      message: 'Are you sure you want to submit this order? This action cannot be undone.',
      confirmLabel: 'Confirm Order',
      icon: Icons.send_outlined,
      color: Theme.of(context).colorScheme.primary,
      onConfirm: _handleSendOrder,
    );
  }

  void _handleSendOrder() async {
    final success = await _sendOrder();
    if (success) {
      _showSuccessModal();
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Order has been sent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFiltersMobile() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Rounded Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.outline,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Filter Chips and Sort
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChipPill(
                  'All Items',
                  !_showPromotionsOnly && !_showInStockOnly,
                  () {
                    setState(() {
                      _showPromotionsOnly = false;
                      _showInStockOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChipPill('Promotions', _showPromotionsOnly, () {
                  setState(() => _showPromotionsOnly = !_showPromotionsOnly);
                }),
                const SizedBox(width: 8),
                _buildFilterChipPill('In Stock', _showInStockOnly, () {
                  setState(() => _showInStockOnly = !_showInStockOnly);
                }),
                SizedBox(width: 12),
                PopupMenuButton<String>(
                  offset: Offset(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) => setState(() => _sortBy = value),
                  itemBuilder: (context) => [
                    _buildSortMenuItem('Name (A-Z)'),
                    _buildSortMenuItem('Name (Z-A)'),
                    _buildSortMenuItem('Price (Low-High)'),
                    _buildSortMenuItem('Price (High-Low)'),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SORT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipPill(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // The sidebar content is moved to its own widget class for cleaner state management if needed,
  // but for now we'll keep it as a method or a local widget to maintain access to state.
  Widget _buildLeftPanel({bool isCompact = false}) {
    return Column(
      children: [
        _buildCustomerInfo(),
        _buildSearchAndFilters(),
        Expanded(
          child: _buildProductsList(shrinkWrap: false),
        ),
        if (isCompact) const SizedBox(height: 20),
        // Age analysis (hidden in compact mode, uses overlay)
        if (!isCompact) _buildAgeAnalysis(),
        // Age analysis toggle button in compact mode
        if (isCompact)
          GestureDetector(
            onTap: () => setState(() => _showAgeAnalysis = !_showAgeAnalysis),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.surface, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Age Analysis',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent({bool isMobile = false, bool isCompact = false}) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scrollbar(
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: constraints.maxWidth > 1000
                          ? constraints.maxWidth
                          : 1000,
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          if (_orderLines.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _clearAllLines,
                                    icon: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.error),
                                    label: Text(
                                      'Clear all',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      side: BorderSide(color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildTableHeader(isCompact: isCompact),
                          Expanded(
                            child: _buildOrderTable(
                              isMobile: isMobile,
                              isCompact: isCompact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _buildPricingSummary(isMobile: isMobile, isCompact: isCompact),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUSTOMER CATEGORY',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _selectedCustomerCategory,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CUSTOMER ROUTE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'North - Zone A',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  setState(() => _sortBy = value);
                },
                itemBuilder: (context) => [
                  _buildSortMenuItem('Name (A-Z)'),
                  _buildSortMenuItem('Name (Z-A)'),
                  _buildSortMenuItem('Price (Low-High)'),
                  _buildSortMenuItem('Price (High-Low)'),
                ],
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortBy,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              _buildFilterChip(
                'Promotions only',
                _showPromotionsOnly,
                (v) => setState(() => _showPromotionsOnly = v),
              ),
              const SizedBox(width: 16),
              _buildFilterChip(
                'In Stock only',
                _showInStockOnly,
                (v) => setState(() => _showInStockOnly = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      height: 35,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: _sortBy == value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: _sortBy == value ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildProductsList({bool shrinkWrap = false}) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Developed by Abdullah Al Nahian',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final query = _searchQuery.toLowerCase();
  List<Map<String, dynamic>> filteredItems;

  if (query.isEmpty) {
    filteredItems = _products;
  } else {
    // Smart filtering exactly as described: direct matches first
    final directMatches = _products.where((p) {
      final name = p['name'].toString().toLowerCase();
      final sku = p['sku'].toString().toLowerCase();
      final gen = p['genericName']?.toString().toLowerCase() ?? '';
      return name.contains(query) || sku.contains(query) || gen.contains(query);
    }).toList();

    // Collect generics from direct matches
    final matchedGenerics = directMatches
        .where((p) => p['genericName'] != null)
        .map((p) => p['genericName'].toString().toLowerCase())
        .toSet();

    // Find alternatives (products with same generic but not in direct matches)
    final directIds = directMatches.map((p) => p['id']).toSet();
    final alternatives = _products.where((p) {
      if (p['genericName'] == null) return false;
      final pGen = p['genericName'].toString().toLowerCase();
      return matchedGenerics.contains(pGen) && !directIds.contains(p['id']);
    }).toList();

    filteredItems = [...directMatches, ...alternatives];
  }

  // Filter based on other criteria
  final filtered = filteredItems.where((p) {
    final matchesPromo = !_showPromotionsOnly || (p['hasPromo'] == true);
    final matchesStock = !_showInStockOnly || (p['inStock'] == true);
    return matchesPromo && matchesStock;
  }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Name (A-Z)':
          return a['name'].toString().compareTo(b['name'].toString());
        case 'Name (Z-A)':
          return b['name'].toString().compareTo(a['name'].toString());
        case 'Price (Low-High)':
          return (a['price'] as num).compareTo(b['price'] as num);
        case 'Price (High-Low)':
          return (b['price'] as num).compareTo(a['price'] as num);
        default:
          return 0;
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _ProductCard(
          product: product,
          isSelected: _selectedProductId == product['id'],
          onTap: () => setState(() => _selectedProductId = product['id']),
          onAdd: product['stockStatus'] == 'Out of Stock'
              ? null
              : () => _showEditLineDialog(product),
        );
      },
    );
  }

  Widget _buildAgeAnalysis() {
    return _AgeAnalysisPanel(
      isExpanded: _showAgeAnalysis,
      isLoading: _isAgeAnalysisLoading,
      data: _ageAnalysisData,
      onToggle: () => setState(() => _showAgeAnalysis = !_showAgeAnalysis),
      onRefresh: _fetchAgeAnalysis,
      onDownload: _downloadAgeAnalysis,
    );
  }

  // Removed redundant _buildOrderHeader

  void _clearAllLines() {
    _showConfirmationDialog(
      title: 'Clear All Items?',
      message: 'Are you sure you want to remove all items from your current order? This action cannot be undone.',
      confirmLabel: 'Yes, Clear All',
      icon: Icons.delete_sweep_outlined,
      color: Theme.of(context).colorScheme.error,
      onConfirm: () {
        setState(() {
          _orderLines.clear();
          _recalculateTotals();
        });
      },
    );
  }

  Widget _buildOrderTable({bool isMobile = false, bool isCompact = false}) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _orderLines.length + 1,
      separatorBuilder: (_, index) => index < _orderLines.length
          ? const Divider(height: 1)
          : const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index == _orderLines.length) {
          return const SizedBox(height: 16);
        }
        return _buildOrderLineRow(index, isCompact: isCompact);
      },
    );
  }

  Widget _buildTableHeader({bool isCompact = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 4, child: _HeaderCell('Description')),
          const Expanded(
            flex: 1,
            child: _HeaderCell('Qty', align: TextAlign.right),
          ),
          const Expanded(
            flex: 1,
            child: _HeaderCell('Free', align: TextAlign.right),
          ),
          const Expanded(
            flex: 2,
            child: _HeaderCell('Price', align: TextAlign.right),
          ),
          const Expanded(
            flex: 2,
            child: _HeaderCell('Excl.', align: TextAlign.right),
          ),
          const Expanded(
            flex: 1,
            child: _HeaderCell('VAT', align: TextAlign.right),
          ),
          const Expanded(
            flex: 2,
            child: _HeaderCell('Incl.', align: TextAlign.right),
          ),
          const Expanded(
            flex: 2,
            child: _HeaderCell('Save', align: TextAlign.right),
          ),
          SizedBox(width: isCompact ? 36 : 40),
        ],
      ),
    );
  }

  Widget _buildOrderLineRow(int index, {bool isCompact = false}) {
    final line = _orderLines[index];
    final productId = line['productId'] ?? '';
    final product = _products.firstWhere(
      (p) => p['id'] == productId,
      orElse: () => line,
    );

    final rowContent = Row(
      children: [
        Expanded(
          flex: 4,
          child: InkWell(
            onTap: () => _showEditLineDialog(
              product,
              existingQuantity: line['quantity'],
              lineIndex: index,
            ),
            child: Text(
              line['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextFormField(
              initialValue: '${line['quantity']}',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onFieldSubmitted: (v) {
                final q = int.tryParse(v);
                if (q != null && q > 0) {
                  setState(() {
                    line['quantity'] = q;
                    line['totalExcl'] = q * line['price'];
                    line['vat'] = q * line['price'] * 0.05;
                    line['totalIncl'] = q * line['price'] * 1.05;
                    _recalculateTotals();
                  });
                }
              },
            ),
          ),
        ),
        Expanded(flex: 1, child: _DataCellPill('${line['free']}')),
        Expanded(
          flex: 2,
          child: _DataCellText('R${line['price'].toStringAsFixed(2)}'),
        ),
        Expanded(
          flex: 2,
          child: _DataCellText('R${line['totalExcl'].toStringAsFixed(2)}'),
        ),
        Expanded(
          flex: 1,
          child: _DataCellText('R${line['vat'].toStringAsFixed(2)}'),
        ),
        Expanded(
          flex: 2,
          child: _DataCellText(
            'R${line['totalIncl'].toStringAsFixed(2)}',
            isBold: true,
          ),
        ),
        Expanded(
          flex: 2,
          child: _DataCellText(
            'R${line['saving'].toStringAsFixed(2)}',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(
          width: isCompact ? 36 : 40,
          child: IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _removeOrderLine(index),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: rowContent,
    );
  }

  Widget _buildPricingSummary({bool isMobile = false, bool isCompact = false}) {
    final titleSize = isCompact ? 14.0 : 16.0;
    final totalSize = isCompact ? 28.0 : 32.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        isCompact ? 16 : 20,
        24,
        isCompact ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pricing Summary',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _SummaryText(
                    'Saving ',
                    'R ${_totalSaving.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 24),
                  _SummaryText('VAT ', 'R ${_totalVat.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL INCLUSIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'R ${_totalInclusive.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: totalSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 32),
              _buildSendOrderButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendOrderButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _orderLines.isEmpty || _isLoading ? null : _confirmSendOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.surface,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Send Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.send_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final TextAlign align;

  const _HeaderCell(this.label, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      textAlign: align,
    );
  }
}

class _DataCellText extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isBold;

  const _DataCellText(this.text, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.right,
    );
  }
}

class _DataCellPill extends StatelessWidget {
  final String text;

  const _DataCellPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryText(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Age Analysis Panel Widget
class _AgeAnalysisPanel extends StatelessWidget {
  final bool isExpanded;
  final bool isLoading;
  final Map<String, dynamic>? data;
  final VoidCallback onToggle;
  final VoidCallback onRefresh;
  final VoidCallback onDownload;

  const _AgeAnalysisPanel({
    required this.isExpanded,
    required this.isLoading,
    this.data,
    required this.onToggle,
    required this.onRefresh,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header / Toggle Button
        GestureDetector(
          onTap: onToggle,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Row(
              children: [
                Text(
                  'Age Analysis',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_double_arrow_down
                      : Icons.keyboard_double_arrow_up,
                  color: Theme.of(context).colorScheme.surface,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Expanded Content
        if (isExpanded)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _AgeAnalysisPanelContent(
                isLoading: isLoading,
                data: data,
                onRefresh: onRefresh,
                onDownload: onDownload,
              ),
            ),
          ),
      ],
    );
  }
}

class _AgeAnalysisPanelContent extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final VoidCallback onRefresh;
  final VoidCallback onDownload;

  const _AgeAnalysisPanelContent({
    required this.isLoading,
    this.data,
    required this.onRefresh,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data!['accountCode'] ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            data!['accountName'] ?? '',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildBuckets(context, data!['buckets'] ?? {}),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PanelButton(
                  onPressed: onRefresh,
                  icon: Icons.sync,
                  label: 'Refresh',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PanelButton(
                  onPressed: onDownload,
                  icon: Icons.download_rounded,
                  label: 'Download',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBuckets(BuildContext context, Map<String, dynamic> buckets) {
    final List<Widget> widgets = [];
    final keys = buckets.keys.toList();

    // Sort buckets: Current, then numeric days (30, 60, etc), then Total last
    keys.sort((a, b) {
      if (a == 'Current') return -1;
      if (b == 'Current') return 1;
      if (a == 'Total') return 1;
      if (b == 'Total') return -1;
      
      final aNum = int.tryParse(a.split(' ')[0]) ?? 0;
      final bNum = int.tryParse(b.split(' ')[0]) ?? 0;
      return aNum.compareTo(bNum);
    });

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = buckets[key];

      if (key == 'Total') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: index % 2 == 0
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: key == 'Total'
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: key == 'Total'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'R ${(value as num).toDouble().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: key == 'Total'
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: key == 'Total' ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}

// Custom Button for Panel
class _PanelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _PanelButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Product Card Widget
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = product['stockStatus'] ?? 'Available';
    final stockColor = MockApiService.getStockColor(statusText);
    final badgeBackground = stockColor.withValues(alpha: 0.1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.15)
            : Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outline.withValues(alpha: isDark ? 0.5 : 0.2),
          width: isSelected ? 1.5 : 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product['name'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'R${(product['price'] ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: stockColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              statusText.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: stockColor,
                              ),
                            ),
                          ),
                          if (product['hasPromo'] == true) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PROMO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onAdd != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: onAdd != null
                            ? Colors.white
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Order Line Dialog (also used for inserting)
class _EditOrderLineDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final Function(int quantity) onSave;
  final bool isEditing;

  const _EditOrderLineDialog({
    required this.product,
    this.quantity = 1,
    required this.onSave,
    this.isEditing = false,
  });

  @override
  State<_EditOrderLineDialog> createState() => _EditOrderLineDialogState();
}

class _EditOrderLineDialogState extends State<_EditOrderLineDialog> {
  late int _quantity;
  final MockApiService _api = MockApiService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _api.getProductPurchaseHistory(
        widget.product['id'] ?? '',
      );
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _history = response.data!;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic stock status based on selected quantity
    final int availableStock = widget.product['stockQuantity'] ?? 0;
    String statusText;

    if (_quantity > availableStock) {
      statusText = 'Out of Stock';
    } else if (availableStock < 10 && availableStock > 0) {
      statusText = 'Low Stock';
    } else if (availableStock == 0) {
      statusText = 'Out of Stock';
    } else {
      statusText = 'Available';
    }

    final stockColor = MockApiService.getStockColor(statusText);

    final String title =
        widget.isEditing ? 'Edit Order Line' : 'Insert Order Line';
    final String buttonText =
        widget.isEditing ? 'Update Line' : 'Insert Line';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Product Info Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                                Text(
                                  'SKU: ${widget.product['sku'] ?? ''} • Supplier: ${widget.product['supplier'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: stockColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: stockColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price Excl.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R${(widget.product['price'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    /// Quantity
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildQtyButton(Icons.remove, () {
                          if (_quantity > 1) setState(() => _quantity--);
                        }),
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildQtyButton(Icons.add, () {
                          setState(() => _quantity++);
                        }),
                      ],
                    ),

                    SizedBox(height: 32),

                    /// Purchase History
                    Text(
                      'Purchase History (Months)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoadingHistory)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _history.map((item) {
                            return _buildMonthCard(
                              '${item["month"]} ${item["year"]}',
                              '${item["quantity"]}',
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            /// Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => widget.onSave(_quantity),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildMonthCard(String month, String quantity) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          SizedBox(height: 8),
          Text(
            quantity,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileOrderLineSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final Function(int quantity) onSave;
  final bool isEditing;

  const _MobileOrderLineSheet({
    required this.product,
    this.quantity = 1,
    required this.onSave,
    this.isEditing = false,
  });

  @override
  State<_MobileOrderLineSheet> createState() => _MobileOrderLineSheetState();
}

class _MobileOrderLineSheetState extends State<_MobileOrderLineSheet> {
  late int _quantity;
  final MockApiService _api = MockApiService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _api.getProductPurchaseHistory(
        widget.product['id'] ?? '',
      );
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _history = response.data!;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic stock status based on selected quantity
    final int availableStock = widget.product['stockQuantity'] ?? 0;
    String statusText;
    Color badgeColor;
    Color badgeBg;

    if (_quantity > availableStock) {
      statusText = 'Out of Stock';
      badgeColor = Colors.red;
    } else if (availableStock < 10 && availableStock > 0) {
      statusText = 'Low Stock';
      badgeColor = Colors.orange;
    } else if (availableStock == 0) {
      statusText = 'Out of Stock';
      badgeColor = Colors.red;
    } else {
      statusText = 'Available';
      badgeColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.product['name'] ?? '',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${widget.product['sku'] ?? ''}',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Supplier: ${widget.product['supplier'] ?? ''}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Text(
                  'R${(widget.product['price'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, () {
                      if (_quantity > 1) setState(() => _quantity--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyButton(Icons.add, () => setState(() => _quantity++)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Purchase History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_isLoadingHistory)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 2.5, mainAxisSpacing: 8, crossAxisSpacing: 8,
                ),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${item["month"]} ${item["year"]}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                        Text('${item["quantity"]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  );
                },
              ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => widget.onSave(_quantity),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  widget.isEditing ? 'Update Line' : 'Insert Line',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}