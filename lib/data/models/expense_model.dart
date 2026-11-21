class ExpenseModel {
  final int id;
  final String type; // 'out' (pengeluaran) or 'in' (pemasukan)
  final String category; // 'capex', 'opex', 'operasional', 'fee_tim', 'lainnya'
  final String itemName;
  final String? brand;
  final int qty;
  final num amount;
  final String transactionDate;
  final String? recipient;
  final String paymentSource;
  final String paymentMethod;
  final String status;
  final String? notes;
  final String? proofImage;
  final String? approvedBy;

  ExpenseModel({
    required this.id,
    required this.type,
    required this.category,
    required this.itemName,
    this.brand,
    this.qty = 1,
    required this.amount,
    required this.transactionDate,
    this.recipient,
    this.paymentSource = 'Kas Operasional',
    this.paymentMethod = 'cash',
    this.status = 'paid',
    this.notes,
    this.proofImage,
    this.approvedBy,
  });

  bool get isExpense => type == 'out';
  String get createdAt => transactionDate;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? 'out',
      category: json['category'] ?? 'operasional',
      itemName: json['item_name'] ?? '',
      brand: json['brand'],
      qty: json['qty'] is int ? json['qty'] : int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      amount: json['amount'] is num ? json['amount'] : num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      transactionDate: json['transaction_date'] ?? '',
      recipient: json['recipient'],
      paymentSource: json['payment_source'] ?? 'Kas Operasional',
      paymentMethod: json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'paid',
      notes: json['notes'],
      proofImage: json['proof_image'],
      approvedBy: json['approved_by'],
    );
  }
}
