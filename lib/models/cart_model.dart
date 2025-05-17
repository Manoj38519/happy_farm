class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final int subTotal;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['productId']),
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
      id: json['id'],
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
  final int discount;
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
      discount: json['discount'],
      type: json['type'],
      countInStock: json['countInStock'],
    );
  }
}
