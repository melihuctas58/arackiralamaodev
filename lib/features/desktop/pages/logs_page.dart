import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/logs_repository.dart';
import '../../../models/session.dart';

class LogsPage extends StatefulWidget { const LogsPage({super.key}); @override State<LogsPage> createState() => _LogsPageState(); }
class _LogsPageState extends State<LogsPage> {
  final _repo = LogsRepository();
  final _q = TextEditingController();
  final _passCtrl = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _selected;
  String? _error; bool _loading = false;
  bool _authenticated = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    final pass = _passCtrl.text.trim();
    if (pass.isEmpty) {
      setState(() => _error = 'Şifre giriniz');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final savedPass = prefs.getString('app_password') ?? '0000';
    
    if (pass == savedPass) {
      setState(() {
        _authenticated = true;
        _error = null;
      });
      await _load();
    } else {
      setState(() => _error = 'Şifre yanlış');
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _selected = null; _items = []; });
    try { _items = await _repo.listByBranch(Session().current!.subeId, q: _q.text.trim()); }
    catch (e) { _error = e.toString(); } finally { setState(() => _loading = false); }
  }

  @override void initState() { super.initState(); }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Center(
        child: Card(
          elevation: 4,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text('Loglar Sayfası', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Bu sayfaya erişmek için temel şifre gereklidir.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _passCtrl,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Temel Şifre',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.password),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  onSubmitted: (_) => _verifyPassword(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _verifyPassword,
                    icon: const Icon(Icons.login),
                    label: const Text('Giriş Yap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Row(children: [
      Expanded(flex: 2, child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _q, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Log ara...'), onSubmitted: (_) => _load())),
          const SizedBox(width: 8), FilledButton(onPressed: _load, child: const Text('Yenile')),
        ])),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text('Hata: $_error')) :
          ListView.separated(padding: const EdgeInsets.all(12), itemCount: _items.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
            final m = _items[i];
            return Card(child: ListTile(
              leading: const Icon(Icons.event_note),
              title: Text('${m['ACTION']} • ${m['MESSAGE']}'),
              subtitle: Text('${m['CREATED_AT']} • ${m['RELATED_TYPE'] ?? '-'}#${m['RELATED_ID'] ?? '-'}'),
              onTap: () => setState(() => _selected = m),
            ));
          })
        ),
      ])),
      const VerticalDivider(width: 1),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Log Detayı', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_selected == null) const Text('Listeden bir log seçiniz')
        else ...[
          Text('Aksiyon: ${_selected!['ACTION']}'),
          Text('Mesaj: ${_selected!['MESSAGE']}'),
          Text('İlgili: ${_selected!['RELATED_TYPE'] ?? '-'}#${_selected!['RELATED_ID'] ?? '-'}'),
          Text('Tarih: ${_selected!['CREATED_AT']}'),
          const SizedBox(height: 8),
          Text('Detaylar:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          SelectableText('${_selected!['DETAILS'] ?? '-'}'),
        ],
      ]))),
    ]);
  }
}