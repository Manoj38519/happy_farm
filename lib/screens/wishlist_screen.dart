import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WishlistScreen extends StatefulWidget {
  final VoidCallback onBack;
  const WishlistScreen({super.key, required this.onBack});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> wishlist = [];
  late Future<void> wishlistFuture;

  void removeFrommylist(int index) async {
    final item = wishlist[index];
    final wishlistItemId =
        item['_id']; // assuming _id is the unique wishlist item ID
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final url = Uri.parse('https://api.sabbafarm.com/api/my-list/$wishlistItemId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        wishlist.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from wishlist')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item')),
      );
    }
  }

  Future<void> addToCart({
    required String productId,
    required String priceId,
    required int quantity,
    required BuildContext context,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final body = {
      "productId": productId,
      "priceId": priceId,
      "userId": userId,
      "quantity": quantity
    };

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/cart/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token ?? "", // fallback if token is null
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to cart!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add: ${response.body}")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String? token = prefs.getString('token');
    final url = Uri.parse('https://api.sabbafarm.com/api/my-list?userId=$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    final result = json.decode(response.body);

    if (response.statusCode == 200) {
      if (result['success'] == true && result['data'] != null) {
        return List<Map<String, dynamic>>.from(result['data']);
      } else {
        throw Exception(result['message'] ?? 'No data found');
      }
    } else {
      throw Exception(result['message'] ?? 'Failed to load wishlist');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    wishlistFuture = loadWishlist();
  }

  Future<void> loadWishlist() async {
    final data = await fetchWishlist();
    setState(() {
      wishlist = data;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Center(child: Text("My Wishlist")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${wishlist.length} items',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return wishlist.isEmpty
                ? const Center(child: Text('Your wishlist is empty'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: wishlist.length,
                    itemBuilder: (context, index) {
                      final item = wishlist[index];
                      final product = item['productId'];
                      final productId = product['_id']; // ✅ productId as string
                      final title = product['name'];
                      final rating = product['rating'];

                      // Extract image
                      final image = (product['images'] != null &&
                              product['images'].isNotEmpty)
                          ? product['images'][0]
                          : null;

                      // Extract price details
                      final prices = product['prices'];
                      final priceObj = (prices != null && prices.isNotEmpty)
                          ? prices[0]
                          : null;

                      final priceValue =
                          priceObj != null ? priceObj['actualPrice'] : null;
                      final priceId = priceObj != null ? priceObj['_id'] : null;
                      final quantity =
                          priceObj != null ? priceObj['quantity'] : null;

                      final animation = Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          (1 / wishlist.length) * index,
                          1.0,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ));
                      _controller.forward();

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.5, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              final removedItem = wishlist[index];
                              removeFrommylist(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$title removed from wishlist'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      setState(() {
                                        wishlist.insert(index, removedItem);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.green[50],
                                        image: image != null
                                            ? DecorationImage(
                                                image: NetworkImage(image),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () =>
                                                    removeFrommylist(index),
                                                child: Icon(Icons.favorite,
                                                    color: Colors.red[400]),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '\$$priceValue',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[800],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              ...List.generate(
                                                5,
                                                (i) => Icon(
                                                  i < rating.floor()
                                                      ? Icons.star
                                                      : i < rating
                                                          ? Icons.star_half
                                                          : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$rating',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.green[800],
                                                    side: BorderSide(
                                                        color:
                                                            Colors.green[800]!),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                      'View Details'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (priceId != null &&
                                                        quantity != null) {
                                                      addToCart(
                                                        productId: productId,
                                                        priceId: priceId,
                                                        quantity:
                                                            1, // or use `quantity` from backend if that's the desired initial quantity
                                                        context: context,
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Price details not available')),
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green[800],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child:
                                                      const Text('Add to Cart'),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
          }
        },
      ),
      floatingActionButton: wishlist.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items added to cart'),
                  ),
                );
              },
              backgroundColor: Colors.green[800],
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add All to Cart'),
            )
          : null,
    );
  }
}
