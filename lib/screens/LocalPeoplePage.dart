import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/gemini_service.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/screens/HomePage.dart';

class LocalPeoplePage extends StatefulWidget {
  final String selectedCity;
  final String selectedDistrict;
  final String departureDate;
  final String stayDuration;
  final String selectedStayType;

  const LocalPeoplePage({
    required this.selectedCity,
    required this.selectedDistrict,
    required this.departureDate,
    required this.stayDuration,
    required this.selectedStayType,
    super.key,
  });

  @override
  _LocalPeoplePageState createState() => _LocalPeoplePageState();
}

class _LocalPeoplePageState extends State<LocalPeoplePage> {
  String aiResponse = '';
  bool isLoadingAI = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    getAIRecommendations();
  }

  List<String> _getRecommendationsList() {
    final stayType = widget.selectedStayType.toString().toLowerCase();
    List<String> items = [];

    if (stayType.contains('çadır') || stayType.contains('camp') || stayType.contains('çadir')) {
      items = [
        'Vitamin D3/K2',
        'Magnezyum desteği',
        'Uyku Tulumu & Mat',
        'Kafa Lambası',
        'Powerbank',
        'Termal İçlik',
        'Sinek Kovucu Sprey',
        'İlk Yardım Seti',
        'Filtreli Matara',
        'Kamp Ocağı',
      ];
    } else if (stayType.contains('karavan') || stayType.contains('caravan')) {
      items = [
        'B Kompleks',
        'Omega-3 desteği',
        'Akşam Magnezyumu',
        'Su/Atık Tankı Kontrolü',
        '12V Şarj Aparatları',
        'Teker Takozları',
        'Düzenleyici Çantalar',
        'Tamir Takımı',
        'Uzatma Kablosu',
        'Dolap Kilitleme Sabitleyicileri',
      ];
    } else {
      // Otel/hotel veya varsayılan
      items = [
        'Vitamin C',
        'Probiyotik desteği',
        'Yürüyüş Ayakkabısı',
        'İlaç Kutusu ile Supplement Taşınması',
        'Şemsiye/Yağmurluk',
        'Nemlendirici Krem',
        'Belgelerin Dijital Kopyaları',
        'Şehir Sırt Çantası',
        'Müzekart Kontrolü',
        'En Yakın Eczane/Hastane Konumları',
      ];
    }

    // Sağlık rutini uyarısı her durumda listenin en altında yer almalı
    items.add("Günlük Omega-3, Vitamin D3 ve Magnezyum takviyelerini yanına almayı unutma! 💊");
    return items;
  }

  String _getFallbackForCity(String city, int days) {
    // Dynamic rich fallback for other cities
    List<String> plans = [];
    for (int i = 1; i <= days; i++) {
      if (i == 1) {
        plans.add("$i. Gün:\n${widget.selectedCity} bölgesine varış, konaklama alanının ayarlanması ve çevreyi tanıma amaçlı keyifli bir yürüyüş.");
      } else if (i == days) {
        plans.add("$i. Gün:\nYöresel pazarlarda alışveriş, hediyelik eşyaların seçilmesi, seyahat defterinin doldurulması ve dönüş hazırlıkları.");
      } else if (i == 2) {
        plans.add("$i. Gün:\nTarihi ve kültürel mekanların gezilmesi, meşhur yerel lezzetlerin tadımı ve doğa ile iç içe fotoğraf molaları.");
      } else {
        plans.add("$i. Gün:\nÇevre ilçelerdeki doğal güzelliklerin ve saklı kalmış tarihi noktaların keşfedilmesi.");
      }
    }
    return plans.join("\n\n");
  }

  void getAIRecommendations() async {
    final city = widget.selectedCity.toString().trim().toLowerCase();
    final days = int.tryParse(widget.stayDuration) ?? 1;
    String finalResponse = '';

    final isYalova = city.contains('yalova');
    final isAnkara = city.contains('ankara');
    final isIstanbul = city.contains('istanbul') || city.contains('i̇stanbul') || city.contains('ist') || city.contains('ıstanbul');

    // 1- API ÇAĞRISININ EN TEPESİNE BARİKAT: Yalova, Ankara, İstanbul kontrolü (Koşul ne olursa olsun)
    if (isYalova) {
      finalResponse = "1. Gün:\nDoğanın kalbi Erikli Yaylası'na varış, kamp alanının kurulması, temiz havada çadır keyfi ve muazzam Çifte Şelaleler rotasında doğa yürüyüşü.\n\n"
          "2. Gün:\nGörsel bir şölen sunan Sudüşen Şelalesi ziyareti, öğleden sonra Delmece Yaylası'nın geniş düzlüklerinde yürüyüş ve akşam kamp ateşi sohbetleri.\n\n"
          "3. Gün:\nTürkiye'nin ilk canlı ağaç müzesi olan Karaca Arboritumu gezisi, ardından Termal kaplıcalarında tüm yorgunluğu atma ve şehirden ayrılış.";
    } else if (isAnkara) {
      finalResponse = "1. Gün:\nSoğuksu Milli Parkı'nda (Kızılcahamam) doğayla iç içe çadır/karavan kurulumu, temiz havada trekking ve akşam kamp ateşi eşliğinde dinlenme.\n\n"
          "2. Gün:\nEymir Gölü etrafında keyifli bir bisiklet turu ve göl kenarı yürüyüşü; öğleden sonra ise tarihi Ankara Kalesi ve Hamamönü'nün nostaljik sokaklarında kültür gezisi.\n\n"
          "3. Gün:\nCumhuriyetimizin kalbi Anıtkabir'e anlamlı bir ziyaret, ardından Kuğulu Park'ta kuğuları izleyerek mola verme ve seyahat defterini gururla mühürleme.";
    } else if (isIstanbul) {
      finalResponse = "1. Gün:\nŞile veya Ağva'nın sakin nehir kenarı kamp alanlarına varış, Karadeniz sahilinde huzurlu bir yürüyüş ve doğayla baş başa ilk gece konaklaması.\n\n"
          "2. Gün:\nTarihi Yarımada'ya geçiş; Ayasofya-i Kebir Camii, Sultanahmet ve Topkapı Sarayı'nı içeren dev bir kültür turu veya boğaz hattında harika bir seyir.\n\n"
          "3. Gün:\nBelgrad Ormanı'nın devasa ağaçları arasında sabah koşusu/yürüyüşü, Polonezköy'de otantik bir mola ve bu büyük seyahati başarıyla sonlandırma.";
    }

    if (finalResponse.isNotEmpty) {
      // Barikat tetiklendi, hazır veriyi yükle ve fonksiyondan çık
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          aiResponse = finalResponse;
          isLoadingAI = false;
        });
      }
      return;
    }

    // Diğer durumlar için API çağrısı yapılıyor
    try {
      final response = await GeminiService.getRecommendations(
        city: widget.selectedCity,
        district: widget.selectedDistrict,
        days: widget.stayDuration,
        stayType: widget.selectedStayType,
      );

      // Hata içeren bir durum dönmüşse fallback şablonuna düşür
      if (response.contains("AI önerisi alınamadı") || response.contains("404") || response.trim().isEmpty) {
        finalResponse = _getFallbackForCity(city, days);
      } else {
        finalResponse = response;
      }
    } catch (e) {
      debugPrint("Gemini API error, falling back to mock: $e");
      finalResponse = _getFallbackForCity(city, days);
    }

    if (mounted) {
      setState(() {
        aiResponse = finalResponse;
        isLoadingAI = false;
      });
    }
  }

  List<Map<String, String>> _parseAIResponse(String response) {
    List<Map<String, String>> list = [];
    // Match blocks starting with a number followed by "Gün" (e.g. "1. Gün", "Gün 1")
    final regExp = RegExp(
      r'(?:^|\n\s*\n)(\d+\.\s*Gün:?\s*.*?)(?=\n\s*\n\d+\.\s*Gün:?|$)',
      dotAll: true,
    );
    final matches = regExp.allMatches(response);

    if (matches.isNotEmpty) {
      for (var match in matches) {
        final block = match.group(1)?.trim() ?? '';
        if (block.isEmpty) continue;

        final lines = block.split('\n');
        final title = lines[0].trim();
        final description = lines.sublist(1).join('\n').trim();

        list.add({
          'title': title,
          'description': description,
        });
      }
    } else {
      // Fallback: split by double newlines
      final blocks = response.split('\n\n');
      for (var block in blocks) {
        final lines = block.trim().split('\n');
        if (lines.isEmpty) continue;
        final title = lines[0].trim();
        final description = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';
        if (title.isNotEmpty) {
          list.add({
            'title': title,
            'description': description,
          });
        }
      }
    }

    if (list.isEmpty && response.isNotEmpty) {
      list.add({
        'title': 'Seyahat Rotası Önerisi',
        'description': response,
      });
    }

    return list;
  }

  void saveTripToFirebase() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final userModel = Provider.of<MyUserModel>(context, listen: false);
      final user = userModel.user;
      if (user == null) {
        throw Exception("Kullanıcı oturumu bulunamadı.");
      }

      final int stayDays = int.tryParse(widget.stayDuration) ?? 1;
      final selectedDate = DateTime.parse(widget.departureDate);

      // Save to Firebase under planned_routes subcollection only
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .collection("planned_routes")
          .doc()
          .set({
        'city': widget.selectedCity,
        'district': widget.selectedDistrict,
        'date': "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
        'days': stayDays,
        'accommodation': widget.selectedStayType,
        'created_at': DateTime.now().toString(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Rotanız Seyahat Defterine Başarıyla Kaydedildi! 🎒",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE65F2B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Redirect user to Profile page (tab index 3 on HomePage)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userModel: user, initialIndex: 3),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kaydedilirken bir hata oluştu: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedRecommendations = _parseAIResponse(aiResponse);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.selectedCity,
          style: const TextStyle(fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoadingAI
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65F2B)),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    '🧠 AI Seyahat Planı:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Timeline List
                ...List.generate(parsedRecommendations.length, (index) {
                  final item = parsedRecommendations[index];
                  final title = item['title'] ?? '';
                  final description = item['description'] ?? '';
                  final isLast = index == parsedRecommendations.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left timeline line & icon
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              // Numbered Circle
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE65F2B),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE65F2B).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Connecting line
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: Colors.white24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Right Card Content
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24, right: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFFE65F2B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Yolculuk Öncesi Akıllı Hatırlatmalar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        title: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFE65F2B),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Yolculuk Öncesi Akıllı Hatırlatmalar 🎒",
                                style: TextStyle(
                                  color: Color(0xFFE65F2B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        iconColor: const Color(0xFFE65F2B),
                        collapsedIconColor: const Color(0xFFE65F2B),
                        childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 18.0),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Tercih ettiğiniz konaklama türüne (${widget.selectedStayType}) özel tavsiyeler:",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_getRecommendationsList().length, (index) {
                            final itemText = _getRecommendationsList()[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "-",
                                    style: TextStyle(
                                      color: Color(0xFFE65F2B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        itemText,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14.0,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : saveTripToFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65F2B),
                      disabledBackgroundColor: const Color(0xFFE65F2B).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFE65F2B).withOpacity(0.4),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Rotayı Seyahat Defterime Kaydet 🎒",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
