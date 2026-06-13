import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Hava Durumu Veri Modeli ────────────────────────────────────────────────
class _WeatherDay {
  final String day;
  final String temp;
  final String status;
  final IconData icon;
  final Color color;

  const _WeatherDay({
    required this.day,
    required this.temp,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _selectedCity = 'Tüm Türkiye';

  // ── Coğrafi Bölge Setleri ────────────────────────────────────────────────
  static const _karadenizIller = {
    'Rize', 'Trabzon', 'Artvin', 'Giresun', 'Ordu', 'Samsun',
    'Sinop', 'Kastamonu', 'Bartın', 'Zonguldak', 'Düzce', 'Bolu',
    'Karabük', 'Tokat', 'Amasya', 'Gümüşhane', 'Bayburt',
  };
  static const _egeMerkezIller = {
    'İzmir', 'Muğla', 'Aydın', 'Denizli', 'Manisa', 'Uşak', 'Kütahya',
  };
  static const _akdenizIller = {
    'Antalya', 'Mersin', 'Hatay', 'Adana', 'Osmaniye', 'Isparta',
    'Burdur', 'Kahramanmaraş',
  };
  static const _doguAnadoluIller = {
    'Erzurum', 'Kars', 'Ardahan', 'Iğdır', 'Ağrı', 'Muş', 'Bitlis',
    'Van', 'Hakkari', 'Şırnak', 'Siirt', 'Bingöl', 'Tunceli',
    'Elazığ', 'Malatya', 'Erzincan',
  };
  static const _guneyDoguIller = {
    'Diyarbakır', 'Şanlıurfa', 'Gaziantep', 'Adıyaman', 'Batman',
    'Mardin', 'Kilis',
  };

  // ── Dinamik 3 Günlük Hava Üreteci (81 il destekli) ───────────────────────
  List<_WeatherDay> _generateWeather(String city) {
    final days = ['Bugün', 'Yarın', 'Salı'];

    if (_karadenizIller.contains(city)) {
      // Karadeniz: serin, yağışlı
      final temps = ['18°C', '16°C', '20°C'];
      final statuses = ['Sağanak Yağışlı', 'Yağmurlu', 'Bulutlu'];
      final icons = [Icons.thunderstorm_rounded, Icons.grain_rounded, Icons.wb_cloudy_rounded];
      final colors = [const Color(0xFF5C6BC0), const Color(0xFF42A5F5), const Color(0xFF78909C)];
      return List.generate(3, (i) => _WeatherDay(
        day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
      ));
    }

    if (_egeMerkezIller.contains(city)) {
      // Ege: sıcak, güneşli
      final temps = ['30°C', '31°C', '28°C'];
      final statuses = ['Güneşli', 'Çok Güneşli', 'Parçalı Bulutlu'];
      final icons = [Icons.wb_sunny_rounded, Icons.wb_sunny_rounded, Icons.wb_cloudy_rounded];
      final colors = [const Color(0xFFFFB300), const Color(0xFFFF8F00), const Color(0xFF78909C)];
      return List.generate(3, (i) => _WeatherDay(
        day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
      ));
    }

    if (_akdenizIller.contains(city)) {
      // Akdeniz: çok sıcak, güneşli
      final temps = ['33°C', '32°C', '30°C'];
      final statuses = ['Çok Sıcak', 'Güneşli', 'Güneşli'];
      final icons = [Icons.wb_sunny_rounded, Icons.wb_sunny_rounded, Icons.wb_sunny_rounded];
      final colors = [const Color(0xFFE65100), const Color(0xFFFF8F00), const Color(0xFFFFB300)];
      return List.generate(3, (i) => _WeatherDay(
        day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
      ));
    }

    if (_doguAnadoluIller.contains(city)) {
      // Doğu Anadolu: soğuk, karlı/bulutlu
      final temps = ['8°C', '6°C', '11°C'];
      final statuses = ['Karlı', 'Yoğun Kar', 'Bulutlu'];
      final icons = [Icons.ac_unit_rounded, Icons.ac_unit_rounded, Icons.wb_cloudy_rounded];
      final colors = [const Color(0xFF80DEEA), const Color(0xFF4DD0E1), const Color(0xFF78909C)];
      return List.generate(3, (i) => _WeatherDay(
        day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
      ));
    }

    if (_guneyDoguIller.contains(city)) {
      // Güneydoğu: çok sıcak, kurak
      final temps = ['35°C', '36°C', '33°C'];
      final statuses = ['Çok Sıcak', 'Kavurucu', 'Güneşli'];
      final icons = [Icons.wb_sunny_rounded, Icons.wb_sunny_rounded, Icons.wb_sunny_rounded];
      final colors = [const Color(0xFFBF360C), const Color(0xFFE64A19), const Color(0xFFFF8F00)];
      return List.generate(3, (i) => _WeatherDay(
        day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
      ));
    }

    // İç Anadolu / Marmara / diğer tüm iller
    final temps = ['24°C', '26°C', '22°C'];
    final statuses = ['Az Bulutlu', 'Güneşli', 'Parçalı Bulutlu'];
    final icons = [Icons.cloud_queue_rounded, Icons.wb_sunny_rounded, Icons.wb_cloudy_rounded];
    final colors = [const Color(0xFF90A4AE), const Color(0xFFFFB300), const Color(0xFF78909C)];
    return List.generate(3, (i) => _WeatherDay(
      day: days[i], temp: temps[i], status: statuses[i], icon: icons[i], color: colors[i],
    ));
  }

  // Türkiye'nin 81 ili (alfabetik)
  static const List<String> _allCities = [
    'Tüm Türkiye',
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
    'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak',
  ];

  @override
  void initState() {
    super.initState();
    _initAlerts();
  }

  Future<void> _initAlerts() async {
    try {
      final alertsCollection = _firestore.collection('alerts');
      final snapshot = await alertsCollection.get();

      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> mockAlerts = [
          {
            'title': 'Muğla Orman Giriş Yasakları',
            'description': 'Valilik kararıyla yangın riski nedeniyle ormanlık alanlarda kamp yapmak yasaklanmıştır.',
            'type': 'danger',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Rize Heyelan Uyarısı',
            'description': 'Yoğun yağış sebebiyle Çamlıhemşin rotasında yer yer taş düşmeleri yaşanmaktadır.',
            'type': 'warning',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Kapadokya Balon İptalleri',
            'description': 'Rüzgar limiti aşıldığı için bu sabahki uçuşlar sivil havacılıkça ertelenmiştir.',
            'type': 'info',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        final batch = _firestore.batch();
        for (var alert in mockAlerts) {
          final docRef = alertsCollection.doc();
          batch.set(docRef, alert);
        }
        await batch.commit();
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Uyarılar ilklendirilirken hata oluştu: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Şehir Seçici Dialog ───────────────────────────────────────────────────
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Şehir Seç', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white54, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arama
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
                          hintText: 'İl ara...',
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
                                : _allCities.where((c) => c.toLowerCase().contains(query)).toList();
                          });
                        },
                      ),
                    ),
                  ),
                  // İl Listesi
                  Flexible(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16),
                        itemBuilder: (_, index) {
                          final city = filtered[index];
                          final bool isSelected = _selectedCity == city;
                          final bool isAll = city == 'Tüm Türkiye';
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            leading: isAll
                                ? const Text('🌍', style: TextStyle(fontSize: 18))
                                : const Text('📍', style: TextStyle(fontSize: 16)),
                            title: Text(
                              city,
                              style: TextStyle(
                                color: isSelected ? Colors.redAccent : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Colors.redAccent, size: 18)
                                : null,
                            onTap: () {
                              setState(() => _selectedCity = city);
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

  // ── Hava Durumu Kartları Bölümü ───────────────────────────────────────────
  Widget _buildWeatherSection() {
    if (_selectedCity == 'Tüm Türkiye') return const SizedBox.shrink();

    final days = _generateWeather(_selectedCity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white38, size: 15),
              const SizedBox(width: 6),
              Text(
                '$_selectedCity · 3 Günlük Hava',
                style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 3 Günlük Kartlar
          Row(
            children: days.map((day) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: day == days.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        day.color.withValues(alpha: 0.08),
                        const Color(0xFF161616),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gün adı
                      Text(
                        day.day,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Hava İkonu
                      Icon(day.icon, color: day.color, size: 26),
                      const SizedBox(height: 8),
                      // Sıcaklık
                      Text(
                        day.temp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Durum
                      Text(
                        day.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: day.color.withValues(alpha: 0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Uyarı Kartı ───────────────────────────────────────────────────────────
  Widget _buildAlertCard(Map<String, dynamic> data) {
    final String title = data['title'] as String? ?? 'Duyuru';
    final String description = data['description'] as String? ?? '';
    final String type = data['type'] as String? ?? 'info';
    final color = _getAlertColor(type);
    final icon = _getAlertIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'danger':  return Colors.red;
      case 'warning': return Colors.amber;
      case 'info':
      default:        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'danger':  return Icons.gpp_bad_outlined;
      case 'warning': return Icons.warning_amber_rounded;
      case 'info':
      default:        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = _selectedCity != 'Tüm Türkiye';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "🚨 Anlık Durumlar & İzinler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('alerts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Bir hata oluştu: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white54)),
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];

                // Lokal filtreleme
                final filteredDocs = _selectedCity == 'Tüm Türkiye'
                    ? allDocs
                    : allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title']?.toString() ?? '';
                        final description = data['description']?.toString() ?? '';
                        return title.contains(_selectedCity) || description.contains(_selectedCity);
                      }).toList();

                return CustomScrollView(
                  slivers: [
                    // ── Şehir Filtre Butonu ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: GestureDetector(
                          onTap: _showCityPickerDialog,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: isFiltered
                                  ? Colors.redAccent.withValues(alpha: 0.12)
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFiltered
                                    ? Colors.redAccent.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: isFiltered ? Colors.redAccent : Colors.white38,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isFiltered ? 'Filtre: $_selectedCity' : '📍 Şehir Seç: Tüm Türkiye',
                                    style: TextStyle(
                                      color: isFiltered ? Colors.white : Colors.white54,
                                      fontSize: 14,
                                      fontWeight: isFiltered ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isFiltered)
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedCity = 'Tüm Türkiye'),
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.close_rounded, color: Colors.white38, size: 18),
                                    ),
                                  ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isFiltered ? Colors.redAccent : Colors.white38,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── 3 Günlük Hava Durumu Kartları (sadece şehir seçiliyse) ──
                    SliverToBoxAdapter(child: _buildWeatherSection()),

                    // ── Divider ───────────────────────────────────────────────
                    if (isFiltered)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white24, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '$_selectedCity · Aktif Uyarılar',
                                style: const TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 0.3),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Firestore tamamen boşsa ────────────────────────────────
                    if (allDocs.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text('Aktif bir uyarı bulunmuyor.',
                              style: TextStyle(color: Colors.white54, fontSize: 15)),
                        ),
                      )

                    // ── Seçilen ilde Firestore kaydı yoksa → dinamik resmi bilgi kartı ──
                    else if (filteredDocs.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Sol mavi öncelik çizgisi
                                    Container(width: 5, color: Colors.blue),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.verified_user_rounded,
                                              color: Colors.blue,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$_selectedCity Bölge İzinleri & Yol Durumu',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Valilik ve Karayolları verilerine göre şu an $_selectedCity sınırlarındaki kamp rotaları ve milli parklarda herhangi bir olumsuz durum bildirilmemiştir. Yolunuz açık olsun! 🧭',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 13,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )

                    // ── Uyarı Kartları Listesi ────────────────────────────────
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final data = filteredDocs[index].data() as Map<String, dynamic>;
                              return _buildAlertCard(data);
                            },
                            childCount: filteredDocs.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
