import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happy_farm/main.dart';
import 'package:happy_farm/screens/Order_details.dart';
import 'package:happy_farm/utils/app_theme.dart';
import 'package:happy_farm/widgets/order_shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, });
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  List orders = [];
  bool isLoading = true;
  late TabController _tabController;

  final List<String> statusTabs = ['All', 'pending', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusTabs.length, vsync: this);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print("User ID not found in SharedPreferences");
        setState(() => isLoading = false);
        return;
      }

      final response =
          await http.get(Uri.parse("https://api.sabbafarm.com/api/orders/"));
      if (response.statusCode == 200) {
        final allOrders = json.decode(response.body);
        final userOrders =
            allOrders.where((order) => order['userid'] == userId).toList();

        print(userOrders);

        setState(() {
          orders = userOrders;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: OrderShimmer())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.green[800],
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green[800],
                    tabs: statusTabs
                        .map((status) => Tab(text: status.capitalize()))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: statusTabs.map((status) {
                      final filteredOrders = status == 'All'
                          ? orders
                          : orders
                              .where((o) => o['orderStatus'] == status)
                              .toList();

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Text(
                            'No ${status.toLowerCase()} products',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(
                                      orderId: order['id'].toString()),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
          );
        },
        label: Text('Shop More'),
        icon: Icon(Icons.storefront),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final VoidCallback onTap;
  final Map order;

  OrderCard({required this.order, required this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'shipped':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDate =
        DateFormat('MMM dd, yyyy').format(DateTime.parse(order['date']));
    final totalAmount =
        double.tryParse(order['amount'].toString())?.toStringAsFixed(2) ??
            '0.00';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "ORD${order['id'].toString().substring(0, 6).toUpperCase()}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['orderStatus'])
                          .withOpacity(0.1),
                      border: Border.all(
                          color: _getStatusColor(order['orderStatus'])),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(order['orderStatus']),
                            color: _getStatusColor(order['orderStatus']),
                            size: 16),
                        SizedBox(width: 4),
                        Text(order['orderStatus'].toString().capitalize(),
                            style: TextStyle(
                                color: _getStatusColor(order['orderStatus']),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              // Order info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Order Date\n$orderDate",
                      style: TextStyle(fontSize: 13)),
                  Text("Items\n${order['products'].length} items",
                      style: TextStyle(fontSize: 13)),
                  Text("Total\n₹$totalAmount",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
              Divider(),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.location_on, size: 20, color: Color(0xFF007B4F)),
                  Text("Track", style: TextStyle(color: Color(0xFF007B4F))),
                  VerticalDivider(),
                  Icon(Icons.remove_red_eye, size: 20, color: Colors.grey),
                  Text("Details", style: TextStyle(color: Colors.grey)),
                  VerticalDivider(),
                  Icon(Icons.refresh, size: 20, color: Colors.blue),
                  Text("Re-order", style: TextStyle(color: Colors.blue)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
}
