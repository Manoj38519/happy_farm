import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD123456',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Delivered',
      'total': 79.99,
      'items': 3,
      'paymentMethod': 'Credit Card',
      'address': '123 Farm Road, Green Valley',
      'trackingNumber': 'TRK789012345',
    },
    {
      'id': 'ORD123455',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Shipped',
      'total': 49.99,
      'items': 2,
      'paymentMethod': 'PayPal',
      'address': '456 Harvest Lane, Meadow Hills',
      'trackingNumber': 'TRK789012344',
    },
    {
      'id': 'ORD123454',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Processing',
      'total': 129.99,
      'items': 5,
      'paymentMethod': 'Credit Card',
      'address': '789 Orchard Street, Apple Grove',
      'trackingNumber': 'TRK789012343',
    },
    {
      'id': 'ORD123453',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Delivered',
      'total': 89.50,
      'items': 4,
      'paymentMethod': 'Debit Card',
      'address': '321 Garden Way, Floral Park',
      'trackingNumber': 'TRK789012342',
    },
    {
      'id': 'ORD123452',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Cancelled',
      'total': 59.99,
      'items': 2,
      'paymentMethod': 'Google Pay',
      'address': '654 Barnyard Drive, Country Side',
      'trackingNumber': 'TRK789012341',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.history;
    }
  }

  List<Map<String, dynamic>> getFilteredOrders(String filter) {
    if (filter == 'All') {
      return orders;
    }
    return orders.where((order) => order['status'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.green[800],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          'All',
          'Processing',
          'Shipped',
          'Delivered',
          'Cancelled',
        ].map((filter) {
          final filteredOrders = getFilteredOrders(filter);
          
          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $filter orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter == 'All' 
                        ? 'You haven\'t placed any orders yet'
                        : 'You don\'t have any $filter orders',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final formattedDate = DateFormat('MMM dd, yyyy').format(order['date'] as DateTime);
              
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                color: Colors.green[800],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${order['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(order['status'] as String).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: getStatusColor(order['status'] as String).withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getStatusIcon(order['status'] as String),
                                  size: 16,
                                  color: getStatusColor(order['status'] as String),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order['status'] as String,
                                  style: TextStyle(
                                    color: getStatusColor(order['status'] as String),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Date',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Items',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order['items']} items',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${order['total']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            if (order['status'] != 'Cancelled')
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    // Show tracking
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Tracking order ${order['id']}'),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.green[800],
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Track',
                                    style: TextStyle(
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ),
                            if (order['status'] != 'Cancelled')
                              const VerticalDivider(width: 1),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  // View Order Details
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (context) => _buildOrderDetailsSheet(order),
                                  );
                                },
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                label: const Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  // Re-order or support
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(order['status'] == 'Cancelled' 
                                          ? 'Contact support for ${order['id']}'
                                          : 'Reordering items from ${order['id']}'),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  order['status'] == 'Cancelled' 
                                      ? Icons.contact_support_outlined
                                      : Icons.replay_outlined,
                                  size: 18,
                                  color: order['status'] == 'Cancelled' 
                                      ? Colors.orange[700]
                                      : Colors.blue[700],
                                ),
                                label: Text(
                                  order['status'] == 'Cancelled' ? 'Support' : 'Re-order',
                                  style: TextStyle(
                                    color: order['status'] == 'Cancelled' 
                                        ? Colors.orange[700]
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to products
          Navigator.pop(context);
        },
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Shop More'),
      ),
    );
  }
  
  Widget _buildOrderDetailsSheet(Map<String, dynamic> order) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(order['date'] as DateTime);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Order ID and Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_outlined,
                        color: Colors.green[800],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Placed on $formattedDate',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(order['status'] as String).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: getStatusColor(order['status'] as String).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        order['status'] as String,
                        style: TextStyle(
                          color: getStatusColor(order['status'] as String),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Order summary
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Items', '${order['items']} items'),
                _buildInfoRow('Order Total', '\$${order['total']}'),
                _buildInfoRow('Payment Method', order['paymentMethod'] as String),
                if (order['status'] != 'Cancelled')
                  _buildInfoRow('Tracking Number', order['trackingNumber'] as String),
                const Divider(height: 32),
                // Shipping address
                Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.green[800],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          order['address'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Download invoice
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading invoice for order ${order['id']}'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Download Invoice'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Contact support
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contacting support...'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[800],
                        side: BorderSide(color: Colors.green[800]!),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.headset_mic_outlined),
                      label: const Text('Help'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}