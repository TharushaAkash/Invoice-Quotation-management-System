import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService extends ChangeNotifier {
  static const String _logoKey = 'business_logo_path';
  static const String _phoneKey = 'business_phone';
  static const String _emailKey = 'business_email';

  String? _logoPath;
  String? _phone;
  String? _email;

  String? get logoPath => _logoPath;
  String? get phone => _phone;
  String? get email => _email;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _logoPath = prefs.getString(_logoKey);
    _phone = prefs.getString(_phoneKey);
    _email = prefs.getString(_emailKey);
    notifyListeners();
  }

  Future<void> setLogoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logoKey, path);
    _logoPath = path;
    notifyListeners();
  }

  Future<void> clearLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logoKey);
    _logoPath = null;
    notifyListeners();
  }

  Future<void> saveBusinessDetails(String phone, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
    _phone = phone;
    _email = email;
    notifyListeners();
  }
}
