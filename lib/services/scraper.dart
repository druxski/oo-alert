import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'db_provider.dart';
import 'dart:convert';

int parsePrice(String s) {
  if (s==null) return 0;
  final cleaned = s.replaceAll(RegExp(r'[^0-9,\.]'), '').replaceAll(',', '.');
  try {
    final v = double.parse(cleaned);
    return v.round();
  } catch (e) {
    return 0;
  }
}

Future<List<Map<String,dynamic>>> fetchOlx(String query, {int? maxPrice}) async {
  final url = 'https://www.olx.pl/oferty/q-${Uri.encodeComponent(query)}/';
  final res = await http.get(Uri.parse(url), headers: {'User-Agent':'Mozilla/5.0'});
  final doc = parser.parse(res.body);
  final items = doc.querySelectorAll('div.offer-wrapper, li.offer');
  final out = <Map<String,dynamic>>[];
  for (final el in items.take(30)) {
    final link = el.querySelector('a[href]');
    final priceEl = el.querySelector('.price, .offer-price__number');
    if (link==null || priceEl==null) continue;
    final href = link.attributes['href'] ?? '';
    final id = href.split('/').where((p)=>p.isNotEmpty).last;
    final title = link.text.trim();
    final price = parsePrice(priceEl.text.trim());
    final thumb = el.querySelector('img')?.attributes['data-src'] ?? el.querySelector('img')?.attributes['src'] ?? '';
    out.add({
      'offerId': id,
      'source': 'olx',
      'title': title,
      'url': href,
      'thumbnail': thumb,
      'currentPrice': price,
      'currency': 'PLN',
      'lastSeen': DateTime.now().toIso8601String()
    });
  }
  return out;
}

Future<List<Map<String,dynamic>>> fetchOtomoto(String query, {int? maxPrice}) async {
  final url = 'https://www.otomoto.pl/oferta/${Uri.encodeComponent(query)}';
  final res = await http.get(Uri.parse(url), headers: {'User-Agent':'Mozilla/5.0'});
  final doc = parser.parse(res.body);
  final items = doc.querySelectorAll('article.offer-item');
  final out = <Map<String,dynamic>>[];
  for (final el in items.take(30)) {
    final link = el.querySelector('a[href]');
    final priceEl = el.querySelector('.offer-price__number, .price');
    if (link==null || priceEl==null) continue;
    final href = link.attributes['href'] ?? '';
    final id = href.split('/').where((p)=>p.isNotEmpty).last;
    final title = el.querySelector('.offer-title__link')?.text.trim() ?? link.text.trim();
    final price = parsePrice(priceEl.text.trim());
    final thumb = el.querySelector('img')?.attributes['data-src'] ?? el.querySelector('img')?.attributes['src'] ?? '';
    out.add({
      'offerId': id,
      'source': 'otomoto',
      'title': title,
      'url': href,
      'thumbnail': thumb,
      'currentPrice': price,
      'currency': 'PLN',
      'lastSeen': DateTime.now().toIso8601String()
    });
  }
  return out;
}

// main updater: applies simple upsert and price-history tracking
Future<void> updateFromFilters() async {
  final filters = await DBProvider.db.getFilters();
  final db = DBProvider.db;
  // if no filters saved, provide defaults
  if (filters.isEmpty) {
    // default: popular searches - you can edit in-app
    await db.saveFilter({'source':'olx','query':'samochód','maxPrice':null,'city':''});
    await db.saveFilter({'source':'otomoto','query':'ford','maxPrice':null,'city':''});
  }
  final f = await db.getFilters();
  for (final fil in f) {
    try {
      List<Map<String,dynamic>> offers = [];
      if (fil['source']=='olx') {
        offers = await fetchOlx(fil['query'], maxPrice: fil['maxPrice']);
      } else {
        offers = await fetchOtomoto(fil['query'], maxPrice: fil['maxPrice']);
      }
      for (final o in offers) {
        final id = await db.upsertOffer(o);
        // check last price in history
        final hist = await db.getHistory(o['offerId']);
        final lastPrice = hist.isNotEmpty ? hist.last['price'] as int : null;
        if (lastPrice == null || lastPrice != o['currentPrice']) {
          await db.addPriceHistory(o['offerId'], o['currentPrice'] ?? 0, DateTime.now().toIso8601String());
        }
      }
    } catch (e) {
      print('Error updating filter ${fil['query']}: $e');
    }
  }
}
