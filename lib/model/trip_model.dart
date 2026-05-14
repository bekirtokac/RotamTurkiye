import 'package:rotam_turkiye/model/UserModel.dart';

class TripModel {
  final String id;
  final UserModel user;
  final String cityName;
  final int budget;
  final int daysSpent;
  final DateTime departureDate;

  TripModel({
    required this.id,
    required this.user,
    required this.cityName,
    required this.budget,
    required this.daysSpent,
    required this.departureDate,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, String id) {
    return TripModel(
      id: id,
      user: UserModel.fromMap(map['user'], id), // İkinci argümanı ekledik
      cityName: map['city_name'],
      budget: map['budget'],
      daysSpent: map['days_spent'],
      departureDate: DateTime.parse(map['departure_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user.toMap(),
      'city_name': cityName,
      'budget': budget,
      'days_spent': daysSpent,
      'departure_date': departureDate.toIso8601String(),
    };
  }
}
