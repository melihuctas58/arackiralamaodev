import 'package:flutter/material.dart';
import '../../../data/repositories/logs_repository.dart';
import '../../../models/session.dart';

class LogsPage extends StatefulWidget { const LogsPage({super.key}); @override State<LogsPage> createState() => _LogsPageState(); }
class _LogsPageState extends State<LogsPage> {
  final _repo = LogsRepository();
  final _q = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _selected;
  String? _error; bool _loading = false;

  // Filtreler
  String _filterAction = 'Tümü';
  String _filterRelatedType = 'Tümü';
  List<String> _actions = ['Tümü'];
  List<String> _relatedTypes = ['Tümü'];

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _selected = null; _items = []; });
    try {
      _items = await _repo.listByBranch(Session().current!.subeId, q: _q.text.trim());
      
      // Aksiyonları ve ilgili tipleri topla
      final actionSet = <String>{'Tümü'};
      final relatedSet = <String>{'Tümü'};
      for (final m in _items) {
        final action = (m['ACTION'] ?? '').toString();
        final related = (m['RELATED_TYPE'] ?? '').toString();
        if (action.isNotEmpty) actionSet.add(action);
        if (related.isNotEmpty) relatedSet.add(related);
      }
      _actions = actionSet.toList()..sort();
      _relatedTypes = relatedSet.toList()..sort();
      
      _applyFilters();
    }
    catch (e) { _error = e.toString(); } finally { setState(() => _loading = false); }
  }

  void _applyFilters() {
    _filteredItems = _items.where((m) {
      // Action filtresi
      if (_filterAction != 'Tümü') {
        final action = (m['ACTION'] ?? '').toString();
        if (action != _filterAction) return false;
      }
      
      // Related Type filtresi
      if (_filterRelatedType != 'Tümü') {
        final related = (m['RELATED_TYPE'] ?? '').toString();
        if (related != _filterRelatedType) return false;
      }
      
      return true;
    }).toList();
    setState(() {});
  }

  @override void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 2, child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _q, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Log ara...'), onSubmitted: (_) => _load())),
          const SizedBox(width: 8), FilledButton(onPressed: _load, child: const Text('Yenile')),
        ])),
        
        // Filtreler
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            const Text('Filtreler: ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            
            // Action Filtresi
            DropdownButton<String>(
              value: _actions.contains(_filterAction) ? _filterAction : 'Tümü',
              items: _actions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => _filterAction = v ?? 'Tümü');
                _applyFilters();
              },
            ),
            const SizedBox(width: 12),
            
            // Related Type Filtresi
            DropdownButton<String>(
              value: _relatedTypes.contains(_filterRelatedType) ? _filterRelatedType : 'Tümü',
              items: _relatedTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() => _filterRelatedType = v ?? 'Tümü');
                _applyFilters();
              },
            ),
            
            const Spacer(),
            Text('${_filteredItems.length} / ${_items.length} log', style: const TextStyle(color: Colors.grey)),
          ]),
        ),
        const SizedBox(height: 8),
        
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text('Hata: $_error')) :
          ListView.separated(padding: const EdgeInsets.all(12), itemCount: _filteredItems.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
            final m = _filteredItems[i];
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