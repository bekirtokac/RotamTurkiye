import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/model/trip_model.dart';
import 'package:rotam_turkiye/services/trip_base.dart';

class FirestoreTripService implements TripBase {
  final FirebaseFirestore _firebaseAuth = FirebaseFirestore.instance;

  @override
  Future<bool> createTrip(
      UserModel user, String? city, String? date, int? budget, int? spentDay) {
    // TODO: implement createTrip
    throw UnimplementedError();
  }

  @override
  Future<TripModel?> readTrip(String userId, String tripId) async {
    try {
      // Kullanıcının dokümanını referans al
      DocumentSnapshot tripSnapshot = await _firebaseAuth
          .collection("users")
          .doc(userId)
          .collection("visited_cities")
          .doc(tripId)
          .get();

      if (tripSnapshot.exists) {
        // Belge varsa, belgeden trip bilgilerini al ve TripModel oluştur
        Map<String, dynamic> tripData =
            tripSnapshot.data() as Map<String, dynamic>;
        return TripModel.fromMap(tripData, tripSnapshot.id);
      } else {
        print("Belirtilen trip bulunamadı.");
        return null;
      }
    } catch (e) {
      print("Trip okunurken hata oluştu: $e");
      return null;
    }
  }
}
