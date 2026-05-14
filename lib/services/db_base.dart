import 'package:rotam_turkiye/model/UserModel.dart';

abstract class DBBase {
  Future<bool> saveUser(UserModel user);
  Future<UserModel> readUser(String id);
  Future<bool> saveUserDetails(String userId, String name, String city);
}
