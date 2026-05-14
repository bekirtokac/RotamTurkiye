import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String personName;

  const ChatPage({Key? key, required this.personName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          personName,
          style: TextStyle(color: Colors.white), // Başlık rengini beyaz yap
        ),
        backgroundColor: Colors.black, // AppBar arka planını siyah yap
        iconTheme: IconThemeData(
            color: Colors.white), // AppBar ikonlarının rengini beyaz yap
      ),
      backgroundColor: Colors.black, // Sayfa arka planını siyah yap
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                // Örnek olarak gönderilen ve alınan mesajlar
                _buildMessajeBubble("Merhaba nasılsın?", false, "11:38"),
                _buildMessajeBubble(
                    "Merhaba, iyiyim sen nasılsın?", true, "11:56"),
                _buildMessajeBubble(
                    "Ben de iyiyim teşekkürler. Bugün ne yapmayı planlıyorsun? Ben bütün gün uyuyacağım.",
                    false,
                    "12:15"),
                _buildMessajeBubble(
                    "Aslında bir planım yok fakat eğer istersen dışarı çıkabiliriz. Yeni bir restoran açılmış ve bayılacaksın!",
                    true,
                    "12:16"),
              ],
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessajeBubble(String message, bool fromMe, String time) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topRight: fromMe ? Radius.circular(0) : Radius.circular(20),
            topLeft: fromMe ? Radius.circular(20) : Radius.circular(0),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              fromMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              time,
              style: TextStyle(color: Colors.white, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
