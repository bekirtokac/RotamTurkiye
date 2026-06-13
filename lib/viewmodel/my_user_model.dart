import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rotam_turkiye/locator.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/repository/user_repository.dart';
import 'package:rotam_turkiye/services/auth_base.dart';
import 'package:rotam_turkiye/services/firebase_storage_service.dart';
import 'package:rotam_turkiye/services/firestore_db_service.dart';

enum ViewState { Idle, Busy }

class MyUserModel with ChangeNotifier implements AuthBase {
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  final FirebaseStorageService _storageService =
      locator<FirebaseStorageService>();
  ViewState _state = ViewState.Idle;
  final UserRepository _userRepository = locator<UserRepository>();
  UserModel? _user;

  UserModel? get user => _user;
  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  MyUserModel() {
    //currentUser();
  }

  @override
  Future<UserModel?> currentUser() async {
    try {
      state = ViewState.Busy;
      return _user = await _userRepository.currentUser();
    } catch (e) {
      print("User_model deki currentUser da hata oldu: ${e.toString()}");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithEmailAndPassword(email, password);
      return _user;
    } catch (e) {
      print(
          "User_model deki signin with email and password da hata oldu: ${e.toString()}");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      bool result = await _userRepository.signOut();
      _user = null;
      return result;
    } catch (e) {
      print("User_model deki currentUser da hata oldu: ${e.toString()}");
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      state = ViewState.Busy;
      _user =
          await _userRepository.createUserWithEmailAndPassword(email, password);
      return _user;
    } catch (e) {
      print(
          "User_model deki create user with email and passwor da hata oldu: ${e.toString()}");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_user == null) {
      return false;
    }

    try {
      state = ViewState.Busy;
      final downloadUrl =
          await _storageService.uploadProfileImage(_user!.id, imageFile);

      final isSaved =
          await _firestoreDBService.updatePhotoUrl(_user!.id, downloadUrl);
      if (!isSaved) {
        return false;
      }

      _user = await _firestoreDBService.readUser(_user!.id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Profil fotoğrafı güncellenirken hata oluştu: $e");
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<void> reloadUser() async {
    if (_user != null) {
      try {
        _user = await _firestoreDBService.readUser(_user!.id);
        notifyListeners();
      } catch (e) {
        print("Error reloading user: $e");
      }
    }
  }

  Future<bool> saveUserDetails(String userId, String name, String city) async {
    try {
      state = ViewState.Busy;
      final bool isSaved =
          await _firestoreDBService.saveUserDetails(userId, name, city);

      if (!isSaved) {
        return false;
      }

      _user = await _firestoreDBService.readUser(userId);
      notifyListeners();
      return true;
    } catch (e) {
      print("Kullanıcı bilgileri kaydedilirken hata oluştu: $e");
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<bool> updateUserScore(int newScore) async {
    if (_user == null) return false;
    try {
      final success =
          await _firestoreDBService.updateUserScore(_user!.id, newScore);
      if (success) {
        _user!.score = newScore;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Kullanıcı puanı ViewModel'de güncellenirken hata oluştu: $e");
      return false;
    }
  }
}

