class StockTransactionModel {
  final int? id;
  final int productId;
  final String type; // IN or OUT
  final int quantity;
  final String date;

  StockTransactionModel({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  factory StockTransactionModel.fromMap(Map<String, dynamic> map) {
    return StockTransactionModel(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
    );
  }
}
