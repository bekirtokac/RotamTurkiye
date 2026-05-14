import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900], // Arka plan rengi
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 10.0), // Kenar boşlukları
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavBarItem("./assets/icons/home.png", currentIndex == 0,
              () => onTap(0)), // Home
          _buildNavBarItem("./assets/icons/search.png", currentIndex == 1,
              () => onTap(1)), // Search
          const SizedBox(
            width: 30,
          ),
          _buildNavBarItem("./assets/icons/chat-bubble.png", currentIndex == 2,
              () => onTap(2)), // Message
          _buildNavBarItem("./assets/icons/user.png", currentIndex == 3,
              () => onTap(3)), // Profile
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
      String iconData, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.blue
              : Colors.transparent, // Seçili ise mavi, değilse saydam
        ),
        child: Image.asset(
          iconData,
          color: isSelected
              ? Colors.white
              : Colors.grey, // Seçili ise beyaz, değilse gri
          height: 28.0,
        ),
      ),
    );
  }
}
