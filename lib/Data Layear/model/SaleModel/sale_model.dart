class SaleModel {
  String? id;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final String paymentMethod;

  SaleModel({
    this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items,
      'subtotal': subtotal,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
    );
  }
}