// ignore_for_file: avoid_print
// mock_data_service.dart
//
// TEST AMAÇLI — Firestore 'posts' koleksiyonuna zengin sahte gönderi
// ekleyerek Arama (SearchPage) ve Feed (PostPage) testlerini kolaylaştırır.
//
// ⚠️  Yalnızca geliştirme / QA sürecinde kullanılır.
//     Ürün sürümüne dahil etmeyin veya SharedPreferences flag'i ile
//     bir kez çalışacak şekilde koruyun (bkz. PostPage entegrasyonu).

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataService {
  MockDataService._();

  static final _db = FirebaseFirestore.instance;
  static final _rng = Random();

  // ── Sahte Yazarlar ────────────────────────────────────────────────────────
  static const _authors = [
    {'userId': 'mock_u1', 'userName': 'Ahmet Yılmaz', 'userPhotoUrl': ''},
    {'userId': 'mock_u2', 'userName': 'Zeynep Kaya', 'userPhotoUrl': ''},
    {'userId': 'mock_u3', 'userName': 'Lokal Gezgin', 'userPhotoUrl': ''},
    {'userId': 'mock_u4', 'userName': 'Meral Demir', 'userPhotoUrl': ''},
    {'userId': 'mock_u5', 'userName': 'Burak Şahin', 'userPhotoUrl': ''},
  ];

  // ── Sahte Post İçerikleri ─────────────────────────────────────────────────
  static const _posts = [
    // İstanbul
    {
      'location': 'İstanbul',
      'description':
          'Boğaz\'da tekne turu yaparken İstanbul silueti inanılmaz güzeldi! 🌉',
      'imageId': 10,
    },
    {
      'location': 'İstanbul, Kapalıçarşı',
      'description':
          'Kapalıçarşı\'nın dar sokaklarında kaybolmak başlı başına bir macera 🛍️',
      'imageId': 11,
    },
    {
      'location': 'İstanbul, Sultanahmet',
      'description':
          'Ayasofya\'nın karşısında gün batımı izlemek tüm yorgunluğumu aldı 🕌',
      'imageId': 12,
    },
    // İzmir
    {
      'location': 'İzmir',
      'description':
          'İzmir Kordon\'da kahvemi yudumlarken ege rüzgarı yüzüme çarptı ☕🌊',
      'imageId': 20,
    },
    {
      'location': 'İzmir, Alaçatı',
      'description':
          'Alaçatı\'nın taş sokakları ve bougainvillea çiçekleri muhteşem! 🌺',
      'imageId': 21,
    },
    {
      'location': 'İzmir, Çeşme',
      'description':
          'Çeşme koylarında kristal berraklığında deniz, masmavi cennet 🏖️',
      'imageId': 22,
    },
    // Antalya
    {
      'location': 'Antalya',
      'description':
          'Antalya Kaleiçi\'nde Roma limanını seyrederek akşam yemeği yedik 🏛️',
      'imageId': 30,
    },
    {
      'location': 'Antalya, Kaş',
      'description':
          'Kaş\'ta dalgıçlık yaparak antik su altı kentini gördüm, inanılmaz! 🤿',
      'imageId': 31,
    },
    {
      'location': 'Antalya, Kemer',
      'description':
          'Kemer\'in saklı koyu: ormanlık patikadan denize inerek yüzdük 🌲🌊',
      'imageId': 32,
    },
    // Muğla
    {
      'location': 'Muğla, Fethiye',
      'description':
          'Ölüdeniz\'de yamaç paraşütü yaptım; gökyüzünden türkuaz lagün görüntüsü büyüledi! 🪂',
      'imageId': 40,
    },
    {
      'location': 'Muğla, Bodrum',
      'description':
          'Bodrum\'da gece yüzüp sonra sahil kafede yıldızları izledik ⭐🌊',
      'imageId': 41,
    },
    {
      'location': 'Muğla, Marmaris',
      'description':
          'Marmaris Datça yarımadasında zeytin bahçelerinde ATV turu harikaydı 🫒🏍️',
      'imageId': 42,
    },
    // Nevşehir
    {
      'location': 'Nevşehir, Kapadokya',
      'description':
          'Kapadokya\'da gün doğumu balon turu hayatımın en unutulmaz deneyimi! 🎈☀️',
      'imageId': 50,
    },
    {
      'location': 'Nevşehir, Ürgüp',
      'description':
          'Ürgüp\'te kaya evde bir gece konakladım; peri bacaları tam önümde 🗿🌙',
      'imageId': 51,
    },
    // Rize
    {
      'location': 'Rize',
      'description':
          'Rize çay bahçelerinde taze çay içmek ruhumu tazeledi; yeşilin bin tonu burada! 🍃☕',
      'imageId': 60,
    },
    {
      'location': 'Rize, Ayder Yaylası',
      'description':
          'Ayder yaylasında sisle örtülü dağlar arasında doğa yürüyüşü büyüleyiciydi ⛰️🌫️',
      'imageId': 61,
    },
    // Trabzon
    {
      'location': 'Trabzon',
      'description':
          'Trabzon\'da Sümela Manastırı\'na çıkarken bulutların içine girdim, mistik his 🏔️',
      'imageId': 70,
    },
    {
      'location': 'Trabzon, Uzungöl',
      'description':
          'Uzungöl\'ün sakin sularına sabah erken gelince bambaşka bir dünyadaydım 🦆🌅',
      'imageId': 71,
    },
    // Eskişehir
    {
      'location': 'Eskişehir',
      'description':
          'Eskişehir Porsuk nehri kıyısında gondol turu yaptım, Venedik gibi! 🛶',
      'imageId': 80,
    },
    {
      'location': 'Eskişehir, Odunpazarı',
      'description':
          'Odunpazarı\'nın renkli tarihi evleri her köşesinde fotoğraf pozu veriyor 📸🏘️',
      'imageId': 81,
    },
    // Çanakkale
    {
      'location': 'Çanakkale',
      'description':
          'Troya antik kentinde Truva atının önünde durup tarihe dokunduk 🐴🏛️',
      'imageId': 90,
    },
    {
      'location': 'Çanakkale, Gelibolu',
      'description':
          'Gelibolu\'da Şehitler Anıtı\'nı ziyaret ettim; derin bir saygı ve hüzün... 🕊️',
      'imageId': 91,
    },
    // Bonus — popüler destinasyonlar
    {
      'location': 'Konya',
      'description':
          'Konya Mevlana Müzesi\'nde sema törenine katılmak ruhani bir deneyimdi 🌀',
      'imageId': 100,
    },
    {
      'location': 'Bursa, Uludağ',
      'description':
          'Uludağ\'da kar altında kayak yaparken 2200 metre zirveden Bursa\'yı gördüm ⛷️❄️',
      'imageId': 101,
    },
    {
      'location': 'Safranbolu',
      'description':
          'Safranbolu\'nun UNESCO miras konaklarında geceledim; zaman durmuş gibi 🏡✨',
      'imageId': 102,
    },
  ];

  /// Firestore 'posts' koleksiyonuna [_posts] listesindeki tüm sahte
  /// dokümanları ekler. Her çağrıda yeni dokümanlar eklenir (idempotent değil).
  ///
  /// Dönüş değeri: eklenen doküman sayısı.
  static Future<int> createMockPosts() async {
    final batch = _db.batch();
    int count = 0;

    for (final post in _posts) {
      final author = _authors[_rng.nextInt(_authors.length)];
      final imageId = (post['imageId'] as int) + _rng.nextInt(5);
      final daysAgo = _rng.nextInt(90); // Son 90 gün içinde rastgele tarih

      final ref = _db.collection('posts').doc();
      batch.set(ref, {
        // İçerik
        'description': post['description'],
        'location': post['location'],
        // Görsel — her post biraz farklı bir picsum resmi alır
        'postImageUrl':
            'https://picsum.photos/id/$imageId/600/400',
        'isLocalImage': false,
        // Etkileşim
        'likeCount': 10 + _rng.nextInt(491), // 10–500
        'commentCount': _rng.nextInt(50),
        // Yazar
        'userId': author['userId'],
        'userName': author['userName'],
        'userPhotoUrl': author['userPhotoUrl'],
        // Zaman damgası — geçmişe yayılmış sıralama testi için
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(
            days: daysAgo,
            hours: _rng.nextInt(24),
            minutes: _rng.nextInt(60),
          )),
        ),
        // İşaretleyici — bu postların mock olduğunu belirtir (ileride temizlemek için)
        'isMock': true,
      });
      count++;
    }

    await batch.commit();
    print('✅ MockDataService: $count sahte post Firestore\'a eklendi.');
    return count;
  }

  /// Firestore'daki tüm mock postları temizler (isMock == true olanlar).
  /// Gerektiğinde çağrılabilir.
  static Future<int> deleteMockPosts() async {
    final snap = await _db
        .collection('posts')
        .where('isMock', isEqualTo: true)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    print('🗑️  MockDataService: ${snap.docs.length} mock post silindi.');
    return snap.docs.length;
  }
}
