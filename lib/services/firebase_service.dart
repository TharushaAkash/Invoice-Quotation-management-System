import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

class FirebaseService extends ChangeNotifier {
  final String _baseUrl = FirebaseConfig.databaseURL;
  String? _authToken;
  String? _userId;

  void updateAuth(String? token, String? userId) {
    _authToken = token;
    _userId = userId;
    notifyListeners();
  }
  
  String _getUrl(String path) {
    String url = _baseUrl;
    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    // Remove leading slash from path if present
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    
    // Firebase Realtime Database REST API requires .json extension
    // And auth token if authenticated
    String finalUrl = '$url/$path.json';
    if (_authToken != null) {
      finalUrl += '?auth=$_authToken';
    }
    return finalUrl;
  }

  // Generic save method (creates new item with auto-generated ID)
  Future<String> save(String path, Map<String, dynamic> data) async {
    final url = _getUrl(path);
    
    // Add userId to data if authenticated
    if (_userId != null) {
      data['creatorId'] = _userId;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 200) {
      // Firebase returns the key in the response
      final key = json.decode(response.body)['name'] as String?;
      return key ?? DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      throw Exception('Failed to save: ${response.statusCode} ${response.body}');
    }
  }

  // Generic update method
  Future<void> update(String path, String id, Map<String, dynamic> data) async {
    final url = _getUrl('$path/$id');
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }

  // Generic delete method
  Future<void> delete(String path, String id) async {
    final url = _getUrl('$path/$id');
    final response = await http.delete(Uri.parse(url));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }

  // Generic get method
  Future<Map<String, dynamic>?> get(String path, String id) async {
    final url = _getUrl('$path/$id');
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }
    return null;
  }

  // Generic get all method
  Future<List<Map<String, dynamic>>> getAll(String path) async {
    final url = _getUrl(path);
    final response = await http.get(Uri.parse(url));
    final List<Map<String, dynamic>> items = [];
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            items.add({
              'id': key,
              ...Map<String, dynamic>.from(value),
            });
          }
        });
      }
    }
    
    return items;
  }
}
