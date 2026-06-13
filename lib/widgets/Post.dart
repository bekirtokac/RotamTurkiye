import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';

class Post extends StatefulWidget {
  final String postId;
  final String imageUrl;
  final String profileImageUrl;
  final String username;

  /// Açıklama metni (üstte belirgin gösterilir)
  final String sharedLocation;

  /// Konum bilgisi — örn: "Muğla, Fethiye"
  final String location;

  /// Gönderiyi paylaşan kullanıcının Firestore ID'si
  final String postUserId;

  /// Uygulamayı kullanan mevcut kullanıcının ID'si
  final String currentUserId;

  /// SharedPreferences'tan okunan yerel profil resmi yolu (nullable)
  final String? localProfileImagePath;

  const Post({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.username,
    required this.sharedLocation,
    this.location = '',
    this.postUserId = '',
    this.currentUserId = '',
    this.localProfileImagePath,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  // ─── Yardımcı: URL tipi ────────────────────────────────────────────────
  bool _isLocalPath(String url) =>
      url.isNotEmpty && !url.startsWith('http') && !url.startsWith('https');

  // ─── Gönderi Resmi ────────────────────────────────────────────────────
  Widget _buildPostImage() {
    if (_isLocalPath(widget.imageUrl)) {
      return Image.file(
        File(widget.imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 220,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: Colors.redAccent,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() => Container(
        height: 220,
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: Icon(Icons.broken_image_rounded,
              color: Colors.white24, size: 48),
        ),
      );

  // ─── Profil Fotoğrafı (3 Katmanlı Öncelik) ──────────────────────────
  Widget _buildAvatar() {
    // 1. Kendi gönderisiyse ve lokal resim varsa
    final bool isOwnPost = widget.postUserId.isNotEmpty &&
        widget.currentUserId.isNotEmpty &&
        widget.postUserId == widget.currentUserId;

    if (isOwnPost &&
        widget.localProfileImagePath != null &&
        widget.localProfileImagePath!.isNotEmpty) {
      final localFile = File(widget.localProfileImagePath!);
      if (localFile.existsSync()) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: FileImage(localFile),
          onBackgroundImageError: (_, __) {},
        );
      }
    }

    // 2. Firestore profileImageUrl
    if (_isLocalPath(widget.profileImageUrl)) {
      final f = File(widget.profileImageUrl);
      if (f.existsSync()) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: FileImage(f),
          onBackgroundImageError: (_, __) {},
        );
      }
    } else if (widget.profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(widget.profileImageUrl),
        onBackgroundImageError: (_, __) {},
        backgroundColor: const Color(0xFF2A2A2A),
      );
    }

    // 3. Fallback: baş harfiyle avatar
    final String initial =
        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.teal.withValues(alpha: 0.85),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // ─── Beğeni Butonu ────────────────────────────────────────────────────
  Widget _buildLikeButton() {
    final myUserModel = Provider.of<MyUserModel>(context, listen: false);
    final activeUserId = widget.currentUserId.isNotEmpty
        ? widget.currentUserId
        : (myUserModel.user?.id ?? '');

    if (activeUserId.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white54,
            size: 26,
          ),
          SizedBox(height: 3),
          Text(
            "0",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final List<dynamic> likes = data != null && data['likes'] != null
            ? data['likes'] as List<dynamic>
            : [];
        final bool isLiked = likes.contains(activeUserId);
        final int likeCount = likes.length;

        return GestureDetector(
          onTap: () async {
            final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
            if (isLiked) {
              await docRef.update({
                'likes': FieldValue.arrayRemove([activeUserId]),
              });
            } else {
              await docRef.update({
                'likes': FieldValue.arrayUnion([activeUserId]),
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isLiked),
                  color: isLiked ? Colors.redAccent : Colors.white54,
                  size: 26,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  likeCount.toString(),
                  key: ValueKey(likeCount),
                  style: TextStyle(
                    color: isLiked ? Colors.redAccent : Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Yorum Butonu ─────────────────────────────────────────────────────
  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: () => _openCommentsSheet(context),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .snapshots(),
        builder: (context, snap) {
          final count = snap.data?.docs.length ?? 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: Colors.white54, size: 26),
              const SizedBox(height: 3),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Yorum BottomSheet ────────────────────────────────────────────────
  void _openCommentsSheet(BuildContext context) {
    final TextEditingController commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // ── Handle ──────────────────────────────────────────
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Başlık ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Yorumlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white54, size: 20),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  // ── Yorum Listesi (StreamBuilder) ───────────────────
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('createdAt', descending: false)
                          .snapshots(),
                      builder: (ctx, snap) {
                        if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.redAccent),
                          );
                        }
                        final comments = snap.data?.docs ?? [];
                        if (comments.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    color: Colors.white12, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Henüz yorum yok.\nİlk yorumu sen yaz!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white30, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: comments.length,
                          itemBuilder: (_, i) {
                            final d = comments[i].data()
                                as Map<String, dynamic>;
                            final String cUser =
                                d['userName'] as String? ?? 'Anonim';
                            final String cText =
                                d['text'] as String? ?? '';
                            final String cPhoto =
                                d['userPhotoUrl'] as String? ?? '';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Mini avatar
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.teal
                                        .withValues(alpha: 0.8),
                                    backgroundImage: cPhoto.startsWith(
                                            'http')
                                        ? NetworkImage(cPhoto)
                                        : null,
                                    child: !cPhoto.startsWith('http')
                                        ? Text(
                                            cUser.isNotEmpty
                                                ? cUser[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cUser,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ── Yorum Giriş Alanı ─────────────────────────────
                  const Divider(color: Colors.white10, height: 1),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 10,
                      bottom:
                          MediaQuery.of(sheetCtx).viewInsets.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222222),
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: Colors.white12),
                            ),
                            child: TextField(
                              controller: commentCtrl,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Yorum yaz...',
                                hintStyle: TextStyle(
                                    color: Colors.white30, fontSize: 14),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) =>
                                  _submitComment(commentCtrl, sheetCtx),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              _submitComment(commentCtrl, sheetCtx),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => commentCtrl.dispose());
  }

  // ─── Yorum Gönder ─────────────────────────────────────────────────────
  Future<void> _submitComment(
      TextEditingController ctrl, BuildContext sheetCtx) async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    try {
      final userModel =
          Provider.of<MyUserModel>(context, listen: false);
      final user = userModel.user;

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'text': text,
        'userName': user?.name ?? 'Anonim',
        'userPhotoUrl': user?.photoUrl ?? '',
        'userId': user?.id ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ctrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum gönderilemedi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ─── Ana Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF282828), width: 1),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gönderi Resmi ──────────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: _buildPostImage(),
          ),

          // ── Konum Etiketi (sadece doluysa göster) ─────────────────────
          if (widget.location.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.location,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── Alt Bilgi Bölümü ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: widget.location.isNotEmpty ? 6 : 12,
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 12),

                // Açıklama (üstte) + Kullanıcı adı (altta)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sharedLocation.isNotEmpty
                            ? widget.sharedLocation
                            : 'Açıklama yok',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.username.isNotEmpty
                            ? widget.username
                            : 'Anonim',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Eylem Butonları (yorum + beğeni) ─────────────────
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCommentButton(),
                    const SizedBox(width: 16),
                    _buildLikeButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
