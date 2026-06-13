import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rotam_turkiye/widgets/Post.dart';

class MyTravelBookPage extends StatefulWidget {
  const MyTravelBookPage({super.key});

  @override
  State<MyTravelBookPage> createState() => _MyTravelBookPageState();
}

class _MyTravelBookPageState extends State<MyTravelBookPage> {
  String? _localProfileImagePath;

  @override
  void initState() {
    super.initState();
    _loadLocalProfilePath();
  }

  Future<void> _loadLocalProfilePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString('local_profile_image_path');
      if (saved != null && saved.isNotEmpty) {
        final bool exists = await File(saved).exists();
        if (exists && mounted) {
          setState(() => _localProfileImagePath = saved);
        }
      }
    } catch (e) {
      debugPrint('MyTravelBookPage: SharedPreferences okuma hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Seyahat Defterim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.map_rounded),
                text: 'Keşiflerim',
              ),
              Tab(
                icon: Icon(Icons.favorite_rounded),
                text: 'Beğendiklerim',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: currentUserId.isEmpty
              ? const Center(
                  child: Text(
                    'Giriş yapmış bir kullanıcı bulunamadı.',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                )
              : TabBarView(
                  children: [
                    // Tab 1: Keşiflerim
                    _buildUserPostsStream(currentUserId),
                    // Tab 2: Beğendiklerim
                    _buildLikedPostsStream(currentUserId),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUserPostsStream(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.redAccent,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu: ${snapshot.error}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  color: Colors.white24,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz bir rota paylaşmadınız 🗺️',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String postUserId = data['userId'] as String? ?? '';
            final String description = (data['description'] as String? ?? '').isNotEmpty
                ? data['description'] as String
                : 'Paylaşım';
            final String userName = data['userName'] as String? ?? 'Anonim';
            final String userPhotoUrl = data['userPhotoUrl'] as String? ?? '';
            final String postImageUrl = data['postImageUrl'] as String? ?? '';

            // URL/Dosya yolu çözümlemesi
            final String resolvedImageUrl = postImageUrl.isEmpty
                ? 'https://picsum.photos/seed/rotam/500/300'
                : postImageUrl;
            final String resolvedProfileUrl = (userPhotoUrl.startsWith('http') ||
                    userPhotoUrl.startsWith('https'))
                ? userPhotoUrl
                : '';

            return Post(
              postId: doc.id,
              imageUrl: resolvedImageUrl,
              profileImageUrl: resolvedProfileUrl,
              username: userName,
              sharedLocation: description,
              location: data['location'] as String? ?? '',
              postUserId: postUserId,
              currentUserId: userId,
              localProfileImagePath: _localProfileImagePath,
            );
          },
        );
      },
    );
  }

  Widget _buildLikedPostsStream(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('likes', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.redAccent,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu: ${snapshot.error}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white24,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Beğendiğiniz bir rota bulunamadı 🤍',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final String postUserId = data['userId'] as String? ?? '';
            final String description = (data['description'] as String? ?? '').isNotEmpty
                ? data['description'] as String
                : 'Paylaşım';
            final String userName = data['userName'] as String? ?? 'Anonim';
            final String userPhotoUrl = data['userPhotoUrl'] as String? ?? '';
            final String postImageUrl = data['postImageUrl'] as String? ?? '';

            // URL/Dosya yolu çözümlemesi
            final String resolvedImageUrl = postImageUrl.isEmpty
                ? 'https://picsum.photos/seed/rotam/500/300'
                : postImageUrl;
            final String resolvedProfileUrl = (userPhotoUrl.startsWith('http') ||
                    userPhotoUrl.startsWith('https'))
                ? userPhotoUrl
                : '';

            return Post(
              postId: doc.id,
              imageUrl: resolvedImageUrl,
              profileImageUrl: resolvedProfileUrl,
              username: userName,
              sharedLocation: description,
              location: data['location'] as String? ?? '',
              postUserId: postUserId,
              currentUserId: userId,
              localProfileImagePath: _localProfileImagePath,
            );
          },
        );
      },
    );
  }
}
