import 'package:flutter/material.dart';
import '../services/db_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class OfferDetailScreen extends StatefulWidget {
  final Map<String,dynamic> offerMap;
  OfferDetailScreen({required this.offerMap});
  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  List<Map<String,dynamic>> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final h = await DBProvider.db.getHistory(widget.offerMap['offerId']);
    setState(() { history = h; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.offerMap['title'] ?? '';
    final price = widget.offerMap['currentPrice'] ?? 0;
    final thumb = widget.offerMap['thumbnail'] ?? '';
    final spots = <FlSpot>[];
    for (int i=0;i<history.length;i++) {
      spots.add(FlSpot(i.toDouble(), (history[i]['price'] ?? 0).toDouble()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            if (thumb!='') Image.network(thumb, height:140, fit:BoxFit.cover),
            SizedBox(height:8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${price} zł', style: TextStyle(fontSize:20, color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () async {
                  final url = widget.offerMap['url'];
                  if (await canLaunch(url)) await launch(url);
                }, child: Text('Otwórz'))
              ],
            ),
            SizedBox(height:12),
            SizedBox(height:200, child: history.isEmpty ? Center(child: Text('Brak historii')) : LineChart(
              LineChartData(lineBarsData: [LineChartBarData(spots: spots, isCurved: true, dotData: FlDotData(show: true))],
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true, bottomTitles: SideTitles(showTitles: true))),
            )),
            SizedBox(height:12),
            Expanded(child: loading ? Center(child:CircularProgressIndicator()) : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[history.length - 1 - i];
                return ListTile(
                  title: Text('${h['price']} zł'),
                  subtitle: Text('${h['ts']}'),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
