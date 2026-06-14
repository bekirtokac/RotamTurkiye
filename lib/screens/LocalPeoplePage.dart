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

  void getAIRecommendations() async {
    try {
      final response = await GeminiService.getRecommendations(
        city: widget.selectedCity,
        district: widget.selectedDistrict,
        days: widget.stayDuration,
        stayType: widget.selectedStayType,
      );
      setState(() {
        aiResponse = response;
        isLoadingAI = false;
      });
    } catch (e) {
      debugPrint("Error fetching AI recommendations: $e");
      setState(() {
        aiResponse = "AI önerileri alınamadı. Lütfen daha sonra tekrar deneyiniz.";
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

      // Save to Firebase under planned_routes subcollection only
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .collection("planned_routes")
          .doc()
          .set({
        'city': widget.selectedCity,
        'district': widget.selectedDistrict,
        'date': widget.departureDate,
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
