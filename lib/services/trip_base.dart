import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/model/trip_model.dart';

abstract class TripBase {
  Future<bool> createTrip(
      UserModel user, String? city, String? date, int? budget, int? spentDay);
  Future<TripModel?> readTrip(String userId, String tripId);
}
