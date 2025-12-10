import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordProtectedPage extends StatefulWidget {
  final Widget child;
  final String passwordKey; // 'app_password' or 'admin_password'
  final String defaultPassword; // '0000' or '1234'
  final String title;
  
  const PasswordProtectedPage({
    super.key,
    required this.child,
    required this.passwordKey,
    required this.defaultPassword,
    required this.title,
  });
  
  @override
  State<PasswordProtectedPage> createState() => _PasswordProtectedPageState();
}

class _PasswordProtectedPageState extends State<PasswordProtectedPage> {
  final _passCtrl = TextEditingController();
  bool _showPassword = false;
  bool _verified = false;
  String? _error;
  String _currentPassword = '';
  
  @override
  void initState() {
    super.initState();
    _loadPassword();
  }
  
  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPassword = prefs.getString(widget.passwordKey) ?? widget.defaultPassword;
    });
  }
  
  Future<void> _verifyPassword() async {
    if (_passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Şifre giriniz');
      return;
    }
    
    if (_passCtrl.text.trim() == _currentPassword) {
      setState(() {
        _verified = true;
        _error = null;
      });
    } else {
      setState(() => _error = 'Şifre yanlış');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return widget.child;
    }
    
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(widget.title, 
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu sayfaya erişmek için şifre giriniz',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _passCtrl,
                    obscureText: !_showPassword,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    onSubmitted: (_) => _verifyPassword(),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _verifyPassword,
                      child: const Text('Giriş'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
