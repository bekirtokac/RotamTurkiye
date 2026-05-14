import 'package:flutter/material.dart';
import 'package:rotam_turkiye/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalPeoplePage extends StatefulWidget {
  final String selectedCity;
  final String departureDate;
  final String stayDuration;
  final String budget;

  const LocalPeoplePage({
    required this.selectedCity,
    required this.departureDate,
    required this.stayDuration,
    required this.budget,
    super.key,
  });

  @override
  _LocalPeoplePageState createState() => _LocalPeoplePageState();
}

class _LocalPeoplePageState extends State<LocalPeoplePage> {
  String aiResponse = '';
  bool isLoadingAI = true;
  List<bool> _isSendingRequestList = [];
  List<String> _buttonTexts = [];

  @override
  void initState() {
    super.initState();
    getAIRecommendations();
  }

  void getAIRecommendations() async {
    // API'yı devre dışı bırakıyoruz:
     /*
    final response = await GeminiService.getRecommendations(
      city: widget.selectedCity,
      days: widget.stayDuration,
      budget: widget.budget,
    );
    setState(() {
      aiResponse = response;
      isLoadingAI = false;
    });
     */
    // Yerine örnek öneriler göster:
  setState(() {
    aiResponse = '''
1. Taş Köprü
Adana'nın simgesi olan tarihi köprü.

2. Sabancı Merkez Camii
Modern mimarisiyle dikkat çeken camii.

3. Adana Arkeoloji Müzesi
Binlerce yıllık geçmişe ışık tutan müze.
''';
    isLoadingAI = false;
  });
  }

  Stream<QuerySnapshot> getLocalPeopleStream() {
    return FirebaseFirestore.instance
        .collection('localPeople')
        .where('city', isEqualTo: widget.selectedCity)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "${widget.selectedCity} şehrindeki yereller";
    double appBarFontSize = appBarTitle.length > 30 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  
  
  title: Text(
    widget.selectedCity,
    style: TextStyle(fontSize: 24.0, color: Colors.white),
  ),
  iconTheme: IconThemeData(color: Colors.white),
),
body: isLoadingAI
    ? Center(child: CircularProgressIndicator())
    : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '🧠 AI’dan Öneriler:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...aiResponse.split('\n\n').map((suggestion) {
            final lines = suggestion.split('\n');
            final title = lines.isNotEmpty ? lines[0].trim() : '';
            final description = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

            return Card(
              color: Colors.deepPurple[700],
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          

                Divider(color: Colors.white),
                Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
            child: Text(
              '${widget.selectedCity} Şehrindeki Yerel Rehberler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ),
                StreamBuilder<QuerySnapshot>(
                  stream: getLocalPeopleStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (_isSendingRequestList.length != docs.length) {
                      _isSendingRequestList = List.filled(docs.length, false);
                      _buttonTexts = List.filled(
                          docs.length, 'Sohbet İsteği Gönder');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final person = docs[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          color: Colors.grey[900],
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(person['photoUrl']),
                            ),
                            title: Text(
                              person['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Şehir: ${widget.selectedCity}',
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                if (_buttonTexts[index] ==
                                    'Sohbet İsteği Gönder') {
                                  _sendRequestAndShowIndicator(index);
                                } else {
                                  _cancelRequest(index);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              child: _isSendingRequestList[index]
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                    )
                                  : Text(
                                      _buttonTexts[index],
                                      style: TextStyle(color: Colors.black),
                                    ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
    );
  }

  void _sendRequestAndShowIndicator(int index) {
    setState(() {
      _isSendingRequestList[index] = true;
      _buttonTexts[index] = 'İstek Gönderildi';
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isSendingRequestList[index] = false;
      });
    });
  }

  void _cancelRequest(int index) {
    setState(() {
      _buttonTexts[index] = 'Sohbet İsteği Gönder';
    });
  }
}
