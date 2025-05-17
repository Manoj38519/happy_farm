import 'package:flutter/material.dart';
import 'package:happy_farm/models/product_model.dart';
import 'package:happy_farm/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeaturedProductDetails extends StatefulWidget {
  final FeaturedProduct product;

  const FeaturedProductDetails({super.key, required this.product});

  @override
  State<FeaturedProductDetails> createState() => _FeaturedProductDetailsState();
}

class _FeaturedProductDetailsState extends State<FeaturedProductDetails> {
  int selectedPriceIndex = 0;
  int quantity = 1;
  int reviewRating = 1;
  final TextEditingController reviewController = TextEditingController();
  bool isWishlist = false;

  Future<void> toggleWishlist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final productId = widget.product.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final body = {
      "productId": productId,
      "userId": userId,
    };

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/my-list/add"),
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      bool added = result['status'] ==
          'added'; // or use your actual backend response field
      setState(() {
        isWishlist = added;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to wishlist")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Future<void> addToCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final price = widget.product.prices[selectedPriceIndex];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final body = {
      "productId": widget.product.id,
      "priceId": price.id,
      "userId": userId,
      "quantity": quantity
    };

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/cart/add"),
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.prices[selectedPriceIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Product Details")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) => Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: const Color.fromARGB(255, 1, 42, 3),
                      size: 28,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      final userId = prefs.getString('userId');

                      if (token == null || userId == null) {
                        // Show dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text(
                                'Please log in to use the wishlist feature.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(), // Close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        toggleWishlist(); // Proceed if logged in
                      }
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('₹${price.actualPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.green)),
                      const SizedBox(width: 8),
                      Text('₹${price.oldPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      Text('${price.discount}% OFF',
                          style: const TextStyle(color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${price.quantity} ${price.type}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(price.countInStock > 0 ? 'IN STOCK' : 'OUT OF STOCK',
                      style: TextStyle(
                          color: price.countInStock > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Quantity and Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              }),
                          Text(quantity.toString(),
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              }),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final token = prefs.getString('token');
                          final userId = prefs.getString('userId');

                          if (token == null || userId == null) {
                            // Show dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Login Required'),
                                content: const Text(
                                    'Please log in to add the product to cart.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(), // Close dialog
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            addToCart(); // Proceed if logged in
                          }
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add To Cart"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ExpansionTile(
                      leading: Icon(Icons.description_outlined,
                          color: Colors.deepPurple),
                      initiallyExpanded: true,
                      title: const Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            product.description?.trim().isNotEmpty == true
                                ? product.description!
                                : "No description available.",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ExpansionTile(
                      leading:
                          Icon(Icons.info_outline_rounded, color: Colors.teal),
                      title: const Text(
                        "Additional Information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${product.category}'),
                              if (product.subCategory != null)
                                Text('Sub-category: ${product.subCategory}'),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text("Add a review", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: "Write a review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < reviewRating
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            reviewRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit review logic
                      },
                      child: const Text("Submit Review"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllProductDetails extends StatefulWidget {
  final AllProduct product;

  const AllProductDetails({super.key, required this.product});

  @override
  State<AllProductDetails> createState() => _AllProductDetailsState();
}

class _AllProductDetailsState extends State<AllProductDetails> {
  int selectedPriceIndex = 0;
  int quantity = 1;
  int reviewRating = 1;
  final TextEditingController reviewController = TextEditingController();
  bool isWishlist = false;
  Future<void> toggleWishlist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final productId = widget.product.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final body = {
      "productId": productId,
      "userId": userId,
    };

    final response = await http.post(
      Uri.parse(
          "https://api.sabbafarm.com/api/my-list/add"), // 🔁 Replace with actual wishlist API URL
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      bool added = result['status'] ==
          'added'; // or use your actual backend response field
      setState(() {
        isWishlist = added;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(added ? "Added to wishlist" : "Removed from wishlist")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Future<void> addToCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString("token");
    final price = widget.product.prices[selectedPriceIndex];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final body = {
      "productId": widget.product.id,
      "priceId": price.id,
      "userId": userId,
      "quantity": quantity,
    };

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/cart/add"),
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.prices[selectedPriceIndex];

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Product Details")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // popup/back arrow
          onPressed: () {
            Navigator.pop(context); // or your custom back logic
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) => Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: const Color.fromARGB(255, 1, 42, 3),
                      size: 28,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      final userId = prefs.getString('userId');

                      if (token == null || userId == null) {
                        // Show dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text(
                                'Please log in to use the wishlist feature.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(), // Close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        toggleWishlist(); // Proceed if logged in
                      }
                    },
                  ),
                ),
              ],
            ),
            // Image carousel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),

                  // Price info
                  Row(
                    children: [
                      Text('₹${price.actualPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.green)),
                      const SizedBox(width: 8),
                      Text('₹${price.oldPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      Text('${price.discount}% OFF',
                          style: const TextStyle(color: Colors.orange)),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text('${price.quantity} ${price.type}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(price.countInStock > 0 ? 'IN STOCK' : 'OUT OF STOCK',
                      style: TextStyle(
                          color: price.countInStock > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 8),
                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              }),
                          Text(quantity.toString(),
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              }),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final token = prefs.getString('token');
                          final userId = prefs.getString('userId');

                          if (token == null || userId == null) {
                            // Show dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Login Required'),
                                content: const Text(
                                    'Please log in to add the product to cart.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(), // Close dialog
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            addToCart(); // Proceed if logged in
                          }
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add To Cart"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),
                  const Divider(),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ExpansionTile(
                      leading: Icon(Icons.description_outlined,
                          color: Colors.deepPurple),
                      initiallyExpanded: true,
                      title: const Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            product.description?.trim().isNotEmpty == true
                                ? product.description!
                                : "No description available.",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ExpansionTile(
                      leading:
                          Icon(Icons.info_outline_rounded, color: Colors.teal),
                      title: const Text(
                        "Additional Information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${product.catName}'),
                              if (product.subCatName != null)
                                Text('Sub-category: ${product.subCatName}'),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Review Section
                  const Text("Add a review", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: "Write a review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < reviewRating
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            reviewRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit review logic
                      },
                      child: const Text("Submit Review"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilteredProductDetails extends StatefulWidget {
  final FilterProducts product;

  const FilteredProductDetails({super.key, required this.product});

  @override
  State<FilteredProductDetails> createState() => _FilteredProductDetailsState();
}

class _FilteredProductDetailsState extends State<FilteredProductDetails> {
  int selectedPriceIndex = 0;
  int quantity = 1;
  int reviewRating = 1;
  final TextEditingController reviewController = TextEditingController();
  bool isWishlist = false;

  Future<void> toggleWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final productId = widget.product.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/my-list/add"),
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
      body: json.encode({
        "productId": productId,
        "userId": userId,
      }),
    );

    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      setState(() {
        isWishlist = result['status'] == 'added';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to wishlist")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final price = widget.product.prices[selectedPriceIndex];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("https://api.sabbafarm.com/api/cart/add"),
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
      body: json.encode({
        "productId": widget.product.id,
        "priceId": price.id,
        "userId": userId,
        "quantity": quantity,
      }),
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product.prices[selectedPriceIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Product Details")),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) => Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      final userId = prefs.getString('userId');

                      if (token == null || userId == null) {
                        // Show dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text(
                                'Please log in to use the wishlist feature.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(), // Close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        toggleWishlist(); // Proceed if logged in
                      }
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('₹${price.actualPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.green)),
                      const SizedBox(width: 8),
                      Text('₹${price.oldPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      Text('${price.discount}% OFF',
                          style: const TextStyle(color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${price.quantity} ${price.type}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(price.countInStock > 0 ? 'IN STOCK' : 'OUT OF STOCK',
                      style: TextStyle(
                          color: price.countInStock > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              }),
                          Text(quantity.toString(),
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              }),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final token = prefs.getString('token');
                          final userId = prefs.getString('userId');

                          if (token == null || userId == null) {
                            // Show dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Login Required'),
                                content: const Text(
                                    'Please log in to add the product to cart.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(), // Close dialog
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            addToCart(); // Proceed if logged in
                          }
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add To Cart"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildExpandableCard(
                    title: "Description",
                    icon: Icons.description,
                    color: Colors.deepPurple,
                    content: product.description.isNotEmpty
                        ? product.description
                        : "No description available.",
                  ),
                  _buildExpandableCard(
                    title: "Additional Information",
                    icon: Icons.info_outline_rounded,
                    color: Colors.teal,
                    content:
                        'Category: ${product.catName}\nSub-category: ${product.subCatName ?? 'N/A'}',
                  ),
                  const Text("Add a review", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: "Write a review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < reviewRating
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            reviewRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        // Review submission logic
                      },
                      child: const Text("Submit Review"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
