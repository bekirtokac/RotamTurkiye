import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Türkiye İl → İlçe haritası
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, List<String>> _turkeyMap = {
  'Adana':          ['Merkez', 'Seyhan', 'Çukurova', 'Karataş', 'Kozan'],
  'Afyonkarahisar': ['Merkez', 'Bolvadin', 'Dinar', 'Sandıklı', 'Sincanlı'],
  'Ankara':         ['Merkez', 'Çamlıdere', 'Çubuk', 'Gölbaşı', 'Güdül', 'Kızılcahamam', 'Nallıhan', 'Polatlı'],
  'Antalya':        ['Merkez', 'Alanya', 'Gazipaşa', 'Kaş', 'Kemer', 'Kumluca', 'Manavgat'],
  'Artvin':         ['Merkez', 'Ardanuç', 'Borçka', 'Hopa', 'Şavşat', 'Yusufeli'],
  'Aydın':          ['Merkez', 'Didim', 'Kuşadası', 'Nazilli', 'Söke'],
  'Balıkesir':      ['Merkez', 'Ayvalık', 'Bandırma', 'Edremit', 'Gönen'],
  'Bolu':           ['Merkez', 'Gerede', 'Mengen', 'Mudurnu', 'Yedigöller'],
  'Bursa':          ['Merkez', 'İnegöl', 'Mudanya', 'Nilüfer', 'Osmangazi', 'Yıldırım'],
  'Çanakkale':      ['Merkez', 'Bayramiç', 'Ezine', 'Gelibolu', 'Lapseki'],
  'Denizli':        ['Merkez', 'Honaz', 'Merkezefendi', 'Pamukkale', 'Tavas'],
  'Eskişehir':      ['Merkez', 'Odunpazarı', 'Sivrihisar', 'Tepebaşı'],
  'Gaziantep':      ['Merkez', 'İslahiye', 'Nizip', 'Şahinbey', 'Şehitkamil'],
  'Hatay':          ['Merkez', 'Antakya', 'Dörtyol', 'İskenderun', 'Kırıkhan'],
  'İstanbul':       ['Merkez', 'Beşiktaş', 'Beyoğlu', 'Çekmeköy', 'Fatih', 'Kadıköy', 'Sarıyer', 'Şişli', 'Şile', 'Üsküdar'],
  'İzmir':          ['Merkez', 'Bergama', 'Çeşme', 'Foça', 'Menemen', 'Selçuk', 'Seferihisar', 'Urla'],
  'Kayseri':        ['Merkez', 'Develi', 'Kocasinan', 'Melikgazi', 'Talas'],
  'Konya':          ['Merkez', 'Beyşehir', 'Ereğli', 'Karatay', 'Meram', 'Selçuklu'],
  'Manisa':         ['Merkez', 'Akhisar', 'Salihli', 'Soma', 'Turgutlu'],
  'Mersin':         ['Merkez', 'Anamur', 'Erdemli', 'Mezitli', 'Silifke', 'Tarsus'],
  'Muğla':          ['Merkez', 'Bodrum', 'Datça', 'Fethiye', 'Köyceğiz', 'Marmaris', 'Milas'],
  'Nevşehir':       ['Merkez', 'Avanos', 'Göreme', 'Hacıbektaş', 'Ürgüp'],
  'Rize':           ['Merkez', 'Ardeşen', 'Çamlıhemşin', 'Fındıklı', 'Pazar'],
  'Sakarya':        ['Merkez', 'Adapazarı', 'Akyazı', 'Hendek', 'Sapanca'],
  'Samsun':         ['Merkez', 'Bafra', 'Çarşamba', 'İlkadım', 'Terme'],
  'Trabzon':        ['Merkez', 'Maçka', 'Of', 'Sürmene', 'Vakfıkebir'],
  'Yalova':         ['Merkez', 'Armutlu', 'Çınarcık', 'Çiftlikköy', 'Termal'],
};

// ─────────────────────────────────────────────────────────────────────────────
// Konaklama türü tanımları
// ─────────────────────────────────────────────────────────────────────────────
class _StayType {
  final String label;
  final String value;
  final IconData icon;
  const _StayType(this.label, this.value, this.icon);
}

