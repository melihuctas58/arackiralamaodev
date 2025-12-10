import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/logs_repository.dart';
import '../../../models/session.dart';

class PasswordManagementPage extends StatefulWidget {
  const PasswordManagementPage({super.key});
  @override
  State<PasswordManagementPage> createState() => _PasswordManagementPageState();
}

class _PasswordManagementPageState extends State<PasswordManagementPage> {
  final _logsRepo = LogsRepository();
  
  final _currentPass1Ctrl = TextEditingController();
  final _newPass1Ctrl = TextEditingController();
  final _confirmPass1Ctrl = TextEditingController();
  
  final _currentPass2Ctrl = TextEditingController();
  final _newPass2Ctrl = TextEditingController();
  final _confirmPass2Ctrl = TextEditingController();
  
  bool _showCurrentPass1 = false;
  bool _showNewPass1 = false;
  bool _showConfirmPass1 = false;
  
  bool _showCurrentPass2 = false;
  bool _showNewPass2 = false;
  bool _showConfirmPass2 = false;
  
  String? _error;
  String? _success;
  
  @override
  void dispose() {
    _currentPass1Ctrl.dispose();
    _newPass1Ctrl.dispose();
    _confirmPass1Ctrl.dispose();
    _currentPass2Ctrl.dispose();
    _newPass2Ctrl.dispose();
    _confirmPass2Ctrl.dispose();
    super.dispose();
  }
  
  Future<void> _changePassword1() async {
    setState(() {
      _error = null;
      _success = null;
    });
    
    final currentPass = _currentPass1Ctrl.text.trim();
    final newPass = _newPass1Ctrl.text.trim();
    final confirmPass = _confirmPass1Ctrl.text.trim();
    
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _error = 'Tüm alanları doldurun');
      return;
    }
    
    if (newPass.length < 4) {
      setState(() => _error = 'Yeni şifre en az 4 karakter olmalı');
      return;
    }
    
    if (newPass != confirmPass) {
      setState(() => _error = 'Yeni şifreler eşleşmiyor');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPass = prefs.getString('app_password') ?? '0000';
      
      if (currentPass != savedPass) {
        setState(() => _error = 'Mevcut şifre yanlış');
        return;
      }
      
      await prefs.setString('app_password', newPass);
      
      // Log the password change (without showing the password)
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current?.calisanId,
        action: 'SIFRE_DEGISTIR',
        message: 'Temel şifre (Seviye 1) değiştirildi',
        relatedType: 'PASSWORD',
      );
      
      setState(() {
        _success = 'Temel şifre başarıyla değiştirildi';
        _currentPass1Ctrl.clear();
        _newPass1Ctrl.clear();
        _confirmPass1Ctrl.clear();
      });
    } catch (e) {
      setState(() => _error = 'Hata: $e');
    }
  }
  
  Future<void> _changePassword2() async {
    setState(() {
      _error = null;
      _success = null;
    });
    
    final currentPass = _currentPass2Ctrl.text.trim();
    final newPass = _newPass2Ctrl.text.trim();
    final confirmPass = _confirmPass2Ctrl.text.trim();
    
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _error = 'Tüm alanları doldurun');
      return;
    }
    
    if (newPass.length < 4) {
      setState(() => _error = 'Yeni şifre en az 4 karakter olmalı');
      return;
    }
    
    if (newPass != confirmPass) {
      setState(() => _error = 'Yeni şifreler eşleşmiyor');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPass = prefs.getString('admin_password') ?? '0000';
      
      if (currentPass != savedPass) {
        setState(() => _error = 'Mevcut şifre yanlış');
        return;
      }
      
      await prefs.setString('admin_password', newPass);
      
      // Log the password change (without showing the password)
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current?.calisanId,
        action: 'SIFRE_DEGISTIR',
        message: 'Yönetici şifresi (Seviye 2) değiştirildi',
        relatedType: 'PASSWORD',
      );
      
      setState(() {
        _success = 'Yönetici şifresi başarıyla değiştirildi';
        _currentPass2Ctrl.clear();
        _newPass2Ctrl.clear();
        _confirmPass2Ctrl.clear();
      });
    } catch (e) {
      setState(() => _error = 'Hata: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Colors.indigo, size: 32),
              const SizedBox(width: 12),
              Text('Şifre Yönetimi', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'İki farklı şifre seviyesi bulunmaktadır. Temel şifre uygulama girişi ve Loglar sayfası için, Yönetici şifresi ise Çalışanlar ve Şubeler sayfası için kullanılır.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _error = null),
                  ),
                ],
              ),
            ),
          
          if (_success != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_success!, style: const TextStyle(color: Colors.green))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _success = null),
                  ),
                ],
              ),
            ),
          
          // Password Level 1 Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Temel Şifre (Seviye 1)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Uygulama girişi ve Loglar sayfası', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  TextField(
                    controller: _currentPass1Ctrl,
                    obscureText: !_showCurrentPass1,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Şifre',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showCurrentPass1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showCurrentPass1 = !_showCurrentPass1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPass1Ctrl,
                    obscureText: !_showNewPass1,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showNewPass1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showNewPass1 = !_showNewPass1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPass1Ctrl,
                    obscureText: !_showConfirmPass1,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre (Tekrar)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPass1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showConfirmPass1 = !_showConfirmPass1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _changePassword1,
                      icon: const Icon(Icons.save),
                      label: const Text('Temel Şifreyi Değiştir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Password Level 2 Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yönetici Şifresi (Seviye 2)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Çalışanlar ve Şubeler sayfası', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  TextField(
                    controller: _currentPass2Ctrl,
                    obscureText: !_showCurrentPass2,
                    decoration: InputDecoration(
                      labelText: 'Mevcut Şifre',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showCurrentPass2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showCurrentPass2 = !_showCurrentPass2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPass2Ctrl,
                    obscureText: !_showNewPass2,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showNewPass2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showNewPass2 = !_showNewPass2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPass2Ctrl,
                    obscureText: !_showConfirmPass2,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre (Tekrar)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPass2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showConfirmPass2 = !_showConfirmPass2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _changePassword2,
                      icon: const Icon(Icons.save),
                      label: const Text('Yönetici Şifresini Değiştir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
