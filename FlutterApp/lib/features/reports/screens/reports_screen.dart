import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/core/api/mock_api_service.dart';
import 'package:smart_orders_desktop/core/utils/responsive.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final MockApiService _api = MockApiService();
  late DateTime _fromDate;
  late DateTime _toDate;
  final TextEditingController _productController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _reportData = [];
  String _selectedReportType = 'Product Purchase - Totals';
  int _rowsPerPage = 50;
  int _currentPage = 1;
  final int _totalRecords = 487;

  final ScrollController _horizontalScrollController = ScrollController();

  // Dynamic: last 12 months
  late List<String> _monthKeys;
  late List<String> _monthLabels;

  static final _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static final _monthKeysShort = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  @override
  void initState() {
    super.initState();
    _initDateRange();
    _fetchInitialData();
  }

  void _initDateRange() {
    final now = DateTime.now();
    // To = current month
    _toDate = DateTime(now.year, now.month, 1);
    // From = 11 months ago (so we cover 12 months total)
    _fromDate = DateTime(now.year, now.month - 11, 1);

    _buildMonthColumns();
  }

  void _buildMonthColumns() {
    _monthKeys = [];
    _monthLabels = [];
    // Generate 12 months from _fromDate to _toDate
    DateTime cursor = DateTime(_fromDate.year, _fromDate.month, 1);
    final endMonth = DateTime(_toDate.year, _toDate.month, 1);
    while (!cursor.isAfter(endMonth)) {
      final key = '${_monthKeysShort[cursor.month - 1]}${cursor.year}';
      final label = '${_monthNames[cursor.month - 1]} ${cursor.year}';
      _monthKeys.add(key);
      _monthLabels.add(label);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
  }

  Future<void> _fetchInitialData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _applyFilters();
  }

  @override
  void dispose() {
    _productController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _buildMonthColumns();
      });
    }
  }

  Future<void> _applyFilters() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _buildMonthColumns();
    });

    try {
      final response = await _api.getProductReport(
        fromDate: _fromDate,
        toDate: _toDate,
        productFilter: _productController.text,
      );
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _reportData = List<Map<String, dynamic>>.from(
              response.data!['reportData'],
            );
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _reportData = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalPages => (_totalRecords / _rowsPerPage).ceil();
  int get _showingStart => _reportData.isEmpty ? 0 : ((_currentPage - 1) * _rowsPerPage) + 1;
  int get _showingEnd => (_currentPage * _rowsPerPage).clamp(0, _totalRecords);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 16),
        child: Column(
          children: [
            // ── Filters ──
            _buildFilters(isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // ── Table ──
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary),
                      )
                    : _reportData.isEmpty
                        ? Center(
                            child: Text('No records found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          )
                        : _buildFrozenColumnTable(),
              ),
            ),

            SizedBox(height: isMobile ? 8 : 12),

            // ── Footer / Pagination ──
            _buildPaginationFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  FILTERS
  // ══════════════════════════════════════════════

  Widget _buildFilters(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: _buildDateField('From', _fromDate, true)),
            const SizedBox(width: 12),
            Expanded(child: _buildDateField('To', _toDate, false)),
          ]),
          const SizedBox(height: 10),
          _buildSearchField(fullWidth: true),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _buildShowBtn()),
            const SizedBox(width: 10),
            _buildRowsDropdown(compact: true),
          ]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildDateField('From Date', _fromDate, true),
        const SizedBox(width: 14),
        _buildDateField('To Date', _toDate, false),
        const SizedBox(width: 14),
        _buildSearchField(),
        const SizedBox(width: 14),
        _buildShowBtn(),
        const Spacer(),
        _buildRowsDropdown(),
        const SizedBox(width: 14),
        _buildReportTypeDropdown(),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        SizedBox(height: 5),
        InkWell(
          onTap: () => _selectDate(context, isFrom),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: Responsive.isMobile(context) ? double.infinity : 125,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade500),
                SizedBox(width: 6),
                Text(DateFormat('M/d/yyyy').format(date), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField({bool fullWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!fullWidth) Text('Product', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        if (!fullWidth) const SizedBox(height: 5),
        Container(
          width: fullWidth ? double.infinity : 200,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: _productController,
            decoration: InputDecoration(
              hintText: 'Search Product',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildShowBtn() {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text('Show Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildRowsDropdown({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Show Rows', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        SizedBox(height: 5),
        Container(
          width: compact ? 75 : 85,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _rowsPerPage,
              isExpanded: true,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade500),
              items: [10, 15, 50, 100].map((v) => DropdownMenuItem<int>(value: v, child: Text('$v'))).toList(),
              onChanged: (val) {
                if (val != null) setState(() { _rowsPerPage = val; _currentPage = 1; });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('View Report', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        SizedBox(height: 5),
        Container(
          width: 190,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedReportType,
              isExpanded: true,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade500),
              items: ['Product Purchase - Totals', 'Detailed']
                  .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedReportType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  FROZEN COLUMN TABLE
  // ══════════════════════════════════════════════

  Widget _buildFrozenColumnTable() {
    const double frozenWidth = 300;
    const double monthColWidth = 100;
    const headerHeight = 42.0;
    const rowHeight = 40.0;

    final headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade800);

    return Row(
      children: [
        // ── Frozen Columns (Code + Description) ──
        SizedBox(
          width: frozenWidth,
          child: Column(
            children: [
              Container(
                height: headerHeight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300), right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(children: [
                  SizedBox(width: 75, child: Text('Code', style: headerStyle)),
                  Expanded(child: Text('Description', style: headerStyle)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _reportData.length,
                  itemBuilder: (context, i) {
                    final item = _reportData[i];
                    return Container(
                      height: rowHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200), right: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(children: [
                        SizedBox(width: 75, child: Text(item['code'] ?? '', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                        Expanded(child: Text(item['description'] ?? '', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable Month Columns ──
        Expanded(
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: monthColWidth * _monthLabels.length,
                child: Column(
                  children: [
                    Container(
                      height: headerHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: _monthLabels.map((label) {
                          return SizedBox(
                            width: monthColWidth,
                            child: Center(child: Text(label, style: headerStyle)),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _reportData.length,
                        itemBuilder: (context, i) {
                          final item = _reportData[i];
                          return Container(
                            height: rowHeight,
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: _monthKeys.map((key) {
                                final val = '${item[key] ?? 0}';
                                final isZero = val == '0';
                                return SizedBox(
                                  width: monthColWidth,
                                  child: Center(
                                    child: Text(
                                      val,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isZero ? Colors.grey.shade400 : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: isZero ? FontWeight.normal : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
      ],
    );
  }

  // ══════════════════════════════════════════════
  //  PAGINATION FOOTER
  // ══════════════════════════════════════════════

  Widget _buildPaginationFooter(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing $_showingStart-$_showingEnd of $_totalRecords', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              _exportBtn(),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _paginationControls()),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('Showing $_showingStart-$_showingEnd of $_totalRecords records', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const Spacer(),
        ..._paginationControls(),
        const Spacer(),
        _exportBtn(),
      ],
    );
  }

  List<Widget> _paginationControls() {
    return [
      _navBtn(Icons.first_page, _currentPage > 1 ? () => setState(() => _currentPage = 1) : null),
      _navBtn(Icons.chevron_left, _currentPage > 1 ? () => setState(() => _currentPage--) : null),
      ..._pageNumbers(),
      _navBtn(Icons.chevron_right, _currentPage < _totalPages ? () => setState(() => _currentPage++) : null),
      _navBtn(Icons.last_page, _currentPage < _totalPages ? () => setState(() => _currentPage = _totalPages) : null),
    ];
  }

  List<Widget> _pageNumbers() {
    List<int> pages = [];
    if (_totalPages <= 5) {
      pages = List.generate(_totalPages, (i) => i + 1);
    } else {
      pages.add(1);
      if (_currentPage > 3) pages.add(-1);
      for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
        if (i > 1 && i < _totalPages) pages.add(i);
      }
      if (_currentPage < _totalPages - 2) pages.add(-1);
      pages.add(_totalPages);
    }

    return pages.map((p) {
      if (p == -1) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text('...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        );
      }
      final active = p == _currentPage;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () => setState(() => _currentPage = p),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: active ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Text('$p', style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.normal, color: active ? Colors.white : Colors.grey.shade700)),
          ),
        ),
      );
    }).toList();
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap) {
    final disabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30, height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
          child: Icon(icon, size: 16, color: disabled ? Colors.grey.shade300 : Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _exportBtn() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_download_outlined, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Text('Export to Excel', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}