const List<_StayType> _stayTypes = [
  _StayType('Tümü',    'tümü',    Icons.layers_rounded),
  _StayType('Çadır',   'çadır',   Icons.holiday_village_rounded),
  _StayType('Karavan', 'karavan', Icons.rv_hookup_rounded),
  _StayType('Otel',    'otel',    Icons.hotel_rounded),
];

// ─────────────────────────────────────────────────────────────────────────────
// Firestore döküman modeli
// ─────────────────────────────────────────────────────────────────────────────
class _Campsite {
  final String id, name, city, district, type, description;
  const _Campsite({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.type,
    required this.description,
  });

  factory _Campsite.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    String s(String k, String fb) {
      final v = d[k]?.toString().trim() ?? '';
      return v.isEmpty ? fb : v;
    }
    return _Campsite(
      id:          doc.id,
      name:        s('name',        'Konaklama Alanı'),
      city:        s('city',        ''),
      district:    s('district',    ''),
      type:        s('type',        'çadır'),
      description: s('description', ''),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class WhereToStayPage extends StatefulWidget {
  const WhereToStayPage({super.key});

  @override
  State<WhereToStayPage> createState() => _WhereToStayPageState();
}

class _WhereToStayPageState extends State<WhereToStayPage> {
  // ── Tema ──────────────────────────────────────────────────────────────────
  static const Color _bg      = Color(0xFF0A0D14);
  static const Color _surface = Color(0xFF141820);
  static const Color _border  = Color(0xFF252D3A);
  static const Color _accent  = Color(0xFFE65F2B);
  static const Color _accent2 = Color(0xFFB33E15);

  // ── Filtre State ──────────────────────────────────────────────────────────
  String? _selectedCity;
  String? _selectedDistrict;
  int     _selectedTypeIdx = 0;

  List<String> get _districtOptions =>
      _selectedCity == null ? [] : (_turkeyMap[_selectedCity] ?? []);

  // ── Firestore ─────────────────────────────────────────────────────────────
  final _db = FirebaseFirestore.instance;

  Query<Map<String, dynamic>> get _query {
    Query<Map<String, dynamic>> q = _db.collection('campsites');
    if (_selectedCity != null) {
      q = q.where('city', isEqualTo: _selectedCity);
    }
    if (_selectedDistrict != null) {
      q = q.where('district', isEqualTo: _selectedDistrict);
    }
    final typeVal = _stayTypes[_selectedTypeIdx].value;
    if (typeVal != 'tümü') {
      q = q.where('type', isEqualTo: typeVal);
    }
    return q;
  }

  // ── Filtre aksiyonları ────────────────────────────────────────────────────
  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity     = city;
      _selectedDistrict = null;
    });
  }

  void _onTypeChanged(int idx) {
    if (_selectedTypeIdx == idx) return;
    setState(() => _selectedTypeIdx = idx);
  }

  // ── Renk / ikon yardımcıları ──────────────────────────────────────────────
  Color _typeColor(String t) {
    switch (t.toLowerCase()) {
      case 'karavan': return const Color(0xFF4FC3F7);
      case 'otel':    return const Color(0xFFFFD54F);
      default:        return _accent;
    }
  }

  IconData _typeIcon(String t) {
    switch (t.toLowerCase()) {
      case 'karavan': return Icons.rv_hookup_rounded;
      case 'otel':    return Icons.hotel_rounded;
      default:        return Icons.holiday_village_rounded;
    }
  }

  String _typeLabel(String t) {
    switch (t.toLowerCase()) {
      case 'karavan': return 'Karavan';
      case 'otel':    return 'Otel';
      default:        return 'Çadır';
    }
  }

  // ── Seed: Koleksiyon boşsa 15 örnek kayıt ────────────────────────────────
  Future<void> _seedIfEmpty() async {
    final snap = await _db.collection('campsites').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    const rows = <Map<String, String>>[
      {'name':'Bolu Yedigöller Kamp',      'city':'Bolu',     'district':'Yedigöller',   'type':'çadır',   'description':'Yedi göllerin büyüleyici doğasında kayın ormanlarının gölgesinde çadır kampı.'},
      {'name':'Fethiye Kabak Koyu',         'city':'Muğla',    'district':'Fethiye',      'type':'çadır',   'description':'Kelebekler Vadisi yakınında turkuaz sulara açılan bakir bir koydaki kamp.'},
      {'name':'Antalya Olimpos Kamp',       'city':'Antalya',  'district':'Kumluca',      'type':'çadır',   'description':'Tarihi kalıntılar ve narenciye bahçelerinin arasında çadır kurma imkânı.'},
      {'name':'Rize Ayder Yaylası Kampı',   'city':'Rize',     'district':'Çamlıhemşin',  'type':'çadır',   'description':'Kaçkar Dağları\'nın eteklerinde yemyeşil çayırlar ve kaplıcalar eşliğinde yayla kampı.'},
      {'name':'Kapadokya Kızılçukur',       'city':'Nevşehir', 'district':'Göreme',       'type':'çadır',   'description':'Peri bacalarının eşsiz siluetini izleyebileceğiniz sıradışı kamp yeri.'},
      {'name':'Artvin Karagöl Kamp',        'city':'Artvin',   'district':'Şavşat',       'type':'çadır',   'description':'Kristal berraklığındaki Karagöl kıyısında doğayla baş başa çadır kampı.'},
      {'name':'Muğla Bozburun Kamp',        'city':'Muğla',    'district':'Marmaris',     'type':'çadır',   'description':'Marmaris yakınında Akdeniz\'in masmavi sularına nazır zeytinlikler arasında kamp.'},
      {'name':'Çeşme Karavan Park',         'city':'İzmir',    'district':'Çeşme',        'type':'karavan', 'description':'Çeşme\'nin kristal koylarına yürüme mesafesinde tam donanımlı karavan parkı.'},
      {'name':'Kemer Karavan Alanı',        'city':'Antalya',  'district':'Kemer',        'type':'karavan', 'description':'Akdeniz kıyısında Toros dağlarının gölgesinde elektrik-su bağlantılı karavan yeri.'},
      {'name':'Sapanca Karavan Parkı',      'city':'Sakarya',  'district':'Sapanca',      'type':'karavan', 'description':'Sapanca Gölü kıyısında huzurlu tesisli karavan durağı.'},
      {'name':'Bodrum Karavan & Kamp',      'city':'Muğla',    'district':'Bodrum',       'type':'karavan', 'description':'Ege koylarının dibinde denize sıfır full-hookup karavan alanı.'},
      {'name':'İstanbul Tarihi Yarımada',   'city':'İstanbul', 'district':'Fatih',        'type':'otel',    'description':'Sultanahmet Meydanı\'na 3 dk mesafede tarihi konak dönüşümü butik otel.'},
      {'name':'Cappadocia Cave Resort',     'city':'Nevşehir', 'district':'Ürgüp',        'type':'otel',    'description':'Göreme\'nin kalbinde peri bacalarına oyulmuş mağara odaları ve panoramik teras.'},
      {'name':'Ölüdeniz Lykia World',       'city':'Muğla',    'district':'Fethiye',      'type':'otel',    'description':'Ölüdeniz Mavi Lagün\'e bakışlı tamamen doğal ahşap mimarili butik tatil köyü.'},
      {'name':'Trabzon Sümela Orman Oteli', 'city':'Trabzon',  'district':'Maçka',        'type':'otel',    'description':'Sümela Manastırı\'na giden yol üzerinde sarp kayalıklar arasında butik doğa oteli.'},
    ];

    final batch = _db.batch();
    for (final row in rows) {
      batch.set(_db.collection('campsites').doc(), row);
    }
    await batch.commit();
    debugPrint('_seedIfEmpty: 15 kayıt yazıldı.');
  }

  /// 29 test kaydını sabit slug-ID'li dokümanlar olarak yazar.
  /// set() idem-potent: aynı ID'ye tekrar çağrılırsa üzerine yazar, çift kayıt oluşmaz.
  Future<void> _seedTestData() async {
    final col = _db.collection('campsites');

    final testDocs = <String, Map<String, String>>{
      'bolu-mengen-purenli-cadir': {
        'name':        'Pürenli Yaylası Kamp Alanı',
        'city':        'Bolu',
        'district':    'Mengen',
        'type':        'çadır',
        'description': 'Doğanın kalbinde, çam kokuları arasında çadır kampı deneyimi.',
      },
      'bolu-merkez-yedigollerkaravan': {
        'name':        'Yedigöller Karavan Parkı',
        'city':        'Bolu',
        'district':    'Merkez',
        'type':        'karavan',
        'description': 'Göl kenarında, karavanlar için ayrılmış yasal ve huzurlu düzlük.',
      },
      'bolu-gerede-abant-otel': {
        'name':        'Abant Dağ Köşkü Oteli',
        'city':        'Bolu',
        'district':    'Gerede',
        'type':        'otel',
        'description': 'Şömineli, konforlu ve doğa manzaralı butik dağ konaklaması.',
      },
      'antalya-kas-olympos-cadir': {
        'name':        'Olympos Çamlık Çadır Kampı',
        'city':        'Antalya',
        'district':    'Kaş',
        'type':        'çadır',
        'description': 'Antik kente ve denize yürüme mesafesinde, portakal ağaçları altında çadır alanı.',
      },
      'antalya-gazipasa-sahil-karavan': {
        'name':        'Gazipaşa Sahil Karavan Alanı',
        'city':        'Antalya',
        'district':    'Gazipaşa',
        'type':        'karavan',
        'description': 'Belediye güvencesinde, denize sıfır yasal ve ücretsiz karavan parkı.',
      },
      'antalya-merkez-kas-marina-otel': {
        'name':        'Kaş Marina Butik Otel',
        'city':        'Antalya',
        'district':    'Merkez',
        'type':        'otel',
        'description': 'Deniz manzaralı, havuzlu ve konforlu Akdeniz mimarisi.',
      },
      // ── Afyonkarahisar ────────────────────────────────────────────────────
      'afyon-merkez-frig-cadir': {
        'name':        'Frig Vadisi Çadır Kamp Alanı',
        'city':        'Afyonkarahisar',
        'district':    'Merkez',
        'type':        'çadır',
        'description': 'Tarihi kaya mezarlarının gölgesinde, mistik bir kamp deneyimi.',
      },
      'afyon-merkez-belediye-karavan': {
        'name':        'Afyon Belediyesi Ücretsiz Karavan Parkı',
        'city':        'Afyonkarahisar',
        'district':    'Merkez',
        'type':        'karavan',
        'description': 'Elektrik, su ve sosyal imkânları olan Türkiye\'nin en modern ücretsiz karavan alanı.',
      },
      'afyon-merkez-ng-termal-otel': {
        'name':        'Ng Afyon Termal Otel',
        'city':        'Afyonkarahisar',
        'district':    'Merkez',
        'type':        'otel',
        'description': 'Günün yorgunluğunu atabileceğiniz şifalı termal havuzlar ve lüks konaklama.',
      },
      // ── Ankara ────────────────────────────────────────────────────────────
      'ankara-kizilcahamam-isik-dagi-karagol-kamp-alani': {
        'name':        'Işık Dağı Karagöl Kamp Alanı',
        'city':        'Ankara',
        'district':    'Kızılcahamam',
        'type':        'çadır',
        'description': 'Yüksek rakımda, çam ormanları arasında göl manzaralı çadır kampı.',
      },
      'ankara-gudul-sorgun-goleti-karavan-parki': {
        'name':        'Sorgun Göleti Karavan Parkı',
        'city':        'Ankara',
        'district':    'Güdül',
        'type':        'karavan',
        'description': 'Geniş düzlükleri ve doğasıyla karavanların rahatça konuşlanabileceği huzurlu alan.',
      },
      'ankara-kizilcahamam-soguksu-termal-otel': {
        'name':        'Soğuksu Termal Otel',
        'city':        'Ankara',
        'district':    'Kızılcahamam',
        'type':        'otel',
        'description': 'Milli parkın yanı başında, şifalı termal sularla konforlu konaklama.',
      },
      'ankara-camlidere-camkoru-tabiat-parki-kampi': {
        'name':        'Çamkoru Tabiat Parkı Kampı',
        'city':        'Ankara',
        'district':    'Çamlıdere',
        'type':        'çadır',
        'description': 'Gözlerden uzak, sessiz ve doğayla baş başa kalabileceğiniz çadır noktası.',
      },
      'ankara-golbasi-mogan-golu-karavan-alani': {
        'name':        'Mogan Gölü Karavan Alanı',
        'city':        'Ankara',
        'district':    'Gölbaşı',
        'type':        'karavan',
        'description': 'Şehre yakın, göl kıyısında haftasonu kaçamakları için ideal karavan alanı.',
      },
      // ── İstanbul ──────────────────────────────────────────────────────────
      'istanbul-sile-sahilkoy-cadir-kamp-alani': {
        'name':        'Sahilköy Çadır Kamp Alanı',
        'city':        'İstanbul',
        'district':    'Şile',
        'type':        'çadır',
        'description': 'Karadeniz dalgalarının sesinde, çam ağaçları altında çadır keyfi.',
      },
      'istanbul-sariyer-kilyos-karavan-parki': {
        'name':        'Kilyos Karavan Parkı',
        'city':        'İstanbul',
        'district':    'Sarıyer',
        'type':        'karavan',
        'description': 'İstanbul\'un kuzeyinde, denize yakın geniş karavan park sahası.',
      },
      'istanbul-sile-agva-beyaz-ev-butik-otel': {
        'name':        'Ağva Beyaz Ev Butik Otel',
        'city':        'İstanbul',
        'district':    'Şile',
        'type':        'otel',
        'description': 'Nehir kenarında, romantik ve izole bir hafta sonu tatili konaklaması.',
      },
      'istanbul-cekmekoy-omerli-baraji-vahsi-kamp-alani': {
        'name':        'Ömerli Barajı Vahşi Kamp Alanı',
        'city':        'İstanbul',
        'district':    'Çekmeköy',
        'type':        'çadır',
        'description': 'Göl manzaralı, tamamen doğanın içinde macera arayan çadırcılar için.',
      },
      'istanbul-sariyer-belgrad-ormani-karavan-duzlugu': {
        'name':        'Belgrad Ormanı Karavan Düzlüğü',
        'city':        'İstanbul',
        'district':    'Sarıyer',
        'type':        'karavan',
        'description': 'Şehrin akciğerlerinde, doğayla iç içe yasal karavan mola noktası.',
      },
      // ── Yalova ────────────────────────────────────────────────────────────
      'yalova-cinarcik-dipsiz-gol-cadir-kampi': {
        'name':        'Dipsiz Göl Çadır Kampı',
        'city':        'Yalova',
        'district':    'Çınarcık',
        'type':        'çadır',
        'description': 'Erikli Yaylası üzerinde, gizemli ve sık ormanlık içinde çadır alanı.',
      },
      'yalova-cinarcik-delmece-yaylasi-karavan-parki': {
        'name':        'Delmece Yaylası Karavan Parkı',
        'city':        'Yalova',
        'district':    'Çınarcık',
        'type':        'karavan',
        'description': 'Geniş ve pürüzsüz düzlüğüyle karavan kulüplerinin gözde yayla rotası.',
      },
      'yalova-termal-limak-thermal-boutique-hotel': {
        'name':        'Termal Limak Thermal Boutique Hotel',
        'city':        'Yalova',
        'district':    'Termal',
        'type':        'otel',
        'description': 'Tarihi dokusu, yemyeşil doğası ve lüks termal spa imkanları.',
      },
      'yalova-cinarcik-erikli-selalesi-kamp-alani': {
        'name':        'Erikli Şelalesi Kamp Alanı',
        'city':        'Yalova',
        'district':    'Çınarcık',
        'type':        'çadır',
        'description': 'Şelale şırıltısı eşliğinde, trekking ve çadır kampı için muazzam rota.',
      },
      'yalova-armutlu-armutlu-sahil-karavan-noktasi': {
        'name':        'Armutlu Sahil Karavan Noktası',
        'city':        'Yalova',
        'district':    'Armutlu',
        'type':        'karavan',
        'description': 'Deniz kıyısında, gün batımını karavanın camından izleyebileceğiniz düzlük.',
      },
      // ── İzmir ─────────────────────────────────────────────────────────────
      'izmir-cesme-delikli-koy-cadir-kampi': {
        'name':        'Delikli Koy Çadır Kampı',
        'city':        'İzmir',
        'district':    'Çeşme',
        'type':        'çadır',
        'description': 'Beyaz kayalıklar ve turkuaz denizin birleştiği, efsaneleşmiş ücretsiz çadır koyu.',
      },
      'izmir-foca-foca-karavan-camping': {
        'name':        'Foça Karavan Camping',
        'city':        'İzmir',
        'district':    'Foça',
        'type':        'karavan',
        'description': 'Eski Foça yakınlarında, zeytin ağaçları altında güvenli karavan parkı.',
      },
      'izmir-cesme-alacati-tas-otel': {
        'name':        'Alaçatı Taş Otel',
        'city':        'İzmir',
        'district':    'Çeşme',
        'type':        'otel',
        'description': 'Arnavut kaldırımlı sokaklarda, otantik Ege mimarisine sahip premium taş konaklama.',
      },
      'izmir-menemen-karagol-tabiat-parki-kampi': {
        'name':        'Karagöl Tabiat Parkı Kampı',
        'city':        'İzmir',
        'district':    'Menemen',
        'type':        'çadır',
        'description': 'Yamanlar Dağı\'nda, göl yansıması eşliğinde serin bir çadır kampı deneyimi.',
      },
      'izmir-urla-urla-demircili-sahil-karavan-alani': {
        'name':        'Urla Demircili Sahil Karavan Alanı',
        'city':        'İzmir',
        'district':    'Urla',
        'type':        'karavan',
        'description': 'Urla\'nın temiz koylarında, sakinlik arayan karavancılar için yasal kıyı.',
      },
    };

    final batch = _db.batch();
    testDocs.forEach((id, data) {
      // merge: false → her zaman tam üzerine yazar (alan artıklarını temizler)
      batch.set(col.doc(id), data, SetOptions(merge: false));
    });
    await batch.commit();
    debugPrint('✅ ${testDocs.length} test kaydı Firestore\'a başarıyla yazıldı.');
  }

  // ── Dropdown InputDecoration şablonu ─────────────────────────────────────
  InputDecoration _dropdownDecoration({
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: enabled ? Colors.white38 : Colors.white12,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon,
          size: 18, color: enabled ? Colors.white38 : Colors.white12),
      filled: true,
      fillColor: enabled ? _surface : _surface.withValues(alpha: 0.5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _border.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
  }

  // ── Widget: Filtre Paneli ─────────────────────────────────────────────────
  Widget _buildFilters() {
    final sortedCities = _turkeyMap.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E121A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık satırı ─────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, size: 14, color: _accent),
              ),
              const SizedBox(width: 8),
              const Text(
                'Filtrele',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_selectedCity != null ||
                  _selectedDistrict != null ||
                  _selectedTypeIdx != 0)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCity     = null;
                    _selectedDistrict = null;
                    _selectedTypeIdx  = 0;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 12, color: Colors.white38),
                        SizedBox(width: 4),
                        Text('Sıfırla',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Dropdown Satırı: İl + İlçe ───────────────────────────────
          Row(
            children: [
              // İl
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedCity,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF161C26),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38, size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dropdownDecoration(
                    hint: 'İl seçin',
                    icon: Icons.location_city_rounded,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tüm İller',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    ...sortedCities.map(
                      (city) => DropdownMenuItem<String?>(
                        value: city,
                        child: Text(city,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                  onChanged: _onCityChanged,
                ),
              ),
              const SizedBox(width: 10),

              // İlçe
              Expanded(
                child: IgnorePointer(
                  ignoring: _selectedCity == null,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedDistrict,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF161C26),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _selectedCity == null
                          ? Colors.white12
                          : Colors.white38,
                      size: 18,
                    ),
                    style: TextStyle(
                      color: _selectedCity == null
                          ? Colors.white24
                          : Colors.white,
                      fontSize: 13,
                    ),
                    decoration: _dropdownDecoration(
                      hint: 'İlçe seçin',
                      icon: Icons.near_me_rounded,
                      enabled: _selectedCity != null,
                    ),
                    items: _selectedCity == null
                        ? []
                        : [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tüm İlçeler',
                                  style:
                                      TextStyle(color: Colors.white54)),
                            ),
                            ..._districtOptions.map(
                              (d) => DropdownMenuItem<String?>(
                                value: d,
                                child: Text(d,
                                    style: const TextStyle(
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                    onChanged: _selectedCity == null
                        ? null
                        : (v) => setState(() => _selectedDistrict = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Tür Chip'leri ─────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _stayTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t      = _stayTypes[i];
                final isSel  = _selectedTypeIdx == i;
                return GestureDetector(
                  onTap: () => _onTypeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: isSel
                          ? const LinearGradient(
                              colors: [_accent, _accent2],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: isSel ? null : _surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel
                            ? _accent
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon,
                            size: 13,
                            color: isSel ? Colors.white : Colors.white38),
                        const SizedBox(width: 5),
                        Text(
                          t.label,
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white38,
                            fontSize: 12.5,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Konaklama Kartı ───────────────────────────────────────────────
  Widget _buildCard(_Campsite item) {
    final Color    tc    = _typeColor(item.type);
    final IconData tIcon = _typeIcon(item.type);
    final String   tLbl  = _typeLabel(item.type);
    final String   loc   = [item.city, item.district]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: tc.withValues(alpha: 0.07),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: tc.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: tc.withValues(alpha: 0.22)),
                      ),
                      child: Icon(tIcon, color: tc, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          if (loc.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 11, color: Colors.white30),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    loc,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: tc.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: tc.withValues(alpha: 0.28)),
                      ),
                      child: Text(
                        tLbl,
                        style: TextStyle(
                          color: tc,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Açıklama
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 11),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12.5,
                      height: 1.55,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget: Boş Durum ─────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: const Text('🗺️', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 22),
            const Text(
              'Konaklama noktası bulunamadı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Bu bölgede kriterlerinize uygun\nkonaklama alanı bulunamadı 🗺️\n\nFarklı bir il, ilçe veya tür seçin.',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget: StreamBuilder Liste ───────────────────────────────────────────
  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _accent, strokeWidth: 3),
                SizedBox(height: 14),
                Text('Konaklama alanları yükleniyor...',
                    style: TextStyle(color: Colors.white30, fontSize: 12)),
              ],
            ),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              'Hata: ${snap.error}',
              style:
                  const TextStyle(color: Colors.white30, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          );
        }

        final items = (snap.data?.docs ?? [])
            .map((d) => _Campsite.fromDoc(d))
            .toList();

        if (items.isEmpty) return _buildEmpty();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 14, bottom: 28),
          itemCount: items.length,
          itemBuilder: (_, i) => _buildCard(items[i]),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nerede Kalınır?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: FutureBuilder<void>(
        // _seedIfEmpty: koleksiyon boşsa 15 örnek yazar
        // _seedTestData: 9 test kaydını sabit ID ile idem-potent yazar
        future: _seedIfEmpty().then((_) => _seedTestData()),
        builder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filtre Paneli ─────────────────────────────────────────
            _buildFilters(),
            const SizedBox(height: 6),

            // ── Sonuç Sayacı ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _query.snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final count = snap.data!.docs.length;
                  return Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        count == 0
                            ? 'Sonuç bulunamadı'
                            : '$count konaklama alanı bulundu',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 4),

            // ── Liste ─────────────────────────────────────────────────
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }
}
