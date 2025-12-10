import 'package:flutter/material.dart';
import '../../../security/password_service.dart';
import '../../../data/repositories/logs_repository.dart';
import '../../../models/session.dart';

class PasswordManagementPage extends StatefulWidget {
  const PasswordManagementPage({super.key});

  @override
  State<PasswordManagementPage> createState() => _PasswordManagementPageState();
}

class _PasswordManagementPageState extends State<PasswordManagementPage> {
  final _passwordService = PasswordService();
  final _logsRepo = LogsRepository();

  final _oldPassword1Ctrl = TextEditingController();
  final _newPassword1Ctrl = TextEditingController();
  final _confirmPassword1Ctrl = TextEditingController();

  final _oldPassword2Ctrl = TextEditingController();
  final _newPassword2Ctrl = TextEditingController();
  final _confirmPassword2Ctrl = TextEditingController();

  bool _obscureOld1 = true;
  bool _obscureNew1 = true;
  bool _obscureConfirm1 = true;

  bool _obscureOld2 = true;
  bool _obscureNew2 = true;
  bool _obscureConfirm2 = true;

  bool _loading = false;

  @override
  void dispose() {
    _oldPassword1Ctrl.dispose();
    _newPassword1Ctrl.dispose();
    _confirmPassword1Ctrl.dispose();
    _oldPassword2Ctrl.dispose();
    _newPassword2Ctrl.dispose();
    _confirmPassword2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword1() async {
    final oldPass = _oldPassword1Ctrl.text.trim();
    final newPass = _newPassword1Ctrl.text.trim();
    final confirmPass = _confirmPassword1Ctrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Tüm alanları doldurunuz');
      return;
    }

    if (newPass.length < 4) {
      _showError('Yeni şifre en az 4 karakter olmalıdır');
      return;
    }

    if (newPass != confirmPass) {
      _showError('Yeni şifreler eşleşmiyor');
      return;
    }

    setState(() => _loading = true);

    try {
      final isValid = await _passwordService.verifyPassword1(oldPass);
      if (!isValid) {
        _showError('Eski şifre yanlış');
        return;
      }

      await _passwordService.setPassword1(newPass);

      // Loglama
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current!.calisanId,
        action: 'SIFRE_DEGISTIRME',
        message: '1. Şifre (Temel) değiştirildi',
        details: {'sifre_turu': '1. Şifre (Temel)'},
      );

      _oldPassword1Ctrl.clear();
      _newPassword1Ctrl.clear();
      _confirmPassword1Ctrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('1. Şifre başarıyla değiştirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePassword2() async {
    final oldPass = _oldPassword2Ctrl.text.trim();
    final newPass = _newPassword2Ctrl.text.trim();
    final confirmPass = _confirmPassword2Ctrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Tüm alanları doldurunuz');
      return;
    }

    if (newPass.length < 4) {
      _showError('Yeni şifre en az 4 karakter olmalıdır');
      return;
    }

    if (newPass != confirmPass) {
      _showError('Yeni şifreler eşleşmiyor');
      return;
    }

    setState(() => _loading = true);

    try {
      final isValid = await _passwordService.verifyPassword2(oldPass);
      if (!isValid) {
        _showError('Eski şifre yanlış');
        return;
      }

      await _passwordService.setPassword2(newPass);

      // Loglama
      await _logsRepo.add(
        subeId: Session().current!.subeId,
        calisanId: Session().current!.calisanId,
        action: 'SIFRE_DEGISTIRME',
        message: '2. Şifre (Yönetici/Üst Rütbe) değiştirildi',
        details: {'sifre_turu': '2. Şifre (Yönetici)'},
      );

      _oldPassword2Ctrl.clear();
      _newPassword2Ctrl.clear();
      _confirmPassword2Ctrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2. Şifre başarıyla değiştirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şifre Yönetimi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu sayfadan uygulama şifrelerini değiştirebilirsiniz.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // 1. Şifre Değiştirme
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Şifre (Temel)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bu şifre uygulama girişi ve Loglar sayfası için kullanılır.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: _oldPassword1Ctrl,
                            label: 'Eski Şifre',
                            obscureText: _obscureOld1,
                            onToggleVisibility: () => setState(() => _obscureOld1 = !_obscureOld1),
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _newPassword1Ctrl,
                            label: 'Yeni Şifre',
                            obscureText: _obscureNew1,
                            onToggleVisibility: () => setState(() => _obscureNew1 = !_obscureNew1),
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _confirmPassword1Ctrl,
                            label: 'Yeni Şifre (Tekrar)',
                            obscureText: _obscureConfirm1,
                            onToggleVisibility: () => setState(() => _obscureConfirm1 = !_obscureConfirm1),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _changePassword1,
                              icon: const Icon(Icons.lock_reset),
                              label: const Text('1. Şifreyi Değiştir'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Şifre Değiştirme
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2. Şifre (Yönetici/Üst Rütbe)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bu şifre Çalışanlar, Şubeler ve Müşteriler sayfaları için kullanılır.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: _oldPassword2Ctrl,
                            label: 'Eski Şifre',
                            obscureText: _obscureOld2,
                            onToggleVisibility: () => setState(() => _obscureOld2 = !_obscureOld2),
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _newPassword2Ctrl,
                            label: 'Yeni Şifre',
                            obscureText: _obscureNew2,
                            onToggleVisibility: () => setState(() => _obscureNew2 = !_obscureNew2),
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _confirmPassword2Ctrl,
                            label: 'Yeni Şifre (Tekrar)',
                            obscureText: _obscureConfirm2,
                            onToggleVisibility: () => setState(() => _obscureConfirm2 = !_obscureConfirm2),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _changePassword2,
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text('2. Şifreyi Değiştir'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bilgi Kartı
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Varsayılan Şifreler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '1. Şifre: "${PasswordService.defaultPassword1}" • 2. Şifre: "${PasswordService.defaultPassword2}"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Şifrelerinizi düzenli olarak değiştirmeniz önerilir.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
