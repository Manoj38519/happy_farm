import 'package:flutter/material.dart';
import 'package:happy_farm/models/product_model.dart';
import 'package:happy_farm/screens/productdetails_screen.dart';
import 'package:happy_farm/widgets/wishListShimmer.dart';
import 'package:happy_farm/service/Whislist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> wishlist = [];
  late Future<void> wishlistFuture;


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
    final data = await WishlistService.fetchWishlist();
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'My Wishlist',
        ),
        backgroundColor: Colors.green.shade700,
        automaticallyImplyLeading: false,
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
            return const Center(child: WishlistShimmer());
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
                              WishlistService.removeFromWishlist(index as String);
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
                            child: GestureDetector(
                              onTap: () {
                                final productInstance =
                                    AllProduct.fromJson(product);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (builder) => ProductDetails(
                                      product: productInstance,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                        color: Colors.grey.shade300)),
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.green[50],
                                              image: image != null
                                                  ? DecorationImage(
                                                      image:
                                                          NetworkImage(image),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        title,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () =>
                                                          WishlistService.removeFromWishlist(
                                                              index as String),
                                                      child: Icon(
                                                          Icons.favorite,
                                                          color:
                                                              Colors.red[400]),
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
                                                                ? Icons
                                                                    .star_half
                                                                : Icons
                                                                    .star_border,
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
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
