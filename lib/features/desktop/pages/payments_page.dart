import 'package:flutter/material.dart';
import '../../../data/repositories/payment_repository.dart' as pay;
import '../../../data/repositories/rental_repository.dart' as rent;
import '../../../models/session.dart';

class PaymentsPage extends StatefulWidget { const PaymentsPage({super.key}); @override State<PaymentsPage> createState() => _PaymentsPageState(); }
class _PaymentsPageState extends State<PaymentsPage> {
  final _repo = pay.PaymentRepository();
  final _rentalRepo = rent.RentalRepository();

  final _q = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  String? _error;

  // Filtreler
  String _filterTur = 'Tümü'; // Kira, Ceza, Sigorta, Bakım, Kaza
  String _filterTip = 'Tümü'; // Nakit, Kart, Havale
  List<String> _turler = ['Tümü'];
  List<String> _tipler = ['Tümü'];

  final upTutar = TextEditingController();
  String upTur = 'Kira';
  String upTip = 'Nakit';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _selected = null; });
    try {
      _items = await _repo.listByBranch(Session().current!.subeId, q: _q.text.trim());
      
      // Tür ve Tip topla
      final turSet = <String>{'Tümü'};
      final tipSet = <String>{'Tümü'};
      for (final m in _items) {
        final tur = (m['ODEME_TURU'] ?? '').toString();
        final tip = (m['ODEME_TIPI'] ?? '').toString();
        if (tur.isNotEmpty) turSet.add(tur);
        if (tip.isNotEmpty) tipSet.add(tip);
      }
      _turler = turSet.toList()..sort();
      _tipler = tipSet.toList()..sort();
      
      _applyFilters();
    }
    catch (e) { _error = e.toString(); } finally { setState(() => _loading = false); }
  }

  void _applyFilters() {
    _filteredItems = _items.where((m) {
      // Tür filtresi
      if (_filterTur != 'Tümü') {
        final tur = (m['ODEME_TURU'] ?? '').toString();
        if (tur != _filterTur) return false;
      }
      
      // Tip filtresi
      if (_filterTip != 'Tümü') {
        final tip = (m['ODEME_TIPI'] ?? '').toString();
        if (tip != _filterTip) return false;
      }
      
      return true;
    }).toList();
    setState(() {});
  }

  Future<void> _delete() async {
    if (_selected == null) return;
    try { await _repo.delete(_selected!['ODEME_ID'] as int); setState(() => _selected = null); _sn('Ödeme silindi'); await _load(); }
    catch (e) { _err(e); }
  }

  Future<void> _update() async {
    if (_selected == null) return;
    try {
      await _repo.update(
        odemeId: _selected!['ODEME_ID'] as int,
        tutar: double.tryParse(upTutar.text),
        tur: upTur,
        tipi: upTip,
      );
      _sn('Ödeme güncellendi'); await _load();
    } catch (e) { _err(e); }
  }

  void _fill(Map<String, dynamic> m) {
    _selected = m;
    upTutar.text = (m['ODEME_TUTARI'] ?? '').toString();
    upTur = (m['ODEME_TURU'] ?? 'Kira').toString();
    upTip = (m['ODEME_TIPI'] ?? 'Nakit').toString();
    setState(() {});
  }

  // ödenmiş/ödenmemiş belirgin rozet
  String _payStatus(Map<String, dynamic> m) {
    // burada basitçe "Kampanya/Diğer" tipleri için "Bekleyen" gibi düşünebiliriz;
    // kesin hesaplama gerektiriyorsa kiralama/sigorta/bakım ceza tutarlarına göre ayrıştırma yapılır.
    final tip = (m['ODEME_TIPI'] ?? '') as String;
    if (tip.toLowerCase() == 'kampanya' || tip.toLowerCase() == 'diğer' || tip.toLowerCase() == 'diger') return 'Bekleyen';
    return 'Ödenmiş';
  }
  Color _statusColor(String s) => s == 'Bekleyen' ? Colors.orange : Colors.green;

  void _sn(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  void _err(Object e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 2, child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _q, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Ödeme/Plaka/Model/Kiralama ara...'), onSubmitted: (_) => _load())),
          const SizedBox(width: 8), FilledButton(onPressed: _load, child: const Text('Yenile')),
        ])),
        
        // Filtreler
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            const Text('Filtreler: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            
            // Ödeme Türü Filtresi
            DropdownButton<String>(
              value: _turler.contains(_filterTur) ? _filterTur : 'Tümü',
              items: _turler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => _filterTur = v ?? 'Tümü');
                _applyFilters();
              },
            ),
            const SizedBox(width: 16),
            
            // Ödeme Tipi Filtresi
            DropdownButton<String>(
              value: _tipler.contains(_filterTip) ? _filterTip : 'Tümü',
              items: _tipler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => _filterTip = v ?? 'Tümü');
                _applyFilters();
              },
            ),
            
            const Spacer(),
            Text('${_filteredItems.length} / ${_items.length} kayıt', style: const TextStyle(color: Colors.grey)),
          ]),
        ),
        const SizedBox(height: 8),
        
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text('Hata: $_error')) :
          ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _filteredItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = _filteredItems[i];
              final label = (m['ODEME_TURU'] ?? '-') as String;
              final tip = (m['ODEME_TIPI'] ?? '-') as String;
              final tutar = (m['ODEME_TUTARI'] ?? 0).toDouble();
              final status = _payStatus(m);
              final color = _statusColor(status);
              return Card(child: ListTile(
                leading: const Icon(Icons.payments),
                title: Text('Ödeme#${m['ODEME_ID']} • ${m['PLAKA'] ?? '-'} • ${m['Marka'] ?? '-'} ${m['Model'] ?? ''}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tür: $label • Tip: $tip • Tutar: ${tutar.toStringAsFixed(2)} TL'),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ]),
                  ],
                ),
                trailing: OutlinedButton.icon(
                  onPressed: () => _fill(m),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Düzenle'),
                ),
                onTap: () => _fill(m),
              ));
            },
          ),
        ),
      ])),
      const VerticalDivider(width: 1),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ödeme Detay', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_selected == null) const Text('Listeden bir ödeme seçin') else Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ID: ${_selected!['ODEME_ID']}'),
          const SizedBox(height: 8),
          TextField(controller: upTutar, decoration: const InputDecoration(labelText: 'Tutar (TL)'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: upTur, items: const [
            DropdownMenuItem(value: 'Kira', child: Text('Kira')),
            DropdownMenuItem(value: 'Depozito', child: Text('Depozito')),
            DropdownMenuItem(value: 'İade', child: Text('İade')),
            DropdownMenuItem(value: 'Ceza', child: Text('Ceza')),
            DropdownMenuItem(value: 'Sigorta', child: Text('Sigorta')),
            DropdownMenuItem(value: 'Bakım', child: Text('Bakım')),
            DropdownMenuItem(value: 'Kaza', child: Text('Kaza')),
            DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
          ], onChanged: (v) => setState(() => upTur = v ?? upTur), decoration: const InputDecoration(labelText: 'Tür')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: upTip, items: const [
            DropdownMenuItem(value: 'Nakit', child: Text('Nakit')),
            DropdownMenuItem(value: 'Kart', child: Text('Kart')),
            DropdownMenuItem(value: 'Havale', child: Text('Havale')),
            DropdownMenuItem(value: 'Kampanya', child: Text('Kampanya')),
            DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
          ], onChanged: (v) => setState(() => upTip = v ?? upTip), decoration: const InputDecoration(labelText: 'Tip')),
          const SizedBox(height: 12),
          Row(children: [
            FilledButton(onPressed: _update, child: const Text('Güncelle')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _delete, child: const Text('Sil')),
          ]),
        ]),
      ]))),
    ]);
  }
}