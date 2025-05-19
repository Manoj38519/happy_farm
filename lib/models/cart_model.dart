class CartItem {
  final String id;
  final Product product;
  final String priceId;
  final String userId;
  final int quantity;
  final int subTotal;

  CartItem({
    required this.id,
    required this.product,
    required this.priceId,
    required this.userId,
    required this.quantity,
    required this.subTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['productId']),
      priceId: json['priceId'],
      userId: json['userId'],
      quantity: json['quantity'],
      subTotal: json['subTotal'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final List<Price> prices;
  final int rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.prices,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images']),
      prices: (json['prices'] as List)
          .map((price) => Price.fromJson(price))
          .toList(),
      rating: json['rating'],
    );
  }
}

class Price {
  final int quantity;
  final int actualPrice;
  final int oldPrice;
  final double discount;
  final String type;
  final int countInStock;

  Price({
    required this.quantity,
    required this.actualPrice,
    required this.oldPrice,
    required this.discount,
    required this.type,
    required this.countInStock,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      quantity: json['quantity'],
      actualPrice: json['actualPrice'],
      oldPrice: json['oldPrice'],
      discount: json['discount'].toDouble(),
      type: json['type'],
      countInStock: json['countInStock'],
    );
  }
}
