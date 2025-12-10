import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordManagementPage extends StatefulWidget {
  const PasswordManagementPage({super.key});
  @override
  State<PasswordManagementPage> createState() => _PasswordManagementPageState();
}

class _PasswordManagementPageState extends State<PasswordManagementPage> {
  final _currentPass1Ctrl = TextEditingController();
  final _newPass1Ctrl = TextEditingController();
  final _confirmPass1Ctrl = TextEditingController();
  
  final _currentPass2Ctrl = TextEditingController();
  final _newPass2Ctrl = TextEditingController();
  final _confirmPass2Ctrl = TextEditingController();
  
  bool _showPass1 = false;
  bool _showPass2 = false;
  String? _error1;
  String? _error2;
  
  String _currentAppPass = '0000';
  String _currentAdminPass = '1234';
  
  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }
  
  Future<void> _loadPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAppPass = prefs.getString('app_password') ?? '0000';
      _currentAdminPass = prefs.getString('admin_password') ?? '1234';
    });
  }
  
  Future<void> _changeAppPassword() async {
    setState(() => _error1 = null);
    
    if (_currentPass1Ctrl.text.trim().isEmpty) {
      setState(() => _error1 = 'Mevcut şifreyi giriniz');
      return;
    }
    
    if (_currentPass1Ctrl.text.trim() != _currentAppPass) {
      setState(() => _error1 = 'Mevcut şifre yanlış');
      return;
    }
    
    if (_newPass1Ctrl.text.trim().isEmpty) {
      setState(() => _error1 = 'Yeni şifre giriniz');
      return;
    }
    
    if (_newPass1Ctrl.text.trim().length < 4) {
      setState(() => _error1 = 'Şifre en az 4 karakter olmalı');
      return;
    }
    
    if (_newPass1Ctrl.text.trim() != _confirmPass1Ctrl.text.trim()) {
      setState(() => _error1 = 'Şifreler eşleşmiyor');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_password', _newPass1Ctrl.text.trim());
    
    setState(() {
      _currentAppPass = _newPass1Ctrl.text.trim();
      _error1 = null;
    });
    
    _currentPass1Ctrl.clear();
    _newPass1Ctrl.clear();
    _confirmPass1Ctrl.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birinci şifre (Uygulama/Loglar) başarıyla değiştirildi')),
      );
    }
  }
  
  Future<void> _changeAdminPassword() async {
    setState(() => _error2 = null);
    
    if (_currentPass2Ctrl.text.trim().isEmpty) {
      setState(() => _error2 = 'Mevcut şifreyi giriniz');
      return;
    }
    
    if (_currentPass2Ctrl.text.trim() != _currentAdminPass) {
      setState(() => _error2 = 'Mevcut şifre yanlış');
      return;
    }
    
    if (_newPass2Ctrl.text.trim().isEmpty) {
      setState(() => _error2 = 'Yeni şifre giriniz');
      return;
    }
    
    if (_newPass2Ctrl.text.trim().length < 4) {
      setState(() => _error2 = 'Şifre en az 4 karakter olmalı');
      return;
    }
    
    if (_newPass2Ctrl.text.trim() != _confirmPass2Ctrl.text.trim()) {
      setState(() => _error2 = 'Şifreler eşleşmiyor');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_password', _newPass2Ctrl.text.trim());
    
    setState(() {
      _currentAdminPass = _newPass2Ctrl.text.trim();
      _error2 = null;
    });
    
    _currentPass2Ctrl.clear();
    _newPass2Ctrl.clear();
    _confirmPass2Ctrl.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İkinci şifre (Yönetici) başarıyla değiştirildi')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Şifre Yönetimi', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Bu sayfada uygulama şifrelerini değiştirebilirsiniz. İki farklı şifre seviyesi vardır.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Birinci Şifre (Uygulama/Loglar)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.indigo),
                          const SizedBox(width: 12),
                          Text('Birinci Şifre (Uygulama Girişi / Loglar)', 
                            style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu şifre uygulama girişinde ve Loglar sayfasına erişimde kullanılır.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _currentPass1Ctrl,
                        obscureText: !_showPass1,
                        decoration: InputDecoration(
                          labelText: 'Mevcut Şifre',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_showPass1 ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showPass1 = !_showPass1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _newPass1Ctrl,
                        obscureText: !_showPass1,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _confirmPass1Ctrl,
                        obscureText: !_showPass1,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre Tekrar',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      
                      if (_error1 != null) ...[
                        const SizedBox(height: 12),
                        Text(_error1!, style: const TextStyle(color: Colors.red)),
                      ],
                      
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _changeAppPassword,
                        icon: const Icon(Icons.check),
                        label: const Text('Birinci Şifreyi Değiştir'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // İkinci Şifre (Yönetici)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text('İkinci Şifre (Yönetici / Üst Rütbe)', 
                            style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu şifre Çalışanlar ve Şubeler sayfalarına erişimde kullanılır. Sadece yetkili kişiler bu şifreyi bilmelidir.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _currentPass2Ctrl,
                        obscureText: !_showPass2,
                        decoration: InputDecoration(
                          labelText: 'Mevcut Şifre',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_showPass2 ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showPass2 = !_showPass2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _newPass2Ctrl,
                        obscureText: !_showPass2,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _confirmPass2Ctrl,
                        obscureText: !_showPass2,
                        decoration: const InputDecoration(
                          labelText: 'Yeni Şifre Tekrar',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      
                      if (_error2 != null) ...[
                        const SizedBox(height: 12),
                        Text(_error2!, style: const TextStyle(color: Colors.red)),
                      ],
                      
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _changeAdminPassword,
                        icon: const Icon(Icons.check),
                        label: const Text('İkinci Şifreyi Değiştir'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
