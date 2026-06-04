import 'package:flutter/material.dart';

class VisitedPlaceList extends StatelessWidget {
  final List<Map<String, dynamic>> places;
  final void Function(String docId)? onDelete;

  const VisitedPlaceList({
    super.key,
    required this.places,
    this.onDelete,
  });

  /// Tüm seyahatlerin "Kaldığı Gün Sayısı" değerlerini toplar ve
  /// gün başına 10 puan hesaplayarak toplam puanı döndürür.
  static int calculateTotalPoints(List<Map<String, dynamic>> places) {
    int totalDays = 0;
    for (var place in places) {
      totalDays += ((place['spent_day'] ?? place['days'] ?? 0) as int);
    }
    return totalDays * 10;
  }

  /// Listede aynı şehir ismi birden fazla kez geçiyorsa,
  /// Set yapısı kullanarak benzersiz (unique) şehir sayısını döndürür.
  static int getUniqueCityCount(List<Map<String, dynamic>> places) {
    final Set<String> uniqueCities = {};
    for (var place in places) {
      final city = (place['city'] ?? place['place'] ?? '') as String;
      if (city.isNotEmpty) {
        uniqueCities.add(city);
      }
    }
    return uniqueCities.length;
  }

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.flight_takeoff_rounded, color: Colors.white24, size: 48),
              const SizedBox(height: 8),
              Text(
                "Henüz gezilen yer eklenmemiş",
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      itemBuilder: (BuildContext context, int index) {
        final place = places[index];
        final cityName = (place['city'] ?? place['place'] ?? 'Bilinmeyen') as String;
        final days = (place['spent_day'] ?? place['days'] ?? 0) as int;
        final date = (place['date'] ?? '') as String;
        final docId = place['docId'] as String?;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 24),
            ),
            title: Text(
              cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '$days gün • $date',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: onDelete != null && docId != null
                ? IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 20),
                    onPressed: () => onDelete!(docId),
                  )
                : null,
          ),
        );
      },
    );
  }
}
