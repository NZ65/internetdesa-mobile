class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final int total;
  final String status; // unpaid, paid, cancelled
  final String? dueDate;
  final String? paidDate;
  final String? paymentMethod;
  final String? proofImage;
  final String? packageName;
  final String? custId;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.total,
    required this.status,
    this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.proofImage,
    this.packageName,
    this.custId,
  });

  bool get isPaid => status == 'paid';
  bool get isUnpaid => status == 'unpaid';

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? 'INV-#${json['id']}',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name']?.toString() ?? 'Pelanggan',
      customerPhone: json['customer_phone']?.toString(),
      customerAddress: json['customer_address']?.toString(),
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'unpaid',
      dueDate: json['due_date']?.toString(),
      paidDate: json['paid_date']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      proofImage: json['proof_image']?.toString(),
      packageName: json['package_name']?.toString(),
      custId: json['cust_id']?.toString() ?? json['customer_id']?.toString(),
    );
  }
}
