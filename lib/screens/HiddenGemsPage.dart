import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HiddenGemsPage extends StatelessWidget {
  Future<List<dynamic>> _loadHiddenGems() async {
    try {
      String data = await rootBundle.loadString('assets/json/hidden_gems.json');
      return json.decode(data);
    } catch (e) {
      print("Veri yüklenirken bir hata oluştu: $e");
      throw Exception("Veri yüklenirken bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Saklı Hazineler",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _loadHiddenGems(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child:
                  Text("Veri yüklenirken bir hata oluştu: ${snapshot.error}"),
            );
          } else {
            List<dynamic> cities = snapshot.data!;
            return ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> city = cities[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            city['city'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            city['hidden_gems'].length,
                            (index) {
                              Map<String, dynamic> gem =
                                  city['hidden_gems'][index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gem['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      gem['description'],
                                      style: TextStyle(
                                        fontSize: 14,
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
              },
            );
          }
        },
      ),
    );
  }
}
