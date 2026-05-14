import 'package:flutter/material.dart';
import 'package:rotam_turkiye/screens/ChatPage.dart';
import 'package:rotam_turkiye/widgets/CustomInput.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kontaktların",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // AppBar arka planını siyah yap
      ),
      backgroundColor: Colors.black, // Sayfa arka planını siyah yap
      body: Column(
        children: [
          CustomInput(
            hintText: "Kontaktların içinde ara",
            leftIconName: "./assets/icons/search.png",
            rightIconName: "./assets/icons/menu.png",
            isPassword: false,
            inputType: InputType.TextField,
          ),
          SizedBox(height: 10), // Aralarına bir boşluk ekleyelim
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Mesajlar',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'İsteği Kabul Edenler',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10), // Aralarına bir boşluk ekleyelim
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemCount: 10, // Örnek için 10 kişi oluşturuyoruz
                  itemBuilder: (context, index) {
                    return _buildMessageCard(context, index);
                  },
                ),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Yatayda 3 öğe göster
                    crossAxisSpacing: 10, // Yatayda öğeler arasındaki boşluk
                    mainAxisSpacing: 10, // Dikeyde öğeler arasındaki boşluk
                  ),
                  itemCount: 10, // Örnek için 10 kişi oluşturuyoruz
                  itemBuilder: (context, index) {
                    return _buildAcceptedRequestItem(context, index);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedRequestItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Kart arka planını gri tonlarında yap
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            // Örnek olarak varsayılan bir profil fotoğrafı ekliyoruz
            backgroundImage: AssetImage('assets/icons/person.png'),
          ),
          SizedBox(height: 5),
          Text(
            "İsim $index",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, int index) {
    // Örnek bir kişi oluşturuyoruz
    final personName = "Kişi $index";
    final lastMessage = "Son Mesaj $index";
    final newMessageCount = index % 4; // Yeni gelen mesaj sayısını belirle

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: Colors.grey[900], // Kart arka planını gri tonlarında yap
      child: ListTile(
        leading: CircleAvatar(
          // Örnek olarak varsayılan bir profil fotoğrafı ekliyoruz
          backgroundImage: AssetImage('assets/icons/person.png'),
        ),
        title: Text(
          personName,
          style: TextStyle(color: Colors.white), // Başlık rengini beyaz yap
        ),
        subtitle: Row(
          children: [
            Text(
              lastMessage,
              style:
                  TextStyle(color: Colors.white), // Altbaşlık rengini beyaz yap
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$newMessageCount',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        onTap: () {
          // Mesaj detay sayfasına geçiş yapabilirsiniz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(personName: personName),
            ),
          );
        },
      ),
    );
  }
}
