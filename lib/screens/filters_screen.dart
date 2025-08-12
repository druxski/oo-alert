import 'package:flutter/material.dart';
import '../services/db_provider.dart';

class FiltersScreen extends StatefulWidget {
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  List<Map<String,dynamic>> filters = [];

  final _queryCtrl = TextEditingController();
  String _source = 'olx';
  final _maxPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await DBProvider.db.getFilters();
    setState(() { filters = f; });
  }

  Future<void> _save() async {
    final q = _queryCtrl.text.trim();
    final mp = int.tryParse(_maxPriceCtrl.text);
    if (q.isEmpty) return;
    await DBProvider.db.saveFilter({'source':_source,'query':q,'maxPrice':mp,'city':''});
    _queryCtrl.clear();
    _maxPriceCtrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filtry (edytowalne)')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _queryCtrl, decoration: InputDecoration(labelText: 'Fraza'))),
              SizedBox(width:8),
              DropdownButton<String>(value: _source, items: ['olx','otomoto'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(), onChanged: (v){ setState(()=>_source=v!); })
            ]),
            TextField(controller: _maxPriceCtrl, decoration: InputDecoration(labelText: 'Max cena (opcjonalnie)'), keyboardType: TextInputType.number),
            SizedBox(height:8),
            ElevatedButton(onPressed: _save, child: Text('Zapisz filtr')),
            SizedBox(height:12),
            Expanded(child: ListView.builder(itemCount: filters.length, itemBuilder: (_, i) {
              final f = filters[i];
              return Card(
                child: ListTile(
                  title: Text('${f['query']} (${f['source']})'),
                  subtitle: Text('max: ${f['maxPrice'] ?? '-'}'),
                  trailing: IconButton(icon: Icon(Icons.delete), onPressed: () async {
                    await DBProvider.db.deleteFilter(f['id']);
                    await _load();
                  }),
                ),
              );
            }))
          ],
        ),
      ),
    );
  }
}
