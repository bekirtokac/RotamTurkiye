import 'package:flutter/material.dart';

class EvliyaCelebiPage extends StatefulWidget {
  const EvliyaCelebiPage({super.key});

  @override
  State<EvliyaCelebiPage> createState() => _EvliyaCelebiPageState();
}

class _EvliyaCelebiPageState extends State<EvliyaCelebiPage> {
  String selectedCity = "İstanbul";

  // ── Evliya Çelebi Orijinal Seyahatname Notları Modeli ────────────────────────
  static const Map<String, List<Map<String, String>>> _seyahatnameNotes = {
    'İstanbul': [
      {
        'title': '🌍 Şehrin Tılsımları',
        'content': 'Yanko bin Madyan\'ın horoz tılsımı ve şehrin diğer büyük tılsımları hanedanlar boyu asırlarca bu ulu şehri kazalardan korumuştur...',
        'icon': 'history_edu',
      },
      {
        'title': '🕌 Ayasofya-i Kebir',
        'content': 'Kubbelerin azameti ve göklere uzanan direkleriyle dünya gözünün görmediği muazzam yapı, alemin en görkemli mabedidir...',
        'icon': 'castle',
      },
      {
        'title': '⚓ İslâmbol Limanı',
        'content': 'Yedi iklimden gelen bin parça gemi ve limanın bitip tükenmeyen bereketi ile İstanbul cihanın ticaret merkezidir...',
        'icon': 'water',
      },
    ],
    'İzmir': [
      {
        'title': '🏰 İzmir Liman Kalesi',
        'content': '1280 adımlık taş yapı, limanın hemen kıyısında denizden gelecek tehlikelere karşı koruyucu bir kalkan gibi durur...',
        'icon': 'castle',
      },
      {
        'title': '🦅 Kadifekale (İç Kale)',
        'content': 'Kaydefa yapısı fil cüssesi büyüklüğündeki taşlar ile harika bir zirvede yükselir ve tüm körfeze hakimdir...',
        'icon': 'castle',
      },
      {
        'title': '💧 Kaledeki Âbıhayat Suyu',
        'content': 'Deniz ortasındaki bu hisarın içinde buz gibi tatlı su fışkıran o meşhur kuyu seyyahların hararetini giderir...',
        'icon': 'water',
      },
    ],
    'Ankara': [
      {
        'title': '🏰 Engür Kalesi',
        'content': 'Bir taşına bin baş verilen uçurumun kenarında kurulmuş, göklere ser çekmiş heybetli kale, fethi imkansız ulu bir hisardır...',
        'icon': 'castle',
      },
      {
        'title': '🐑 Meşhur Sof Kumaşı',
        'content': 'İpek gibi yumuşak tiftik keçisi yününden özenle dokunan, padişahların ve kralların giydiği o şanlı kumaş buranın yegane gururudur...',
        'icon': 'history_edu',
      },
      {
        'title': '🧱 Ankara Kerpici',
        'content': 'Sağlamlığın timsali, kışın sıcak yazın serin tutan meşhur kerpiç evler bu şehrin bağrında yükselir...',
        'icon': 'castle',
      },
    ],
    'Trabzon': [
      {
        'title': '🐟 Uğruna Kan Akıtılan Balık',
        'content': 'Trabzon halkının hamsi çılgınlığı ve ona olan muhabbeti o derecedir ki, hamsi geldiğinde tüm şehir işi gücü bırakıp kıyıya koşar...',
        'icon': 'fish',
      },
      {
        'title': '🥘 Hamsi Tavası Tarif-i Şerifi',
        'content': 'Soğan, tarçın, maydanoz, karabiber ve turunç suyuyla yapılan o nefis pilaki ve tava tarifi adeta dertlere devadır...',
        'icon': 'restaurant',
      },
      {
        'title': '🌳 Cennet Bahçeleri',
        'content': 'Limon, erguvan, zeytin ve turunç kokan, şırıl şırıl akan nehirlerin suladığı cennet misali bağlar şehrin süsüdür...',
        'icon': 'history_edu',
      },
    ],
  };

