import 'package:flutter/material.dart';
import 'package:smart_orders_desktop/core/api/mock_api_service.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final MockApiService _api = MockApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getOrders();
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _orders = response.data!.items.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch =
          order['orderNumber'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          order['company'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesStatus =
          _statusFilter == 'All' ||
          order['status'].toString().toLowerCase() ==
              _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showOrderDetails(String orderId) {
    final isMobile = Responsive.isMobile(context);
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _OrderDetailsDialog(
              orderId: orderId,
              scrollController: scrollController,
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _OrderDetailsDialog(orderId: orderId),
      );
    }
  }

  void _showOrderPreview(String orderId) {
    final isMobile = Responsive.isMobile(context);
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _OrderPreviewDialog(orderId: orderId),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _OrderPreviewDialog(orderId: orderId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final isCompact = Responsive.isCompact(context);

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Actions
              _buildHeader(isMobile),

              // Search & Filters (desktop only)
              if (!isMobile) _buildFilters(isMobile),

              const SizedBox(height: 8),

              // Orders Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isCompact ? 16 : 24),
                    vertical: 8,
                  ),
                  child: _isLoading
                      ? Center(
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
                        )
                      : _filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : isMobile
                      ? _buildCardView()
                      : _buildTableView(isCompact: isCompact),
                ),
              ),

              // Footer / Load More
              if (!_isLoading && _filteredOrders.isNotEmpty) _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filteredOrders.length} of ${_orders.length} Order(s)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            OutlinedButton(
              onPressed: _isLoading ? null : _loadOrders,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Text('Reload', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 8),
                  Icon(Icons.refresh, size: 16),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _loadOrders,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reload'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          _buildSearchBar(),
          SizedBox(width: 16),
          _buildStatusDropdown(),
          Spacer(),
          Text(
            '${_filteredOrders.length} of ${_orders.length} Order(s)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({double width = 300}) {
    return SizedBox(
      width: width,
      height: 40,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search order number or company...',
          hintStyle: TextStyle(fontSize: 13),
          prefixIcon: Icon(Icons.search, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusFilter,
          onChanged: (value) {
            if (value != null) setState(() => _statusFilter = value);
          },
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          items: [
            'All',
            'Invoiced',
            'Pending',
            'Cancelled',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_searchQuery.isNotEmpty || _statusFilter != 'All')
            TextButton(
              onPressed: () => setState(() {
                _searchQuery = '';
                _statusFilter = 'All';
              }),
              child: Text('Clear filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildTableView({bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 24,
                vertical: isCompact ? 12 : 16,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: isCompact
                  ? const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 900,
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderCell('Company')),
                            Expanded(flex: 1, child: _HeaderCell('Account')),
                            Expanded(flex: 2, child: _HeaderCell('Order No.')),
                            Expanded(flex: 1, child: _HeaderCell('Date')),
                            Expanded(flex: 1, child: _HeaderCell('Invoice')),
                            Expanded(
                              flex: 1,
                              child: _HeaderCell(
                                'Total',
                                align: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _HeaderCell(
                                'Status',
                                align: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _HeaderCell(
                                'Actions',
                                align: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Row(
                      children: [
                        Expanded(flex: 2, child: _HeaderCell('Company')),
                        Expanded(flex: 1, child: _HeaderCell('Account')),
                        Expanded(flex: 2, child: _HeaderCell('Order No.')),
                        Expanded(flex: 1, child: _HeaderCell('Date')),
                        Expanded(flex: 1, child: _HeaderCell('Invoice')),
                        Expanded(
                          flex: 1,
                          child: _HeaderCell('Total', align: TextAlign.right),
                        ),
                        Expanded(
                          flex: 1,
                          child: _HeaderCell('Status', align: TextAlign.center),
                        ),
                        Expanded(
                          flex: 1,
                          child: _HeaderCell('Actions', align: TextAlign.right),
                        ),
                      ],
                    ),
            ),
            const Divider(height: 1),
            // Table Rows
            Expanded(
              child: ListView.separated(
                itemCount: _filteredOrders.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return isCompact
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 900,
                            child: _buildOrderTableRow(
                              order,
                              isCompact: isCompact,
                            ),
                          ),
                        )
                      : _buildOrderTableRow(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTableRow(
    Map<String, dynamic> order, {
    bool isCompact = false,
  }) {
    return InkWell(
      onTap: () => _showOrderDetails(order['id'] ?? ''),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                order['company'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                order['account'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                order['orderNumber'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                order['orderDate'] ?? '',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                order['status']?.toString().toLowerCase() == 'cancelled'
                    ? '-'
                    : (order['invoice'] ?? 'N/A'),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      order['invoice'] != null &&
                          order['status']?.toString().toLowerCase() !=
                              'cancelled'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration:
                      order['invoice'] != null &&
                          order['status']?.toString().toLowerCase() !=
                              'cancelled'
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'R${(order['orderTotalIncl'] as double).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(child: _StatusBadge(order['status'])),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    onPressed: () => _showOrderPreview(order['id'] ?? ''),
                    tooltip: 'Preview',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: () => _showOrderDetails(order['id'] ?? ''),
                    tooltip: 'Details',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.separated(
      itemCount: _filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        final total = (order['orderTotalIncl'] as double).toStringAsFixed(2);
        // User image mockup shows Invoice Total, Invoice No, Invoice Date etc.
        // We use mock data or same values as placeholder where missing.

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Order Number & Date Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '#${order['orderNumber']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      order['orderDate'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Company & Account Info
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      order['company'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                    SizedBox(width: 8),
                    Text(
                      order['account'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(order['status']),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Info grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Row 1: Order Total & Invoice Total
                    Row(
                      children: [
                        Expanded(
                          child: _OrderInfoTile(
                            label: 'ORDER TOTAL',
                            value: 'R$total',
                            isBold: true,
                          ),
                        ),
                        Expanded(
                          child: _OrderInfoTile(
                            label: 'INVOICE TOTAL',
                            value:
                                'R${(order['invoiceTotalIncl'] as double?)?.toStringAsFixed(2) ?? total}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Row 2: Invoice & Invoice Date
                    Row(
                      children: [
                        Expanded(
                          child: _OrderInfoTile(
                            label: 'INVOICE',
                            value: order['invoice'] ?? 'N/A',
                            valueColor: order['invoice'] != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Expanded(
                          child: _OrderInfoTile(
                            label: 'INVOICE DATE',
                            value:
                                order['invoiceDate'] ??
                                order['orderDate'] ??
                                '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),

              // Actions row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showOrderPreview(order['id'] ?? ''),
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          'Preview',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showOrderDetails(order['id'] ?? ''),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text(
                          'Details',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Load More Orders'),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final TextAlign align;

  const _HeaderCell(this.title, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      textAlign: align,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final dynamic status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final statusStr = status.toString();
    Color baseColor;

    switch (statusStr.toLowerCase()) {
      case 'invoiced':
        baseColor = const Color(0xFF16A34A);
        break;
      case 'pending':
        baseColor = const Color(0xFFF59E0B);
        break;
      case 'cancelled':
        baseColor = Theme.of(context).colorScheme.error;
        break;
      default:
        baseColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        statusStr,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OrderInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _OrderInfoTile({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Order Details Dialog Widget
class _OrderDetailsDialog extends StatefulWidget {
  final String orderId;
  final ScrollController? scrollController;

  const _OrderDetailsDialog({required this.orderId, this.scrollController});

  @override
  State<_OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<_OrderDetailsDialog> {
  final MockApiService _api = MockApiService();
  final ScrollController _horizontalController = ScrollController();
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      final response = await _api.getOrderDetails(widget.orderId);
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _details = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = widget.scrollController != null;
    final screenWidth = mediaQuery.size.width;

    final Widget content = Container(
      width: isMobile ? double.infinity : screenWidth * 0.9,
      height: isMobile ? null : 650,
      constraints: isMobile
          ? null
          : BoxConstraints(maxWidth: 1400, minWidth: 800),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 24,
        isMobile ? 12 : 24,
        isMobile ? 12 : 24,
        isMobile ? 24 : 24,
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _details == null
          ? Center(child: Text('Error loading order details'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Drag Handle for mobile
                if (isMobile)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                // Improved Header to match design
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.file_download_outlined,
                                color: Theme.of(context).colorScheme.outline,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${_details!['orderNumber']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(_details!['status']),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.outline),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        thickness: 1.0,
                        radius: const Radius.circular(3),
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1450,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Row(
                                    children: [
                                      _ItemHeaderCell('Qty', width: 60),
                                      _ItemHeaderCell('Price', width: 80),
                                      _ItemHeaderCell('Free', width: 60),
                                      _ItemHeaderCell('Ord. Total', width: 100),
                                      _ItemHeaderCell('Inv Qty', width: 70),
                                      _ItemHeaderCell('Inv Price', width: 90),
                                      _ItemHeaderCell('Inv Free', width: 70),
                                      _ItemHeaderCell('Inv. Total', width: 100),
                                      _ItemHeaderCell(
                                        'Invoice',
                                        width: 100,
                                        align: TextAlign.center,
                                      ),
                                      _ItemHeaderCell(
                                        'Saving',
                                        width: 80,
                                        align: TextAlign.right,
                                      ),
                                      _ItemHeaderCell(
                                        'Description',
                                        width: 250,
                                      ),
                                      _ItemHeaderCell(
                                        'Main Acc',
                                        width: 90,
                                        align: TextAlign.center,
                                      ),
                                      _ItemHeaderCell(
                                        'Item Result',
                                        width: 110,
                                        align: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount:
                                        (_details!['items'] as List).length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = _details!['items'][index];
                                      final ordPrice =
                                          (item['ordPrice'] ?? 0.0) as double;
                                      final ordQty =
                                          (item['ordQty'] ?? 0) as int;
                                      final invPrice =
                                          (item['invPrice'] ?? 0.0) as double;
                                      final invQty =
                                          (item['invQty'] ?? 0) as int;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            _ItemCell('$ordQty', width: 60),
                                            _ItemCell(
                                              ordPrice.toStringAsFixed(2),
                                              width: 80,
                                            ),
                                            _ItemCell(
                                              '${item['ordFree']}',
                                              width: 60,
                                            ),
                                            _ItemCell(
                                              (ordPrice * ordQty)
                                                  .toStringAsFixed(2),
                                              width: 100,
                                            ),
                                            _ItemCell('$invQty', width: 70),
                                            _ItemCell(
                                              invPrice.toStringAsFixed(2),
                                              width: 90,
                                            ),
                                            _ItemCell(
                                              '${item['invFree']}',
                                              width: 70,
                                            ),
                                            _ItemCell(
                                              (invPrice * invQty)
                                                  .toStringAsFixed(2),
                                              width: 100,
                                            ),
                                            _ItemCell(
                                              item['result']
                                                          ?.toString()
                                                          .toLowerCase() ==
                                                      'cancelled'
                                                  ? '-'
                                                  : '${item['invoice'] ?? '-'}',
                                              width: 100,
                                              align: TextAlign.center,
                                            ),
                                            _ItemCell(
                                              ((item['saving'] ?? 0.0)
                                                      as double)
                                                  .toStringAsFixed(2),
                                              width: 80,
                                              align: TextAlign.right,
                                            ),
                                            _ItemCell(
                                              '${item['description']}',
                                              width: 250,
                                            ),
                                            _ItemCell(
                                              '${item['mainAcc'] ?? 'No'}',
                                              width: 90,
                                              align: TextAlign.center,
                                            ),
                                            _ItemResultBadge(item['result']),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.outline,
                      size: 18,
                    ),
                    Spacer(),
                    SizedBox(
                      height: 36,
                      width: 80,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );

    if (isMobile) {
      return content;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: content,
    );
  }
}

class _ItemHeaderCell extends StatelessWidget {
  final String title;
  final double width;
  final TextAlign align;

  const _ItemHeaderCell(
    this.title, {
    required this.width,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ItemCell extends StatelessWidget {
  final String text;
  final double width;
  final TextAlign align;

  const _ItemCell(
    this.text, {
    required this.width,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ItemResultBadge extends StatelessWidget {
  final dynamic result;

  const _ItemResultBadge(this.result);

  @override
  Widget build(BuildContext context) {
    final resStr = result.toString();
    Color baseColor = Colors.grey;

    if (resStr.toLowerCase() == 'invoiced' ||
        resStr.toLowerCase() == 'active') {
      baseColor = const Color(0xFF16A34A);
    } else if (resStr.toLowerCase() == 'cancelled' ||
        resStr.toLowerCase() == 'inactive') {
      baseColor = Theme.of(context).colorScheme.error;
    } else if (resStr.toLowerCase() == 'pending') {
      baseColor = const Color(0xFFF59E0B);
    }

    return SizedBox(
      width: 110,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: baseColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            resStr,
            style: TextStyle(
              color: baseColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Order Preview Dialog Widget
class _OrderPreviewDialog extends StatefulWidget {
  final String orderId;

  const _OrderPreviewDialog({required this.orderId});

  @override
  State<_OrderPreviewDialog> createState() => _OrderPreviewDialogState();
}

class _OrderPreviewDialogState extends State<_OrderPreviewDialog> {
  final MockApiService _api = MockApiService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  double _zoom = 0.8;
  bool _isAutoFit = false;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final response = await _api.getOrderDetails(widget.orderId);
      if (response.success && response.data != null) {
        if (!mounted) return;
        setState(() {
          _details = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_details == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${_details!['account']} / ${_details!['accountName']}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Status: ${_details!['status']}'),
                      pw.Text('Order Date: ${_details!['orderDate']}'),
                    ],
                  ),
                  pw.Text(
                    '${_details!['company']} / CITY MEDICAL',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Qty', textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Price', textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Total', textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  ...(_details!['items'] as List).map((item) {
                    final qty = (item['ordQty'] ?? 0) as int;
                    final price = (item['ordPrice'] ?? 0.0) as double;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item['description']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('$qty', textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'R${price.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'R${(qty * price).toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'order_${_details!['orderNumber']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = constraints.maxWidth;
          final dialogHeight = constraints.maxHeight;

          // Initial auto-fit logic
          if (_isAutoFit && _details != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                const double docWidth = 800.0;
                final double availableWidth =
                    dialogWidth - 80; // More margin for fit
                final double fitZoom = (availableWidth / docWidth).clamp(
                  0.3,
                  1.5,
                );
                if ((_zoom - fitZoom).abs() > 0.01) {
                  setState(() => _zoom = fitZoom);
                }
              }
            });
          }

          return Container(
            width: dialogWidth,
            height: dialogHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Toolbar
                _buildToolbar(isMobile),

                // Document View
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _details == null
                      ? const Center(
                          child: Text(
                            'Error loading preview',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Scrollbar(
                          controller: _verticalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Scrollbar(
                                controller: _horizontalController,
                                thumbVisibility: true,
                                notificationPredicate: (notification) =>
                                    notification.depth == 0,
                                child: SingleChildScrollView(
                                  controller: _horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: SizedBox(
                                      width: 800 * _zoom,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.topLeft,
                                        child: _buildDocumentContent(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                // Footer
                _buildFooter(isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return LayoutBuilder(
      builder: (context, toolbarConstraints) {
        final bool shouldCollapse = toolbarConstraints.maxWidth < 700;

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 18),
              const SizedBox(width: 8),
              if (toolbarConstraints.maxWidth > 400)
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              const SizedBox(width: 24), // Gap after title
              // Main Tools
              if (!shouldCollapse) ...[
                const _ToolbarIcon(Icons.grid_view, tooltip: 'Grid'),
                const _ToolbarIcon(Icons.search, tooltip: 'Search'),
                _buildDivider(),
                const _ToolbarIcon(Icons.print, tooltip: 'Print'),
                const _ToolbarIcon(Icons.save, tooltip: 'Save'),
                const _ToolbarIcon(Icons.search_sharp, tooltip: 'Inspect'),
                _buildDivider(),
                const _ToolbarIcon(Icons.pan_tool, tooltip: 'Pan'),
                _buildZoomControls(),
                _buildDivider(),
                const _ToolbarIcon(Icons.email, tooltip: 'Email'),
              ] else ...[
                // Compact view tools
                _buildZoomControls(),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More tools',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'grid',
                      child: Row(
                        children: [
                          Icon(Icons.grid_view, size: 18),
                          SizedBox(width: 12),
                          Text('Grid View'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'print',
                      child: Row(
                        children: [
                          Icon(Icons.print, size: 18),
                          SizedBox(width: 12),
                          Text('Print'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.save, size: 18),
                          SizedBox(width: 12),
                          Text('Save'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'email',
                      child: Row(
                        children: [
                          Icon(Icons.email, size: 18),
                          SizedBox(width: 12),
                          Text('Email PDF'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              if (!shouldCollapse) const Spacer(),

              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.cancel, color: Colors.red, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.zoom_out, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () {
            setState(() {
              _zoom = (_zoom - 0.1).clamp(0.3, 2.0);
              _isAutoFit = false;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.zoom_in, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () {
            setState(() {
              _zoom = (_zoom + 0.1).clamp(0.3, 2.0);
              _isAutoFit = false;
            });
          },
        ),
        SizedBox(width: 8),
        InkWell(
          onTap: () => setState(() => _isAutoFit = !_isAutoFit),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isAutoFit
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.white,
              border: Border.all(
                color: _isAutoFit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${(_zoom * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: _isAutoFit ? Theme.of(context).colorScheme.primary : Colors.black87,
                fontWeight: _isAutoFit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _buildDocumentContent() {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 704, // 800 - 48*2 padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_details!['account']} / ${_details!['accountName']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow('Status', _details!['status']),
                      _InfoRow('Order Date', _details!['orderDate']),
                      _InfoRow('Invoice Date', _details!['invoiceDate'] ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_details!['company']} / CITY MEDICAL - PRETORIA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1.5, color: Colors.black),
          const SizedBox(height: 24),

          // Table Header
          Container(
            width: 704,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: _DocHeaderCell('Product Description')),
                _DocHeaderCell('Ord. Qty', width: 40, align: TextAlign.right),
                _DocHeaderCell('Inv Qty', width: 40, align: TextAlign.right),
                _DocHeaderCell('Ord Free', width: 40, align: TextAlign.right),
                _DocHeaderCell('Inv Free', width: 40, align: TextAlign.right),
                _DocHeaderCell('Ord Price', width: 60, align: TextAlign.right),
                _DocHeaderCell('Inv Price', width: 60, align: TextAlign.right),
                _DocHeaderCell('Total', width: 60, align: TextAlign.right),
                _DocHeaderCell('Result', width: 80, align: TextAlign.right),
              ],
            ),
          ),

          // Table Items
          ...(_details!['items'] as List).map((item) {
            final ordQty = (item['ordQty'] ?? 0) as int;
            final ordPrice = (item['ordPrice'] ?? 0.0) as double;
            return Container(
              width: 704,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      item['description'],
                      style: const TextStyle(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _DocCell('$ordQty', width: 40, align: TextAlign.right),
                  _DocCell(
                    '${item['invQty']}',
                    width: 40,
                    align: TextAlign.right,
                  ),
                  _DocCell(
                    '${item['ordFree']}',
                    width: 40,
                    align: TextAlign.right,
                  ),
                  _DocCell(
                    '${item['invFree']}',
                    width: 40,
                    align: TextAlign.right,
                  ),
                  _DocCell(
                    ordPrice.toStringAsFixed(2),
                    width: 60,
                    align: TextAlign.right,
                  ),
                  _DocCell(
                    (item['invPrice'] as double).toStringAsFixed(2),
                    width: 60,
                    align: TextAlign.right,
                  ),
                  _DocCell(
                    (ordQty * ordPrice).toStringAsFixed(2),
                    width: 60,
                    align: TextAlign.right,
                  ),
                  _DocCell(item['result'], width: 80, align: TextAlign.right),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text(
            isMobile ? 'P 1/1' : 'Page 1 of 1',
            style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 11),
          ),
          Spacer(),
          Text(
            '${(_zoom * 100).toInt()}%',
            style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 11),
          ),
          SizedBox(width: 12),
          if (!isMobile)
            SizedBox(
              width: 140,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _zoom.clamp(0.3, 2.0),
                  min: 0.3,
                  max: 2.0,
                  onChanged: (v) {
                    setState(() {
                      _zoom = v;
                      _isAutoFit = false;
                    });
                  },
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download, size: 18, color: Colors.white),
            padding: EdgeInsets.zero,
            tooltip: 'Download PDF',
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _ToolbarIcon(this.icon, {required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      tooltip: tooltip,
      onPressed: () {},
      splashRadius: 20,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DocHeaderCell extends StatelessWidget {
  final String text;
  final double? width;
  final TextAlign align;

  const _DocHeaderCell(this.text, {this.width, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _DocCell extends StatelessWidget {
  final String text;
  final double? width;
  final TextAlign align;

  const _DocCell(this.text, {this.width, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}