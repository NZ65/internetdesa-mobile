import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _summary = {};
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentType = 'all';
  String _currentCategory = 'all';

  List<ExpenseModel> get transactions => _transactions;
  List<ExpenseModel> get expenses => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get summary => _summary;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  num get saldoTersisa => _summary['saldo_tersisa'] ?? 0;
  num get sisaModal => _summary['sisa_modal'] ?? 0;
  num get sisaKasOps => _summary['sisa_kas_ops'] ?? 0;
  num get monthExpense => _summary['month_expense'] ?? 0;

  Future<void> fetchExpenses({
    String? type,
    String? category,
    int page = 1,
    bool silent = false,
  }) async {
    if (type != null) _currentType = type;
    if (category != null) _currentCategory = category;
    _currentPage = page;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final res = await ApiClient().get(AppConfig.epExpenses, queryParameters: {
        'type': _currentType,
        'category': _currentCategory,
        'page': _currentPage,
        'limit': 25,
      });

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final list = data['transactions'] as List? ?? [];
        _transactions = list.map((t) => ExpenseModel.fromJson(t)).toList();
        _summary = Map<String, dynamic>.from(data['summary'] ?? {});
        if (data['pagination'] != null) {
          _totalPages = data['pagination']['totalPages'] ?? 1;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required String itemName,
    required num amount,
    String type = 'out',
    String category = 'operasional',
    String paymentSource = 'Kas Operasional',
    String paymentMethod = 'cash',
    String? recipient,
    String? notes,
    File? receiptImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'item_name': itemName.trim(),
        'amount': amount.toString(),
        'type': type,
        'category': category,
        'payment_source': paymentSource,
        'payment_method': paymentMethod,
        'recipient': recipient?.trim() ?? '',
        'notes': notes?.trim() ?? '',
      };

      final files = {
        'receipt_image': receiptImage,
      };

      final res = await ApiClient().postMultipart(AppConfig.epExpenses, fields, files);
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        await fetchExpenses(page: 1, silent: true);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> createExpense({
    String? title,
    String? itemName,
    required num amount,
    String type = 'out',
    String category = 'operasional',
    String paymentSource = 'Kas Operasional',
    String paymentMethod = 'cash',
    String? recipient,
    String? notes,
    File? receiptImage,
    File? receiptFile,
  }) async {
    return addExpense(
      itemName: itemName ?? title ?? '',
      amount: amount,
      type: type,
      category: category,
      paymentSource: paymentSource,
      paymentMethod: paymentMethod,
      recipient: recipient,
      notes: notes,
      receiptImage: receiptImage ?? receiptFile,
    );
  }
}
