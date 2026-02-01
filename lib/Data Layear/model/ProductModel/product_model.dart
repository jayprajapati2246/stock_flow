class ProductModel {
  final String? id;
  final String image;
  final String name;
  final String category;
  final String sku;
  final double price;
  final double purchasePrice;
  final int quantity;
  final String supplierId; // Changed from supplier to supplierId

  ProductModel({
    this.id,
    required this.image,
    required this.name,
    required this.category,
    required this.sku,
    required this.price,
    required this.purchasePrice,
    required this.quantity,
    required this.supplierId, // Changed from supplier to supplierId
  });

  ProductModel copyWith({
    String? id,
    String? image,
    String? name,
    String? category,
    String? sku,
    double? price,
    double? purchasePrice,
    int? quantity,
    String? supplierId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      supplierId: supplierId ?? this.supplierId, // Changed from supplier to supplierId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'category': category,
      'sku': sku,
      'price': price,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'supplierId': supplierId, // Changed from supplier to supplierId
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      image: map['image'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      sku: map['sku'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      supplierId: map['supplierId'] ?? '', // Changed from supplier to supplierId
    );
  }
}
