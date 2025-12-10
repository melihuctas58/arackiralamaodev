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
  
  final _currentAdminPassCtrl = TextEditingController();
  final _newBasicPassCtrl = TextEditingController();
  final _confirmBasicPassCtrl = TextEditingController();
  final _newAdminPassCtrl = TextEditingController();
  final _confirmAdminPassCtrl = TextEditingController();
  
  bool _showPasswords = false;
  String? _error;
  String? _success;
  
  String _currentBasicPass = '0000';
  String _currentAdminPass = '9999';
  bool _adminVerified = false;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBasicPass = prefs.getString('app_password') ?? '0000';
      _currentAdminPass = prefs.getString('admin_password') ?? '9999';
    });
  }

  Future<void> _verifyAdmin() async {
    if (_currentAdminPassCtrl.text.trim() != _currentAdminPass) {
      setState(() {
        _error = 'Yönetici şifresi yanlış';
        _success = null;
      });
      return;
    }
    setState(() {
      _adminVerified = true;
      _error = null;
      _success = 'Yönetici şifresi doğrulandı';
    });
  }

  Future<void> _changeBasicPassword() async {
    if (!_adminVerified) {
      setState(() {
        _error = 'Önce yönetici şifresi ile giriş yapın';
        _success = null;
      });
      return;
    }

    if (_newBasicPassCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'Yeni temel şifre giriniz';
        _success = null;
      });
      return;
    }

    if (_newBasicPassCtrl.text.trim().length < 4) {
      setState(() {
        _error = 'Şifre en az 4 karakter olmalı';
        _success = null;
      });
      return;
    }

    if (_newBasicPassCtrl.text.trim() != _confirmBasicPassCtrl.text.trim()) {
      setState(() {
        _error = 'Şifreler eşleşmiyor';
        _success = null;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_password', _newBasicPassCtrl.text.trim());
    
    // Log the change
    try {
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current?.calisanId,
        action: 'SIFRE_DEGISIKLIK',
        message: 'Temel şifre değiştirildi',
        relatedType: 'SIFRE',
        relatedId: null,
      );
    } catch (_) {}

    setState(() {
      _currentBasicPass = _newBasicPassCtrl.text.trim();
      _error = null;
      _success = 'Temel şifre başarıyla değiştirildi';
      _newBasicPassCtrl.clear();
      _confirmBasicPassCtrl.clear();
    });
  }

  Future<void> _changeAdminPassword() async {
    if (!_adminVerified) {
      setState(() {
        _error = 'Önce yönetici şifresi ile giriş yapın';
        _success = null;
      });
      return;
    }

    if (_newAdminPassCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'Yeni yönetici şifresi giriniz';
        _success = null;
      });
      return;
    }

    if (_newAdminPassCtrl.text.trim().length < 4) {
      setState(() {
        _error = 'Şifre en az 4 karakter olmalı';
        _success = null;
      });
      return;
    }

    if (_newAdminPassCtrl.text.trim() != _confirmAdminPassCtrl.text.trim()) {
      setState(() {
        _error = 'Şifreler eşleşmiyor';
        _success = null;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_password', _newAdminPassCtrl.text.trim());
    
    // Log the change
    try {
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current?.calisanId,
        action: 'SIFRE_DEGISIKLIK',
        message: 'Yönetici şifresi değiştirildi',
        relatedType: 'SIFRE',
        relatedId: null,
      );
    } catch (_) {}

    setState(() {
      _currentAdminPass = _newAdminPassCtrl.text.trim();
      _error = null;
      _success = 'Yönetici şifresi başarıyla değiştirildi';
      _newAdminPassCtrl.clear();
      _confirmAdminPassCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.indigo, size: 32),
              const SizedBox(width: 12),
              Text('Şifre Yönetimi', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_success!, style: const TextStyle(color: Colors.green))),
                ],
              ),
            ),

          // Admin verification section
          if (!_adminVerified) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yönetici Doğrulama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Şifreleri yönetmek için önce yönetici şifrenizi girin.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentAdminPassCtrl,
                      obscureText: !_showPasswords,
                      decoration: InputDecoration(
                        labelText: 'Yönetici Şifresi',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.admin_panel_settings),
                        suffixIcon: IconButton(
                          icon: Icon(_showPasswords ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPasswords = !_showPasswords),
                        ),
                      ),
                      onSubmitted: (_) => _verifyAdmin(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _verifyAdmin,
                        icon: const Icon(Icons.check),
                        label: const Text('Doğrula'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Change Basic Password Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          '1. Şifre (Temel)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uygulama girişi ve Loglar sayfası için kullanılır.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newBasicPassCtrl,
                      obscureText: !_showPasswords,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Temel Şifre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmBasicPassCtrl,
                      obscureText: !_showPasswords,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Temel Şifre (Tekrar)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _changeBasicPassword,
                        icon: const Icon(Icons.save),
                        label: const Text('Temel Şifreyi Değiştir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Change Admin Password Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          '2. Şifre (Yönetici)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Çalışanlar ve Şubeler sayfası için kullanılır. Üst düzey yetki.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newAdminPassCtrl,
                      obscureText: !_showPasswords,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Yönetici Şifresi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmAdminPassCtrl,
                      obscureText: !_showPasswords,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Yönetici Şifresi (Tekrar)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _changeAdminPassword,
                        icon: const Icon(Icons.save),
                        label: const Text('Yönetici Şifresini Değiştir'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Show/Hide passwords toggle
            Row(
              children: [
                Checkbox(
                  value: _showPasswords,
                  onChanged: (v) => setState(() => _showPasswords = v ?? false),
                ),
                const Text('Şifreleri göster'),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Information section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Bilgi',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Temel şifre: Uygulama girişi ve Loglar sayfası için gereklidir.'),
                  const Text('• Yönetici şifresi: Çalışanlar ve Şubeler sayfası için gereklidir.'),
                  const Text('• Yönetici şifresi, temel şifreyi değiştirebilir.'),
                  const Text('• Tüm şifre değişiklikleri sistem loglarına kaydedilir.'),
                  const Text('• Şifreler en az 4 karakter olmalıdır.'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
