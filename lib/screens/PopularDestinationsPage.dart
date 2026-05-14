import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PopularDestinationsPage extends StatelessWidget {
  Future<List<dynamic>> _loadDestinations() async {
    try {
      String data =
          await rootBundle.loadString('assets/json/popular_destinations.json');
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
          "Popüler Hedefler",
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
        future: _loadDestinations(),
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
            List<dynamic> destinations = snapshot.data!;
            return ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> destination = destinations[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          destination['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        destination['name'],
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        destination['description'],
                        style: TextStyle(fontSize: 14),
                      ),
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
