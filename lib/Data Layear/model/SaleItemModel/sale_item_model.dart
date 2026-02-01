

class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  // Convert a SaleItemModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  // Create a SaleItemModel from a Firestore document
  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
