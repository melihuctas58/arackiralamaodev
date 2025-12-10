import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Şifre yönetim servisi
/// 1. Şifre: Uygulama girişi ve Loglar sayfası için
/// 2. Şifre: Çalışanlar, Şubeler ve Müşteriler sayfası için
class PasswordService {
  static const String _password1Key = 'app_password_1';
  static const String _password2Key = 'app_password_2';
  
  static const String defaultPassword1 = '1234';
  static const String defaultPassword2 = 'admin';

  /// 1. Şifreyi al (uygulama girişi ve Loglar için)
  Future<String> getPassword1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_password1Key) ?? defaultPassword1;
  }

  /// 2. Şifreyi al (Çalışanlar, Şubeler, Müşteriler için)
  Future<String> getPassword2() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_password2Key) ?? defaultPassword2;
  }

  /// 1. Şifreyi güncelle
  Future<void> setPassword1(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_password1Key, password);
  }

  /// 2. Şifreyi güncelle
  Future<void> setPassword2(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_password2Key, password);
  }

  /// 1. Şifreyi doğrula
  Future<bool> verifyPassword1(String password) async {
    final stored = await getPassword1();
    return stored == password;
  }

  /// 2. Şifreyi doğrula
  Future<bool> verifyPassword2(String password) async {
    final stored = await getPassword2();
    return stored == password;
  }

  /// Şifre girişi dialog göster
  static Future<bool> showPasswordDialog(
    BuildContext context, {
    required String title,
    required String description,
    required Future<bool> Function(String) verifyPassword,
  }) async {
    final controller = TextEditingController();
    bool obscureText = true;
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscureText,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscureText = !obscureText),
                  ),
                ),
                onSubmitted: (_) async {
                  final password = controller.text.trim();
                  if (password.isEmpty) return;
                  final isValid = await verifyPassword(password);
                  if (context.mounted) Navigator.of(context).pop(isValid);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                final password = controller.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şifre giriniz')),
                  );
                  return;
                }
                final isValid = await verifyPassword(password);
                if (context.mounted) {
                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifre yanlış'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    Navigator.of(context).pop(true);
                  }
                }
              },
              child: const Text('Doğrula'),
            ),
          ],
        ),
      ),
    ) ?? false;
  }
}
