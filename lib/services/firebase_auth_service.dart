import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/services/auth_base.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<UserModel?> currentUser() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı bulunamadı.'); // Throw exception if no user
      } else {
        final user = _userFromFirebase(currentUser);
        return user;
      }
    } catch (e) {
      print(
          "Firebase auth service içindeki current user hata: ${e.toString()}");
      return null; // Hata durumunda null döndür
    }
  }

  UserModel _userFromFirebase(User user) {
    // ignore: unnecessary_null_comparison
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.'); // Kullanıcı yoksa hata fırlatın
    }
    return UserModel(
      id: user.uid,
      email: user.email!,
      name: "deneme",
      city: 'deneme',
    );
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user =
          userCredential.user; // UserCredential'dan User'e dönüştür
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı.'); // Throw exception if no user
      } else {
        final userModel = _userFromFirebase(user);
        return userModel;
      }
    } catch (e) {
      print(
          "Firebase auth service içindeki current user hata: ${e.toString()}");
      return null; // Hata durumunda null döndür
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print("Firebase auth service içindeki signout hata: ${e.toString()}");
      return false;
    }
  }

  @override
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Kullanıcı oluşturulamadı.');
      } else {
        final userModel = _userFromFirebase(user);
        return userModel;
      }
    } catch (e) {
      print("Firebase auth service içindeki create user hata: ${e.toString()}");
      return null;
    }
  }
}
