import 'package:flutter/material.dart';

class DiscoverItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const DiscoverItem({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Tıklanıldığında belirtilen onTap fonksiyonunu çağırır
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF232323), // Rengi #232323 olarak ayarla
                    borderRadius: BorderRadius.circular(24), // Köşeleri yuvarla
                  ),
                  height: 80,
                  width:
                      80, // Kare olması için height ve width değerlerini aynı yap
                  child: Image.asset(
                    iconPath,
                    color: Colors.white,
                    fit: BoxFit.scaleDown, // İmajın boyutunu küçültmek için
                  ),
                ),
                SizedBox(width: 20), // Boşluk ekledik
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Image.asset(
                  "./assets/icons/right-arrow.png",
                  height: 30,
                  color: Colors.white,
                ),
              ],
            ),
            Divider(
              color: Color(0xFF282828), // Çizgi rengini belirtiyoruz
              thickness: 2, // Çizgi kalınlığını belirtiyoruz
              height: 20, // Çizgiye olan boşluğu belirtiyoruz
            ),
          ],
        ),
      ),
    );
  }
}
