import 'package:rotam_turkiye/locator.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/services/auth_base.dart';
import 'package:rotam_turkiye/services/firebase_auth_service.dart';
import 'package:rotam_turkiye/services/firestore_db_service.dart';

class UserRepository implements AuthBase {
  final FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  @override
  Future<UserModel?> currentUser() async {
    return await _firebaseAuthService.currentUser();
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    UserModel? user =
        await _firebaseAuthService.signInWithEmailAndPassword(email, password);
    return await _firestoreDBService.readUser(user!.id);
  }

  @override
  Future<bool> signOut() async {
    return await _firebaseAuthService.signOut();
  }

  @override
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password) async {
    UserModel? user = await _firebaseAuthService
        .createUserWithEmailAndPassword(email, password);
    bool result = await _firestoreDBService.saveUser(user!);
    if (result) {
      return await _firestoreDBService.readUser(user.id);
    } else {
      return null;
    }
  }
}
