import 'package:flutter/material.dart';
import '../services/db_provider.dart';
import '../services/scraper.dart';
import '../models/offer.dart';
import 'offer_detail_screen.dart';
import 'filters_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String,dynamic>> offers = [];
  Timer? _timer;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadLocal();
    _refreshNow();
    _timer = Timer.periodic(Duration(seconds: 60), (_) => _refreshNow());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    final list = await DBProvider.db.getOffers();
    setState(() { offers = list; });
  }

  Future<void> _refreshNow() async {
    setState(() { loading = true; });
    await updateFromFilters();
    await _loadLocal();
    setState(() { loading = false; });
  }

  Widget _buildTile(Map<String,dynamic> m) {
    final price = (m['currentPrice'] ?? 0);
    return Card(
      color: Color(0xFF111827),
      margin: EdgeInsets.symmetric(horizontal:12, vertical:6),
      child: ListTile(
        leading: (m['thumbnail'] ?? '')=='' ? Icon(Icons.image, size:40) : Image.network(m['thumbnail'], width:60, fit:BoxFit.cover),
        title: Text(m['title'] ?? '', maxLines:1, overflow: TextOverflow.ellipsis),
        subtitle: Text(m['source'] ?? '', style: TextStyle(fontSize:12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${price} zł', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
            SizedBox(height:4),
            Icon(Icons.chevron_right)
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offerMap: m)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OLX + Otomoto — Najnowsze'),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => FiltersScreen()));
            await _refreshNow();
          }),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshNow)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNow,
        child: loading ? Center(child: CircularProgressIndicator()) :
        ListView.builder(
          itemCount: offers.length,
          itemBuilder: (_, i) => _buildTile(offers[i]),
        ),
      ),
    );
  }
}
