import 'package:flutter/material.dart';

class VedatMilorPage extends StatefulWidget {
  const VedatMilorPage({super.key});

  @override
  State<VedatMilorPage> createState() => _VedatMilorPageState();
}

class _VedatMilorPageState extends State<VedatMilorPage> {
  String selectedCity = "İstanbul";

  // ── Vedat Milor Gurme Notları Modeli ───────────────────────────────────────
  static const Map<String, List<Map<String, String>>> _gurmeNotes = {
    'İstanbul': [
      {
        'title': '🥩 Tarihi Karadeniz Dönercisi - Beşiktaş',
        'content': 'Benim için dönerin nirvanası burasıdır. Odun ateşinde ağır ağır pişen, yağ dengesi muazzam, fabrikasyon olmayan hakiki dana eti döneri. Kurumadan servis edilmesi mühimdir.',
        'icon': 'meat',
      },
      {
        'title': '🍲 Kanaat Lokantası - Üsküdar',
        'content': 'Tencere yemeklerinde ve zeytinyağlılarda bir İstanbul klasiği. Özellikle elbasan tava ve kuzu kapaması, o eski esnaf lokantası disiplininin en asil örneklerindendir.',
        'icon': 'soup',
      },
      {
        'title': '🍧 Asiye Hanım Kadayıfı - Fatih',
        'content': 'Katkısız hakiki tereyağı ve tam kıvamında şerbetle hazırlanan kadayıf. Çıtır dokusu ve içindeki Antep fıstığının kalitesi damağı yormuyor.',
        'icon': 'dessert',
      },
    ],
    'İzmir': [
      {
        'title': '🌮 Tarihi Kemeraltı Söğüşçüsü',
        'content': 'Söğüş, hazırlaması ciddiyet isteyen bir sanattır. Beyin, dil ve yanak etinin ince kıyılıp taze yeşillik ve kimyonla harmanlanması burada kusursuz yapılıyor.',
        'icon': 'meat',
      },
      {
        'title': '🍲 Adil Müftüoğlu Esnaf Lokantası',
        'content': '1955\'ten beri çizgisini bozmayan ulu çınar. Özellikle kuzu tandır ve şevketi bostan yemekleri, Ege mutfağının asaletini tabaklara yansıtıyor.',
        'icon': 'soup',
      },
      {
        'title': '🍧 Meşhur Reyhan Pastanesi',
        'content': 'Lor tatlısı ve vişneli dondurması, fabrikasyon pastacılığa karşı duran dürüst birer lezzet anıtı gibidir.',
        'icon': 'dessert',
      },
    ],
    'Ankara': [
      {
        'title': '🏰 Kebabçı Emin Usta - Ulus',
        'content': 'Derme çatma bir dükkanda kömür ateşinde pişen, sosla veya gereksiz baharatla boğulmamış, etin kendi lezzetini öne çıkaran muazzam bir kuzu şiş.',
        'icon': 'meat',
      },
      {
        'title': '🍲 Boğaziçi Lokantası - Ulus',
        'content': 'Ankara\'nın en dürüst tencere yemekleri adresi. Ankara tavası ve kuzu kapaması, kemiğinden kendi kendine ayrılacak kadar kıvamlı ve lezzetlidir.',
        'icon': 'soup',
      },
      {
        'title': '🍧 Zeynel Muhallebicisi',
        'content': 'Hakiki manda sütü ve pirinç sübyesiyle yapılan kazandibi. Yanık kokusu yapay değil, karamelize şekerden gelen o asil derinliğe sahip.',
        'icon': 'dessert',
      },
    ],
    'Trabzon': [
      {
        'title': '🐟 Rüştü\'nün Fırını - Pide',
        'content': 'Pide hamurunun ekşi mayalı olması, Trabzon tereyağının kalitesi ve kolot peynirinin uzayan dokusuyla tam bir başyapıt. Kenarları çıtır, içi sulu.',
        'icon': 'bakery',
      },
      {
        'title': '🍲 Kalkanoğlu Pilavcısı',
        'content': 'Kavurmalı pilavın efsane adresi. Kuru fasulye ve et suyunda pişmiş, her tanesi tek tek sayılan tereyağlı pilavın uyumu damakta adeta bir şölen sunuyor.',
        'icon': 'soup',
      },
      {
        'title': '🍧 Beton Helva - Merkez',
        'content': 'Geleneksel irmik ve fıstıklı helvanın en dürüst üreticisi. Kıvamı beton gibi sert görünse de ağızda dağılan yapısı şaşırtıcı ve asildir.',
        'icon': 'dessert',
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

  // ── Şehir Gurme Verisi Alma (Fallback Destekli) ───────────────────────────
  List<Map<String, String>> _getCityNotes(String city) {
    if (_gurmeNotes.containsKey(city)) {
      return _gurmeNotes[city]!;
    }
    return [
      {
        'title': '🥩 Meşhur Esnaf Lezzetleri',
        'content': '$city merkezinde gizli kalmış, fabrikasyona yenik düşmemiş o geleneksel lezzet durağı. Etin kalitesi ve ustalık takdire şayan.',
        'icon': 'meat',
      },
      {
        'title': '🍲 Çorba ve Tencere Yemekleri',
        'content': 'Hakiki kemik suyu ve yerel malzemelerle pişmiş, şahsiyeti olan dürüst bir esnaf lokantası. Yoğurt mayası yerel, malzemeler tazedir.',
        'icon': 'soup',
      },
      {
        'title': '🍧 Yöresel Tatlı Mirası',
        'content': 'Katkı maddesi içermeyen, o eski kuşakların tarifini koruyan asil bir tatlı adresi. Gerçek şeker pancarı şerbeti kullanılmış.',
        'icon': 'dessert',
      },
    ];
  }

  // ── İkon Eşleştirici ───────────────────────────────────────────────────────
  IconData _getIconData(String iconType) {
    switch (iconType) {
      case 'meat':
        return Icons.restaurant_rounded;
      case 'soup':
        return Icons.soup_kitchen_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'dessert':
        return Icons.icecream_rounded;
      default:
        return Icons.restaurant_menu_rounded;
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
                            Icons.restaurant_menu_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gurme Şehri Seç',
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
          'Vedat Milor Rotaları',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Gurme Başlık Kartı ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.redAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vedat Milor Gurme Rehberi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Esnaf lokantaları, yerel lezzetler ve dürüst gurme durakları.',
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
            ),

            // ── Şehir Seçim Butonu ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gurme Keşif Rotası',
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
                              '📍 Gurme Şehir Seç: $selectedCity',
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Gurme Mekan Notları Başlığı ──────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Değerlendirmeler & Tavsiyeler',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Gurme Mekanları Listesi (Expanded + ListView.builder) ─────────
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: travelNotes.length,
                itemBuilder: (context, index) {
                  final note = travelNotes[index];
                  final String title = note['title'] ?? '';
                  final String content = note['content'] ?? '';
                  final String iconType = note['icon'] ?? 'default';
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
                            color: Colors.redAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.redAccent,
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
                                        color: Colors.redAccent,
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
                                      'Milor',
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
                                  fontStyle: FontStyle.normal,
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
            ),
          ],
        ),
      ),
    );
  }
}
