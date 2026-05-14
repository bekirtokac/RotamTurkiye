import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String imageUrl;
  final String profileImageUrl;
  final String username;
  final String sharedLocation;

  const Post({
    Key? key,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.username,
    required this.sharedLocation,
  }) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(
          color: Color(0xFF282828),
          width: 1.0,
        ),
      ),
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              title: Text(
                widget.username,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                widget.sharedLocation,
                style: TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                icon: isLiked
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                color: isLiked ? Colors.red : Colors.white,
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