  // ── Türkiye'nin 81 İli (Alfabetik) ─────────────────────────────────────────
  static const List<String> _allCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya',
    'Ankara', 'Antalya', 'Ardahan', 'Artvin', 'Aydın', 'Balıkesir',
    'Bartın', 'Batman', 'Bayburt', 'Bilecik', 'Bingöl', 'Bitlis',
    'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum',
    'Denizli', 'Diyarbakır', 'Düzce', 'Edirne', 'Elazığ', 'Erzincan',
    'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane',
    'Hakkari', 'Hatay', 'Iğdır', 'Isparta', 'İstanbul', 'İzmir',
    'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu',
    'Kayseri', 'Kırıkkale', 'Kırklareli', 'Kırşehir', 'Kilis',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Mardin',
    'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye',
    'Rize', 'Sakarya', 'Samsun', 'Şanlıurfa', 'Siirt', 'Sinop',
    'Şırnak', 'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli',
    'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak'
  ];

  // ── Şehir Verisi Listesi Alma (Fallback Destekli) ──────────────────────────
  List<Map<String, String>> _getCityNotes(String city) {
    if (_seyahatnameNotes.containsKey(city)) {
      return _seyahatnameNotes[city]!;
    }
    return [
      {
        'title': '📜 Seyyâh-ı Âlem Üslubu',
        'content': 'Evliya Çelebi bu kadim menzile ayak bastıkta, kalbini ferahlatan havasına ve bağlarına hayran kalmıştır...',
        'icon': 'history_edu',
      },
      {
        'title': '🐪 Tarihi Hanlar ve Menziller',
        'content': 'Bölgedeki yolcuların konakladığı kervansaraylar ve tüccarların ticaret hanları gayet mamurdur...',
        'icon': 'castle',
      },
      {
        'title': '🍽️ Mahalli Nimetler',
        'content': 'Hak Teala\'nın bu topraklara lütfettiği yerel lezzetler ve misafirperver ahali övgüye layıktır...',
        'icon': 'restaurant',
      },
    ];
  }

  // ── İkon Eşleştirici ───────────────────────────────────────────────────────
  IconData _getIconData(String iconType) {
    switch (iconType) {
      case 'castle':
        return Icons.castle_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'fish':
        return Icons.set_meal_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'history_edu':
      default:
        return Icons.history_edu_rounded;
    }
  }

  // ── Şehir Seçici Açılır Penceresi ──────────────────────────────────────────
  void _showCityPickerDialog() {
    final searchController = TextEditingController();
    List<String> filtered = List.from(_allCities);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF141414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white12, width: 1),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Başlığı
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Seyahatname Şehri Seç',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white54, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arama Filtresi
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Şehir ara...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) {
                          setDialogState(() {
                            final query = val.trim().toLowerCase();
                            filtered = query.isEmpty
                                ? List.from(_allCities)
                                : _allCities
                                    .where((c) => c.toLowerCase().contains(query))
                                    .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  // Şehir Listesi
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (_, index) {
                          final city = filtered[index];
                          final bool isSelected = selectedCity == city;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            leading: const Text('📍', style: TextStyle(fontSize: 15)),
                            title: Text(
                              city,
                              style: TextStyle(
                                color: isSelected ? Colors.redAccent : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.redAccent, size: 18)
                                : null,
                            onTap: () {
                              setState(() => selectedCity = city);
                              Navigator.pop(dialogContext);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final travelNotes = _getCityNotes(selectedCity);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Evliya Çelebi Rotaları',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Seyahatname Başlık Kartı ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_edu_rounded,
                        color: Colors.orangeAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarihsel Gezgin Rehberi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Evliya Çelebi\'nin 17. yüzyıl seyahat notları ve kültür rotaları.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Şehir Seçim Butonu ─────────────────────────────────────────────
              const Text(
                'Seyahatname Rotası',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCityPickerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '📍 Şehir Seç: $selectedCity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Seyahatname Notları Başlığı ────────────────────────────────────
              const Text(
                'Evliya Çelebi Notları',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // ── Seyahatname Notları Listesi (ListView.builder) ──────────────────
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: travelNotes.length,
                itemBuilder: (context, index) {
                  final note = travelNotes[index];
                  final String title = note['title'] ?? '';
                  final String content = note['content'] ?? '';
                  final String iconType = note['icon'] ?? 'history_edu';
                  final IconData icon = _getIconData(iconType);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E1E1E),
                          Color(0xFF121212),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.02),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.15)),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.orangeAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Tarihi',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                content,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
