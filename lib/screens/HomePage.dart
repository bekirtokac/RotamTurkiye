import 'package:flutter/material.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/MessagesPage.dart';
import 'package:rotam_turkiye/screens/NewTripPage.dart'; // Yeni import
import 'package:rotam_turkiye/screens/PostPage.dart';
import 'package:rotam_turkiye/screens/ProfilePage.dart';
import 'package:rotam_turkiye/screens/SearchPage.dart';
import 'package:rotam_turkiye/widgets/BottomNavBar.dart';

class HomePage extends StatefulWidget {
  final UserModel? userModel;
  const HomePage({super.key, required this.userModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToNewTripPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewTripPage, // Yeni seyahat sayfasına git
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(50.0), // İstenilen yuvarlaklık değeri
        ),
        child: Image.asset(
          "./assets/icons/add.png",
          height: 30,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: _getPage(_selectedIndex),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return PostPage();
      case 1:
        return SearchPage();
      case 2:
        return MessagesPage();
      case 3:
        return ProfilePage();
      default:
        return Container();
    }
  }
}
