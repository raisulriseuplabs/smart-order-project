import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_orders_desktop/core/api/api_response.dart';

/// Mock API Service - Simulates real API with delays and responses
/// This can be replaced with real API calls later
class MockApiService {
  final Random _random = Random();
  static final List<Map<String, dynamic>> _createdOrders = [];

  /// Simulate network delay
  Future<void> _delay() async {
    final ms = 500 + _random.nextInt(1000);
    await Future.delayed(Duration(milliseconds: ms));
  }

  /// Simulate random failures (10% chance)
  void _simulateFailure() {
    if (_random.nextInt(10) == 0) {
      throw Exception('Network error: Connection timeout');
    }
  }

  // ============= AUTH APIs =============

  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    await _delay();
    _simulateFailure();
    if (email == 'john.smith@citymed.com' && password == 'password') {
      return ApiResponse(
        success: true,
        data: {
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': '1', 
            'name': 'Dr. John Smith', 
            'email': email, 
            'status': 'Active',
            'phone': '+27 12 345 6789',
            'branch': 'CITY-PTA (Pretoria)',
            'account': '102238, 102240, 102245',
          },
        },
        message: 'Login successful',
      );
    }
    if (email == 'blocked@citymed.com' && password == 'password') {
      return ApiResponse(
        success: true,
        data: {
          'token': 'mock_token_blocked',
          'user': {
            'id': '2', 
            'name': 'Blocked User', 
            'email': email, 
            'status': 'Blocked',
            'phone': '+27 00 000 0000',
            'branch': 'N/A',
            'account': 'N/A',
          },
        },
        message: 'Login successful',
      );
    }
    return const ApiResponse(success: false, error: 'Invalid email or password');
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String branch, required String account, required String name, required String email, String? phone,
  }) async {
    await _delay();
    _simulateFailure();
    return const ApiResponse(success: true, data: {'message': 'Registration request submitted successfully'}, message: 'Please wait for administrator approval');
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    await _delay();
    _simulateFailure();
    return const ApiResponse(success: true, message: 'Password reset request submitted. An administrator will contact you.');
  }

  Future<ApiResponse<Map<String, dynamic>>> checkSession() async {
    await _delay();
    return const ApiResponse(success: true, data: {'user': {'id': '1', 'name': 'Dr. John Smith', 'email': 'john.smith@citymed.com', 'status': 'Active'}});
  }

  Future<ApiResponse<void>> logout() async {
    await _delay();
    return const ApiResponse(success: true, message: 'Logged out successfully');
  }

  Future<ApiResponse<void>> changePassword({required String oldPassword, required String newPassword}) async {
    await _delay();
    _simulateFailure();
    if (oldPassword == 'password') {
      return const ApiResponse(success: true, message: 'Password changed successfully');
    }
    return const ApiResponse(success: false, error: 'Current password is incorrect');
  }

  // ============= PRODUCTS APIs =============

  Future<ApiResponse<ListResponse<Map<String, dynamic>>>> getProducts({
    int page = 1, int limit = 20, String? search, bool? promotionsOnly, bool? inStockOnly, String? sortBy,
  }) async {
    await _delay();
    _simulateFailure();

    final allProducts = _getMockProducts();
    var filtered = allProducts;

    // Smart search: brand matches first, then alternatives with same generic
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();

      // Direct matches (name, sku, or generic name)
      final directMatches = allProducts.where(
        (p) => p['name'].toString().toLowerCase().contains(query) ||
               p['sku'].toString().toLowerCase().contains(query) ||
               p['genericName'].toString().toLowerCase().contains(query),
      ).toList();

      // Find generic names from direct matches
      final matchedGenerics = directMatches.map((p) => p['genericName'].toString().toLowerCase()).toSet();

      // Alternatives: same generic but not already matched
      final directIds = directMatches.map((p) => p['id']).toSet();
      final alternatives = allProducts.where(
        (p) => matchedGenerics.contains(p['genericName'].toString().toLowerCase()) && !directIds.contains(p['id']),
      ).toList();

      filtered = [...directMatches, ...alternatives];
    }

    if (promotionsOnly == true) {
      filtered = filtered.where((p) => p['hasPromo'] == true).toList();
    }
    if (inStockOnly == true) {
      filtered = filtered.where((p) => p['inStock'] == true).toList();
    }

    final start = (page - 1) * limit;
    final paginated = filtered.skip(start).take(limit).toList();

    return ApiResponse(success: true, data: ListResponse(items: paginated, total: filtered.length, page: page, limit: limit));
  }

  Future<ApiResponse<Map<String, dynamic>>> getProductDetails(String productId) async {
    await _delay();
    _simulateFailure();
    final product = _getMockProducts().firstWhere((p) => p['id'] == productId, orElse: () => {});
    if (product.isEmpty) return const ApiResponse(success: false, error: 'Product not found');
    return ApiResponse(success: true, data: product);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProductPurchaseHistory(String productId) async {
    await _delay();
    _simulateFailure();
    final history = List.generate(6, (index) {
      final date = DateTime.now().subtract(Duration(days: 30 * (5 - index)));
      return {'month': _getMonthName(date.month), 'year': date.year.toString().substring(2), 'quantity': _random.nextInt(10)};
    });
    return ApiResponse(success: true, data: history);
  }

  // ============= ORDERS APIs =============

  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String customerCategory, required String customerRoute, required List<Map<String, dynamic>> items,
    required String userStatus,
  }) async {
    await _delay();
    if (userStatus == 'Blocked') {
      return const ApiResponse(success: false, error: 'Your account has been blocked contact to admin or support center');
    }
    _simulateFailure();
    final now = DateTime.now();
    final orderId = 'ORD-${now.millisecondsSinceEpoch}';
    final orderNumber = '102238_${now.millisecondsSinceEpoch}';
    double orderTotalIncl = 0;
    double saving = 0;
    for (final item in items) {
      orderTotalIncl += (item['totalIncl'] ?? 0) as double;
      saving += (item['saving'] ?? 0) as double;
    }
    _createdOrders.add({
      'id': orderId, 'company': 'CITY-PTA', 'account': '102238', 'orderNumber': orderNumber,
      'orderDate': '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
      'invoice': '', 'invoiceDate': '', 'orderTotalIncl': orderTotalIncl, 'invTotalIncl': 0.0,
      'saving': saving, 'status': 'Pending', 'createdAt': now.toIso8601String(),
    });
    return ApiResponse(success: true, data: {'orderId': orderId, 'orderNumber': orderNumber, 'status': 'Pending'}, message: 'Order created successfully');
  }

  Future<ApiResponse<ListResponse<Map<String, dynamic>>>> getOrders({int page = 1, int limit = 20}) async {
    await _delay();
    _simulateFailure();
    final orders = [..._createdOrders.reversed, ..._getMockOrders()];
    final start = (page - 1) * limit;
    final paginated = orders.skip(start).take(limit).toList();
    return ApiResponse(success: true, data: ListResponse(items: paginated, total: orders.length, page: page, limit: limit));
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetails(String orderId) async {
    await _delay();
    _simulateFailure();
    return ApiResponse(success: true, data: {
      'id': orderId, 'orderNumber': '102238_121125134914', 'company': 'CITY-PTA', 'account': '102238',
      'accountName': 'MARSHALLS TRAD HEALTHCARE', 'orderDate': '11/12/2025 1:49:14 PM',
      'invoiceDate': '11/12/2025', 'invoice': 'INV-9921', 'status': 'Cancelled',
      'items': [
        {'description': '8-TREK DRAWING OINT & BOIL PLASTER', 'ordQty': 10, 'ordFree': 0, 'ordPrice': 5.00, 'invQty': 10, 'invFree': 0, 'invPrice': 5.00, 'saving': 5.00, 'invoice': 'INV-8821', 'mainAcc': 'Yes', 'result': 'Invoiced'},
        {'description': 'ADULT TOOTHBRUSH SOFT', 'ordQty': 4, 'ordFree': 1, 'ordPrice': 6.50, 'invQty': 4, 'invFree': 1, 'invPrice': 6.50, 'saving': 1.50, 'invoice': 'INV-8822', 'mainAcc': 'Yes', 'result': 'Invoiced'},
        {'description': 'SURGICAL FACE MASK 3-PLY', 'ordQty': 2, 'ordFree': 0, 'ordPrice': 3.85, 'invQty': 0, 'invFree': 0, 'invPrice': 0.00, 'saving': 0.00, 'invoice': '-', 'mainAcc': 'Yes', 'result': 'Cancelled'},
      ],
      'totalInclusive': 1240.50, 'totalVat': 59.60, 'totalSaving': 104.20,
    });
  }

  // ============= REPORTS APIs =============

  Future<ApiResponse<Map<String, dynamic>>> getProductReport({
    required DateTime fromDate, required DateTime toDate, String? productFilter,
  }) async {
    await _delay();
    _simulateFailure();
    return ApiResponse(success: true, data: {'reportData': _getMockReportData(), 'generatedAt': DateTime.now().toIso8601String()});
  }

  Future<ApiResponse<Map<String, dynamic>>> getAgeAnalysis() async {
    await _delay();
    _simulateFailure();
    final allOrders = [..._createdOrders, ..._getMockOrders()];
    double current = 0, d30 = 0, d60 = 0, d90 = 0, d120 = 0, d150 = 0, d180 = 0;
    final now = DateTime.now();
    for (var order in allOrders) {
      DateTime? orderDate;
      if (order['createdAt'] != null) {
        orderDate = DateTime.parse(order['createdAt']);
      } else {
        final parts = (order['orderDate'] as String).split('/');
        if (parts.length == 3) orderDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      if (orderDate != null) {
        final diff = now.difference(orderDate).inDays;
        final amount = (order['orderTotalIncl'] ?? 0.0) as double;
        if (diff <= 0) current += amount;
        else if (diff <= 30) d30 += amount;
        else if (diff <= 60) d60 += amount;
        else if (diff <= 90) d90 += amount;
        else if (diff <= 120) d120 += amount;
        else if (diff <= 150) d150 += amount;
        else d180 += amount;
      }
    }
    return ApiResponse(success: true, data: {
      'accountCode': '102238', 'accountName': 'MARSHALLS TRAD HEALTHCARE',
      'buckets': {'Current': current, '30 Days': d30, '60 Days': d60, '90 Days': d90, '120 Days': d120, '150 Days': d150, '180 Days': d180, 'Total': current + d30 + d60 + d90 + d120 + d150 + d180},
    });
  }

  // ============= ACCOUNT APIs =============

  Future<ApiResponse<Map<String, dynamic>>> checkForUpdates() async {
    await _delay();
    return const ApiResponse(success: true, data: {'hasUpdate': false, 'currentVersion': '1.0.0', 'latestVersion': '1.0.0'});
  }

  // ============= HELPER METHODS =============

  String _stockStatus(int qty) {
    if (qty == 0) return 'Out of Stock';
    if (qty < 10) return 'Low Stock';
    return 'Available';
  }

  // Stock Colors Helper
  static Color getStockColor(String status) {
    if (status == 'Low Stock') return Colors.orange;
    if (status == 'Out of Stock') return Colors.red;
    return Colors.green;
  }

  List<Map<String, dynamic>> _getMockProducts() {
    final products = <Map<String, dynamic>>[
      // User's specific product from screenshot
      {
        'id': 'p00',
        'name': 'Surgical Latex Gloves - Medium (Box of 100)',
        'genericId': 'g00',
        'genericName': 'Latex Gloves',
        'dose': 'Medium',
        'price': 12.50,
        'sku': 'GLV-MED-100',
        'supplier': 'MedSafe Corp',
        'hasPromo': false,
        'stockQuantity': 5
      },
      // Paracetamol family
      {'id': 'p01', 'name': 'Calpol 500mg Tablets', 'genericId': 'g01', 'genericName': 'Paracetamol', 'dose': '500 mg', 'price': 2.00, 'sku': 'CAL-500', 'supplier': 'GSK', 'hasPromo': false, 'stockQuantity': 8},
      {'id': 'p02', 'name': 'Tylenol 500mg Tablets', 'genericId': 'g01', 'genericName': 'Paracetamol', 'dose': '500 mg', 'price': 4.80, 'sku': 'TYL-500', 'supplier': 'Johnson&Johnson', 'hasPromo': true, 'stockQuantity': 20},
      {'id': 'p03', 'name': 'Panadol 650mg Tablets', 'genericId': 'g01', 'genericName': 'Paracetamol', 'dose': '650 mg', 'price': 1.90, 'sku': 'PAN-650', 'supplier': 'GSK', 'hasPromo': false, 'stockQuantity': 6},
      {'id': 'p04', 'name': 'Crocin 500mg Tablets', 'genericId': 'g01', 'genericName': 'Paracetamol', 'dose': '500 mg', 'price': 2.30, 'sku': 'CRO-500', 'supplier': 'Teva', 'hasPromo': false, 'stockQuantity': 10},
      {'id': 'p05', 'name': 'Dolo 650mg Tablets', 'genericId': 'g01', 'genericName': 'Paracetamol', 'dose': '650 mg', 'price': 3.60, 'sku': 'DOL-650', 'supplier': 'Micro Labs', 'hasPromo': true, 'stockQuantity': 15},
      // Amoxicillin family
      {'id': 'p06', 'name': 'Amoxil 500mg Capsules', 'genericId': 'g02', 'genericName': 'Amoxicillin', 'dose': '500 mg', 'price': 4.20, 'sku': 'AMX-500', 'supplier': 'GSK', 'hasPromo': false, 'stockQuantity': 6},
      {'id': 'p07', 'name': 'Mox 250mg Capsules', 'genericId': 'g02', 'genericName': 'Amoxicillin', 'dose': '250 mg', 'price': 5.20, 'sku': 'MOX-250', 'supplier': 'Ranbaxy', 'hasPromo': false, 'stockQuantity': 15},
      {'id': 'p08', 'name': 'Novamox 500mg Capsules', 'genericId': 'g02', 'genericName': 'Amoxicillin', 'dose': '500 mg', 'price': 6.50, 'sku': 'NOV-500', 'supplier': 'Cipla', 'hasPromo': true, 'stockQuantity': 0},
      {'id': 'p09', 'name': 'Almox 250mg Capsules', 'genericId': 'g02', 'genericName': 'Amoxicillin', 'dose': '250 mg', 'price': 3.90, 'sku': 'ALM-250', 'supplier': 'Alkem', 'hasPromo': false, 'stockQuantity': 8},
      {'id': 'p10', 'name': 'Trimox 500mg Capsules', 'genericId': 'g02', 'genericName': 'Amoxicillin', 'dose': '500 mg', 'price': 9.40, 'sku': 'TRM-500', 'supplier': 'Sandoz', 'hasPromo': false, 'stockQuantity': 20},
      // Ibuprofen family
      {'id': 'p11', 'name': 'Advil 400mg Tablets', 'genericId': 'g03', 'genericName': 'Ibuprofen', 'dose': '400 mg', 'price': 2.80, 'sku': 'ADV-400', 'supplier': 'Pfizer', 'hasPromo': true, 'stockQuantity': 8},
      {'id': 'p12', 'name': 'Brufen 400mg Tablets', 'genericId': 'g03', 'genericName': 'Ibuprofen', 'dose': '400 mg', 'price': 4.50, 'sku': 'BRU-400', 'supplier': 'Abbott', 'hasPromo': false, 'stockQuantity': 15},
      {'id': 'p13', 'name': 'Nurofen 200mg Tablets', 'genericId': 'g03', 'genericName': 'Ibuprofen', 'dose': '200 mg', 'price': 2.10, 'sku': 'NUR-200', 'supplier': 'Reckitt', 'hasPromo': false, 'stockQuantity': 6},
      {'id': 'p14', 'name': 'Ibugesic 400mg Tablets', 'genericId': 'g03', 'genericName': 'Ibuprofen', 'dose': '400 mg', 'price': 2.90, 'sku': 'IBG-400', 'supplier': 'Cipla', 'hasPromo': false, 'stockQuantity': 10},
      {'id': 'p15', 'name': 'Motrin 600mg Tablets', 'genericId': 'g03', 'genericName': 'Ibuprofen', 'dose': '600 mg', 'price': 6.20, 'sku': 'MOT-600', 'supplier': 'Johnson&Johnson', 'hasPromo': true, 'stockQuantity': 15},
      // Azithromycin family
      {'id': 'p16', 'name': 'Zithromax 500mg Tablets', 'genericId': 'g04', 'genericName': 'Azithromycin', 'dose': '500 mg', 'price': 8.50, 'sku': 'ZIT-500', 'supplier': 'Pfizer', 'hasPromo': false, 'stockQuantity': 3},
      {'id': 'p17', 'name': 'Azee 500mg Tablets', 'genericId': 'g04', 'genericName': 'Azithromycin', 'dose': '500 mg', 'price': 11.20, 'sku': 'AZE-500', 'supplier': 'Cipla', 'hasPromo': false, 'stockQuantity': 5},
      {'id': 'p18', 'name': 'Azax 250mg Tablets', 'genericId': 'g04', 'genericName': 'Azithromycin', 'dose': '250 mg', 'price': 7.90, 'sku': 'AZX-250', 'supplier': 'Ranbaxy', 'hasPromo': true, 'stockQuantity': 0},
      {'id': 'p19', 'name': 'Zady 500mg Tablets', 'genericId': 'g04', 'genericName': 'Azithromycin', 'dose': '500 mg', 'price': 8.10, 'sku': 'ZAD-500', 'supplier': 'Alkem', 'hasPromo': false, 'stockQuantity': 3},
      {'id': 'p20', 'name': 'Aziwin 250mg Tablets', 'genericId': 'g04', 'genericName': 'Azithromycin', 'dose': '250 mg', 'price': 7.50, 'sku': 'AZW-250', 'supplier': 'Alembic', 'hasPromo': false, 'stockQuantity': 6},
      // Metformin family
      {'id': 'p21', 'name': 'Glucophage 500mg Tablets', 'genericId': 'g05', 'genericName': 'Metformin', 'dose': '500 mg', 'price': 5.60, 'sku': 'GLU-500', 'supplier': 'Merck', 'hasPromo': false, 'stockQuantity': 20},
      {'id': 'p22', 'name': 'Glycomet 500mg Tablets', 'genericId': 'g05', 'genericName': 'Metformin', 'dose': '500 mg', 'price': 2.80, 'sku': 'GLY-500', 'supplier': 'USV', 'hasPromo': true, 'stockQuantity': 9},
      {'id': 'p23', 'name': 'Obimet 850mg Tablets', 'genericId': 'g05', 'genericName': 'Metformin', 'dose': '850 mg', 'price': 6.90, 'sku': 'OBI-850', 'supplier': 'Cipla', 'hasPromo': false, 'stockQuantity': 15},
      {'id': 'p24', 'name': 'Formet 500mg Tablets', 'genericId': 'g05', 'genericName': 'Metformin', 'dose': '500 mg', 'price': 8.20, 'sku': 'FOR-500', 'supplier': 'Sun', 'hasPromo': false, 'stockQuantity': 30},
      {'id': 'p25', 'name': 'Metlong 1000mg Tablets', 'genericId': 'g05', 'genericName': 'Metformin', 'dose': '1000 mg', 'price': 3.70, 'sku': 'MET-1000', 'supplier': 'Blue Cross', 'hasPromo': false, 'stockQuantity': 7},
      // Cetirizine family
      {'id': 'p26', 'name': 'Zyrtec 10mg Tablets', 'genericId': 'g06', 'genericName': 'Cetirizine', 'dose': '10 mg', 'price': 2.50, 'sku': 'ZYR-10', 'supplier': 'UCB', 'hasPromo': false, 'stockQuantity': 8},
      {'id': 'p27', 'name': 'Cetzine 10mg Tablets', 'genericId': 'g06', 'genericName': 'Cetirizine', 'dose': '10 mg', 'price': 4.60, 'sku': 'CTZ-10', 'supplier': 'Unichem', 'hasPromo': true, 'stockQuantity': 15},
      {'id': 'p28', 'name': 'Alerid 10mg Tablets', 'genericId': 'g06', 'genericName': 'Cetirizine', 'dose': '10 mg', 'price': 1.80, 'sku': 'ALR-10', 'supplier': 'Cipla', 'hasPromo': false, 'stockQuantity': 0},
      {'id': 'p29', 'name': 'Okacet 5mg Tablets', 'genericId': 'g06', 'genericName': 'Cetirizine', 'dose': '5 mg', 'price': 2.70, 'sku': 'OKA-5', 'supplier': 'Lupin', 'hasPromo': false, 'stockQuantity': 10},
      {'id': 'p30', 'name': 'Cetcip 10mg Tablets', 'genericId': 'g06', 'genericName': 'Cetirizine', 'dose': '10 mg', 'price': 5.40, 'sku': 'CTC-10', 'supplier': 'Cipla', 'hasPromo': false, 'stockQuantity': 20},
    ];

    // Compute dynamic fields
    for (final p in products) {
      final qty = p['stockQuantity'] as int;
      p['inStock'] = qty > 0;
      p['stockStatus'] = _stockStatus(qty);
    }

    return products;
  }

  List<Map<String, dynamic>> _getMockOrders() {
    return [
      {'id': 'ord_1', 'company': 'CITY-PTA', 'account': '102238', 'orderNumber': '102238_121125134914', 'orderDate': '11/12/2025', 'invoice': '-', 'invoiceDate': '11/12/2025', 'orderTotalIncl': 1240.50, 'invTotalIncl': 430.50, 'saving': 0.00, 'status': 'Cancelled', 'createdAt': '2025-12-11T13:49:14Z'},
      {'id': 'ord_2', 'company': 'CITY-PTA', 'account': '102238', 'orderNumber': '102238_30d', 'orderDate': '10/01/2026', 'invoice': 'INV-9930', 'invoiceDate': '10/01/2026', 'orderTotalIncl': 450.00, 'invTotalIncl': 450.00, 'saving': 20.00, 'status': 'Invoiced', 'createdAt': '2026-01-10T10:00:00Z'},
      {'id': 'ord_3', 'company': 'CITY-PTA', 'account': '102238', 'orderNumber': '102238_60d', 'orderDate': '10/12/2025', 'invoice': 'INV-9960', 'invoiceDate': '10/12/2025', 'orderTotalIncl': 780.00, 'invTotalIncl': 780.00, 'saving': 50.00, 'status': 'Invoiced', 'createdAt': '2025-12-10T10:00:00Z'},
      {'id': 'ord_4', 'company': 'CITY-PTA', 'account': '102238', 'orderNumber': '102238_90d', 'orderDate': '10/11/2025', 'invoice': 'INV-9990', 'invoiceDate': '10/11/2025', 'orderTotalIncl': 1120.00, 'invTotalIncl': 1120.00, 'saving': 100.00, 'status': 'Invoiced', 'createdAt': '2025-11-10T10:00:00Z'},
    ];
  }

  List<Map<String, dynamic>> _getMockReportData() {
    return [
      {'code': 'TR048', 'description': '8-TREK DRAWING OINT 25g', 'mar2025': 2, 'apr2025': 0, 'may2025': 1, 'jun2025': 0, 'jul2025': 3, 'aug2025': 0, 'sep2025': 0, 'oct2025': 1, 'nov2025': 0, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': '14406/30', 'description': 'A VOGEL COUGH FORMULA 30ml', 'mar2025': 0, 'apr2025': 1, 'may2025': 0, 'jun2025': 2, 'jul2025': 0, 'aug2025': 0, 'sep2025': 0, 'oct2025': 0, 'nov2025': 1, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': 'MOH623', 'description': 'A VOGEL ECHINAFORCE 100ml', 'mar2025': 0, 'apr2025': 0, 'may2025': 0, 'jun2025': 0, 'jul2025': 1, 'aug2025': 2, 'sep2025': 0, 'oct2025': 0, 'nov2025': 0, 'dec2025': 3, 'jan2026': 0, 'feb2026': 0},
      {'code': 'FAR002', 'description': 'A VOGEL ECHINAFORCE 50ML', 'mar2025': 1, 'apr2025': 0, 'may2025': 0, 'jun2025': 0, 'jul2025': 0, 'aug2025': 4, 'sep2025': 0, 'oct2025': 0, 'nov2025': 2, 'dec2025': 3, 'jan2026': 0, 'feb2026': 0},
      {'code': 'FAR020', 'description': 'A VOGEL ECHINAFORCE JNR. 120lbs', 'mar2025': 0, 'apr2025': 2, 'may2025': 0, 'jun2025': 0, 'jul2025': 0, 'aug2025': 0, 'sep2025': 0, 'oct2025': 3, 'nov2025': 0, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': '14413/30', 'description': 'A VOGEL INDIGESTION FORMULA 30ml', 'mar2025': 0, 'apr2025': 0, 'may2025': 3, 'jun2025': 0, 'jul2025': 0, 'aug2025': 1, 'sep2025': 0, 'oct2025': 0, 'nov2025': 1, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': 'DE363', 'description': 'A VOGEL M/ CONC WHEY 200ml', 'mar2025': 0, 'apr2025': 0, 'may2025': 0, 'jun2025': 1, 'jul2025': 0, 'aug2025': 0, 'sep2025': 0, 'oct2025': 0, 'nov2025': 0, 'dec2025': 2, 'jan2026': 0, 'feb2026': 2},
      {'code': 'RAG01', 'description': 'ACCORD ANASTRAZOLE 1MG', 'mar2025': 0, 'apr2025': 0, 'may2025': 0, 'jun2025': 0, 'jul2025': 2, 'aug2025': 0, 'sep2025': 5, 'oct2025': 0, 'nov2025': 0, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': 'SUR2475', 'description': 'ADULT *NAPPES LARGE 10s CERTAINTY', 'mar2025': 10, 'apr2025': 0, 'may2025': 20, 'jun2025': 0, 'jul2025': 0, 'aug2025': 15, 'sep2025': 0, 'oct2025': 0, 'nov2025': 40, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
      {'code': 'RAH29', 'description': 'ADULT PULL UPS 10s L CERTAINTY', 'mar2025': 0, 'apr2025': 5, 'may2025': 0, 'jun2025': 10, 'jul2025': 0, 'aug2025': 0, 'sep2025': 0, 'oct2025': 10, 'nov2025': 30, 'dec2025': 0, 'jan2026': 0, 'feb2026': 0},
    ];
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
