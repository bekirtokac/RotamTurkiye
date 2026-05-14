import 'package:rotam_turkiye/locator.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/model/trip_model.dart';
import 'package:rotam_turkiye/services/firestore_db_service.dart';
import 'package:rotam_turkiye/services/trip_base.dart';

class TripRepository implements TripBase {
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();

  @override
  Future<bool> createTrip(UserModel user, String? city, String? date,
      int? budget, int? spentDay) async {
    try {
      bool tripCreated = await _firestoreDBService.createTrip(
          user, city, date, budget, spentDay);
      return tripCreated;
    } catch (e) {
      print("Trip oluşturulurken bir hata oluştu: $e");
      return false;
    }
  }

  @override
  Future<TripModel?> readTrip(String userId, String tripId) async {
    try {
      TripModel? trip = await _firestoreDBService.readTrip(userId, tripId);
      return trip;
    } catch (e) {
      print("Trip okunurken bir hata oluştu: $e");
      return null;
    }
  }
}
