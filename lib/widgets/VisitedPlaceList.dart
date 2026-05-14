import 'package:flutter/material.dart';

class VisitedPlaceList extends StatelessWidget {
  const VisitedPlaceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: visitedPlaces.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            visitedPlaces[index]['place'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kaldığı Gün Sayısı: ${visitedPlaces[index]['days']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                'Ziyaret Tarihi: ${visitedPlaces[index]['date']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Örnek veri listesi
List<Map<String, dynamic>> visitedPlaces = [
  {
    'place': 'Ankara',
    'days': 5,
    'date': '10 Mart 2023',
  },
  {
    'place': 'Mersin',
    'days': 3,
    'date': '25 Nisan 2023',
  },
  {
    'place': 'İzmir',
    'days': 4,
    'date': '7 Temmuz 2023',
  },
];
