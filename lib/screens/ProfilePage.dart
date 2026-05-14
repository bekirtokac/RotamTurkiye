import 'package:flutter/material.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/widgets/VisitedPlaceList.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key});

  void _signOut(BuildContext context) async {
    final _userModel = Provider.of<MyUserModel>(context, listen: false);
    await _userModel.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Arka plan rengini siyah yap
      appBar: AppBar(
        backgroundColor: Colors.transparent, // App bar arka planını şeffaf yap
        title: Text(
          "Profil",
          style: TextStyle(
            color: Colors.white, // Başlık rengini beyaz yap
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white, // Çıkış yap ikonu rengini beyaz yap
            ),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 100, // Profil fotoğrafı boyutu
            backgroundImage: NetworkImage(
                'https://images.pexels.com/photos/17034914/pexels-photo-17034914/free-photo-of-adam-model-sapka-yuz.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'), // Profil fotoğrafı
          ),
          SizedBox(height: 20), // Boşluk ekleyelim
          Text(
            "Metin Tütün",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10), // Boşluk ekleyelim
          Text(
            "Ankara",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20), // Boşluk ekleyelim
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Puanlar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "100", // Örnek puan sayısı
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Biletler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "10", // Örnek bilet sayısı
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "Gezdiğin yerler",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          VisitedPlaceList()
        ],
      ),
    );
  }
}
