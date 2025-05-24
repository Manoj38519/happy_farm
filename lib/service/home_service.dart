import 'dart:convert';
import 'package:happy_farm/models/banner_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happy_farm/models/product_model.dart';

class HomeService {
  static const String baseUrl = 'https://api.sabbafarm.com/api';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded;
    } else {
      final message = decoded['message'] ?? 'Unexpected error occurred';
      throw Exception('Error ${response.statusCode}: $message');
    }
  }

  Future<List<dynamic>> searchProducts(String query) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: headers,
    );
    final data = _handleResponse(response);
    return data;
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/category'),
      headers: headers,
    );
    final decoded = _handleResponse(response);
    final List data = decoded['categoryList'];
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<FilterProducts>> fetchFilteredProducts({
    required String categoryId,
    int? minPrice,
    int? maxPrice,
    int? rating,
  }) async {
    String url;

    if (rating != null) {
      url = '$baseUrl/products/rating?catId=$categoryId&rating=$rating';
    } else if (minPrice != null && maxPrice != null) {
      url =
          '$baseUrl/products/filterByPrice?minPrice=$minPrice&maxPrice=$maxPrice&catId=$categoryId';
    } else {
      throw Exception('Invalid filter parameters');
    }

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final decoded = _handleResponse(response);
    final List data = decoded['products'];
    return data.map<FilterProducts>((json) => FilterProducts.fromJson(json)).toList();
  }

  Future<List<FeaturedProduct>> fetchFeaturedProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/products/featured'),
      headers: headers,
    );
    final List data = _handleResponse(response);
    return data.map((product) => FeaturedProduct.fromJson(product)).toList();
  }

  Future<List<FilterProducts>> fetchProductsByCategory(String catName) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/products/catName?catName=$catName'),
      headers: headers,
    );
    final decoded = _handleResponse(response);
    final List data = decoded['products'];
    return data.map<FilterProducts>((json) => FilterProducts.fromJson(json)).toList();
  }

  Future<List<AllProduct>> fetchAllProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: headers,
    );
    final decoded = _handleResponse(response);
    final List data = decoded['products'];
    return data.map((json) => AllProduct.fromJson(json)).toList();
  }
  Future<List<BannerModel>> fetchBanners() async {
  final headers = await _getHeaders();
  final response = await http.get(
      Uri.parse('$baseUrl/homeBanner/'),
      headers: headers,
    );
  
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((e) => BannerModel.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load banners');
  }
}

}
