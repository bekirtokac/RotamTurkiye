import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/model/trip_model.dart';
import 'package:rotam_turkiye/services/db_base.dart';
import 'package:rotam_turkiye/services/trip_base.dart';

class FirestoreDBService implements DBBase, TripBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(UserModel user) async {
    await _firebaseDB.collection("users").doc(user.id).set(user.toMap());
    return true;
  }

  @override
  Future<bool> saveUserDetails(String userId, String name, String city) async {
    try {
      await _firebaseDB.collection("users").doc(userId).update({
        'name': name,
        'city': city,
      });
      readUser(userId);
      return true;
    } catch (e) {
      print("Kullanıcı bilgileri kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  @override
  Future<UserModel> readUser(String id) async {
    DocumentSnapshot _readingUser =
        await _firebaseDB.collection("users").doc(id).get();
    Map<String, dynamic>? _readingUserInfo =
        _readingUser.data() as Map<String, dynamic>?;

    if (_readingUserInfo != null) {
      print("okunana user: ${_readingUserInfo.toString()}");
      return UserModel.fromMap(_readingUserInfo, id);
    } else {
      throw Exception("User not found!");
    }
  }

  @override
  Future<bool> createTrip(
    UserModel user,
    String? city,
    String? date,
    int? budget,
    int? spentDay,
  ) async {
    try {
      // Kullanıcının dokümanını referans al
      DocumentReference userDocRef =
          _firebaseDB.collection("users").doc(user.id);

      // "visited_cities" koleksiyonunu oluştur
      await userDocRef.collection("visited_cities").doc().set({
        'city': city,
        'date': date,
        'budget': budget,
        'spent_day': spentDay,
      });

      print("Trip oluşturuldu ve visited_cities koleksiyonuna eklendi.");
      return true;
    } catch (e) {
      print("Trip oluşturulamadı: $e");
      return false;
    }
  }

  @override
  Future<TripModel?> readTrip(String userId, String tripId) async {
    try {
      // Kullanıcının dokümanını referans al
      DocumentSnapshot tripSnapshot = await _firebaseDB
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
