class InvoiceModel {
  final int id;
  final String invoiceNo;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final String? custId;
  final String period;
  final num total;
  final String status;
  final String dueDate;
  final String? paidAt;
  final String? paymentMethod;

  InvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.custId,
    required this.period,
    required this.total,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.paymentMethod,
  });

  bool get isPaid => status == 'paid';
  String get invoiceNumber => invoiceNo;
  num get amount => total;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      invoiceNo: json['invoice_no'] ?? 'INV-${json['id']}',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name'] ?? json['name'] ?? 'Pelanggan',
      customerPhone: json['customer_phone'] ?? json['phone'],
      custId: json['cust_id'],
      period: json['period'] ?? json['billing_period'] ?? '-',
      total: json['total'] is num ? json['total'] : num.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'unpaid',
      dueDate: json['due_date'] ?? '',
      paidAt: json['paid_at'] ?? json['payment_date'],
      paymentMethod: json['payment_method'],
    );
  }
}
