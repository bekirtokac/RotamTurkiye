import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // 1. Firebase Storage sorgusunu 'FirebaseStorage.instance.ref().child("profile_images/${userId}.jpg")' şeklinde yapılandır.
      final ref =
          FirebaseStorage.instance.ref().child("profile_images/$userId.jpg");

      // 2. '.putFile()' metodunu try-catch bloğu içine al. Catch bloğunda hatanın asıl sebebini (e.code veya e.message) konsola 'print()' ile yazdır.
      try {
        await ref.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } on FirebaseException catch (e) {
        print("Firebase Storage putFile error code: ${e.code}");
        print("Firebase Storage putFile error message: ${e.message}");
        rethrow;
      } catch (e) {
        print("General error during putFile: $e");
        rethrow;
      }

      // 3. Yükleme tamamlandıktan sonra '.getDownloadURL()' asenkron metodunun başarıyla tamamlandığından emin ol
      final downloadUrl = await ref.getDownloadURL();

      // 4. Dönen linki Firestore 'users' koleksiyonundaki ilgili kullanıcının 'photoUrl' alanına güncelle.
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase Storage upload error code: ${e.code}");
      print("Firebase Storage upload error message: ${e.message}");
      rethrow;
    } catch (e) {
      print("General Storage upload error: $e");
      rethrow;
    }
  }
}
