import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutService {
  static const String baseUrl='https://api.sabbafarm.com/api';
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch user details');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createOrder({
    required String name,
    required String phoneNumber,
    required String email,
    required String address,
    required String pincode,
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'pincode': pincode,
      'email': email,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-order'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print('Failed to create order: ${response.body}');
      return null;
    }
  }

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'orderId': orderId,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/payment/verify-order'),
      headers: headers,
      body: body,
    );

    return response.statusCode == 200;
  }
}
