import 'package:rotam_turkiye/model/UserModel.dart';

abstract class AuthBase {
  Future<UserModel?> currentUser();
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password);
  Future<bool> signOut();
}
