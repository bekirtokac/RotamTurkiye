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
  Future<bool> updatePhotoUrl(String userId, String photoUrl) async {
    try {
      await _firebaseDB.collection("users").doc(userId).update({
        'photoUrl': photoUrl,
      });
      return true;
    } catch (e) {
      print("Profil fotoğrafı URL kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  @override
  Future<UserModel> readUser(String id) async {
    DocumentSnapshot readingUser =
        await _firebaseDB.collection("users").doc(id).get();
    Map<String, dynamic>? readingUserInfo =
        readingUser.data() as Map<String, dynamic>?;

    if (readingUserInfo != null) {
      print("okunana user: ${readingUserInfo.toString()}");
      return UserModel.fromMap(readingUserInfo, id);
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

  /// Kullanıcının visited_cities koleksiyonunu stream olarak dinler.
  Stream<QuerySnapshot> getVisitedCities(String userId) {
    return _firebaseDB
        .collection("users")
        .doc(userId)
        .collection("visited_cities")
        .snapshots();
  }

  /// Profil sayfasından tek bir gezilen şehir kaydı ekler.
  Future<bool> addVisitedCity(
      String userId, String city, int spentDay, String date) async {
    try {
      await _firebaseDB
          .collection("users")
          .doc(userId)
          .collection("visited_cities")
          .doc()
          .set({
        'city': city,
        'spent_day': spentDay,
        'date': date,
      });
      return true;
    } catch (e) {
      print("Gezilen şehir eklenirken hata oluştu: $e");
      return false;
    }
  }

  /// Gezilen şehir kaydını siler.
  Future<bool> deleteVisitedCity(String userId, String docId) async {
    try {
      await _firebaseDB
          .collection("users")
          .doc(userId)
          .collection("visited_cities")
          .doc(docId)
          .delete();
      return true;
    } catch (e) {
      print("Gezilen şehir silinirken hata oluştu: $e");
      return false;
    }
  }

  /// Gezilen şehir/plan kaydını günceller.
  Future<bool> updateVisitedCity(
      String userId, String docId, String city, int spentDay, String date) async {
    try {
      await _firebaseDB
          .collection("users")
          .doc(userId)
          .collection("visited_cities")
          .doc(docId)
          .update({
        'city': city,
        'spent_day': spentDay,
        'date': date,
      });
      return true;
    } catch (e) {
      print("Seyahat planı güncellenirken hata oluştu: $e");
      return false;
    }
  }

  /// Kullanıcının toplam puanını (score) Firestore'da günceller.
  Future<bool> updateUserScore(String userId, int score) async {
    try {
      await _firebaseDB.collection("users").doc(userId).update({
        'score': score,
      });
      return true;
    } catch (e) {
      print("Kullanıcı puanı güncellenirken hata oluştu: $e");
      return false;
    }
  }

  /// Verilen puana göre kullanıcının tüm veritabanında kaçıncı sırada olduğunu dinamik olarak hesaplar.
  Future<int> getUserRank(int score) async {
    try {
      final snapshot = await _firebaseDB
          .collection("users")
          .where("score", isGreaterThan: score)
          .count()
          .get();
      return (snapshot.count ?? 0) + 1;
    } catch (e) {
      print("Sıralama hesaplanırken hata oluştu: $e");
      return 1;
    }
  }
}


