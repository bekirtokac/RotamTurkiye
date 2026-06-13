import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // ─── State ───────────────────────────────────────────────────────────────
  String? _selectedImagePath;
  bool _isPosting = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ─── Fotoğraf Seçme ───────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (image != null && image.path.isNotEmpty) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ─── Gönderi Paylaşma (Firestore — Firebase Storage bypass) ─────────────
  Future<void> _sharePost() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir açıklama yaz veya fotoğraf ekle.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final currentUser = userModel.user;

    setState(() => _isPosting = true);

    try {
      // Firebase Storage kapalı — yerel yolu veya fallback URL'i Firestore'a yaz
      final String postImageUrl = _selectedImagePath != null
          ? _selectedImagePath! // Yerel yol (lokal gösterim için)
          : 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/500/300';

      await FirebaseFirestore.instance.collection('posts').add({
        'description': description,
        'location': _locationController.text.trim(),
        'postImageUrl': postImageUrl,
        'isLocalImage': _selectedImagePath != null,
        'userId': currentUser?.id ?? '',
        'userName': currentUser?.name ?? 'Anonim',
        'userPhotoUrl': currentUser?.photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gönderi paylaşıldı! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gönderi paylaşılamadı: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImagePath != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _isPosting ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Gönderi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fotoğraf Alanı ──────────────────────────────────────────
            GestureDetector(
              onTap: _isPosting ? null : _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasImage
                        ? Colors.redAccent.withValues(alpha: 0.7)
                        : Colors.white12,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                          ),
                          // Değiştir overlay
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _isPosting ? null : _pickImage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Değiştir',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Colors.redAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Fotoğraf Ekle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Galerinden bir fotoğraf seç',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Açıklama Alanı ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _descriptionController,
                enabled: !_isPosting,
                maxLines: 4,
                minLines: 2,
                maxLength: 300,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Bu anı anlat... 🗺️',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Konum Alanı ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      enabled: !_isPosting,
                      maxLines: 1,
                      maxLength: 80,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Konum — örn: Muğla, Fethiye',
                        hintStyle:
                            TextStyle(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                        counterStyle:
                            TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Paylaş Butonu (Alt kısım, büyük) ──────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isPosting ? null : _sharePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isPosting ? 'Paylaşılıyor...' : 'Paylaş',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
