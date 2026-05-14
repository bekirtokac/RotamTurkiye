import 'package:flutter/material.dart';
import 'package:rotam_turkiye/model/onboarding_content_model.dart';
import 'package:rotam_turkiye/screens/LoginPage.dart'; // LoginPage import edildi

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int index = 0;
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Image.asset(
                            contents[i].image,
                            height: 300,
                          ),
                          Text(
                            contents[i].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Beyaz metin rengi
                            ),
                          ),
                          Text(
                            contents[i].metin,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  buildDot(currentIndex, context), // currentIndex'i gönder
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.all(40),
            width: double.infinity,
            child: ElevatedButton(
              child: Text(
                currentIndex == contents.length - 1
                    ? "Hadi Başlayalım!"
                    : "İleri",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold), // Siyah metin rengi
              ),
              onPressed: () {
                if (currentIndex == contents.length - 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage()), // LoginPage'e git
                  );
                } else {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Düğme arka plan rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> buildDot(int index, BuildContext context) {
  return List.generate(
    contents.length,
    (i) => Container(
      height: 10,
      width: index == i ? 25 : 10, // index ile i'yi karşılaştır
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 100, 22, 17), // Kırmızı nokta rengi
      ),
    ),
  );
}
