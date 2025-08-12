class Offer {
  int? id; // local DB id
  String offerId; // source-specific id
  String source; // 'olx' or 'otomoto'
  String title;
  String url;
  String thumbnail;
  int? currentPrice;
  String currency;
  String lastSeen; // ISO string
  Offer({
    this.id,
    required this.offerId,
    required this.source,
    required this.title,
    required this.url,
    required this.thumbnail,
    this.currentPrice,
    this.currency='PLN',
    this.lastSeen='',
  });

  factory Offer.fromMap(Map<String, dynamic> m) => Offer(
    id: m['id'],
    offerId: m['offerId'],
    source: m['source'],
    title: m['title'],
    url: m['url'],
    thumbnail: m['thumbnail'] ?? '',
    currentPrice: m['currentPrice'],
    currency: m['currency'] ?? 'PLN',
    lastSeen: m['lastSeen'] ?? '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offerId': offerId,
      'source': source,
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'currentPrice': currentPrice,
      'currency': currency,
      'lastSeen': lastSeen,
    };
  }
}
