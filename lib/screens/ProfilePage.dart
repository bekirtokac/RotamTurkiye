import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/locator.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/services/firestore_db_service.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/pages/MyTravelBookPage.dart';
import 'package:rotam_turkiye/widgets/VisitedPlaceList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotam_turkiye/screens/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUpdatingProfile = false;
  final bool _isUpdatingPhoto = false;
  bool _isLoading = false;
  String? _localPhotoPath; // Firebase bypass: seçilen resmin yerel yolu
  final ImagePicker _imagePicker = ImagePicker();
  final FirestoreDBService _dbService = locator<FirestoreDBService>();

  UserModel? get _currentUser =>
      Provider.of<MyUserModel>(context, listen: false).user;

  // Firestore stream
  StreamSubscription<QuerySnapshot>? _visitedCitiesSubscription;
  StreamSubscription<QuerySnapshot>? _plannedRoutesSubscription;
  List<Map<String, dynamic>> _pastTrips = [];
  List<Map<String, dynamic>> _legacyFutureTrips = [];
  List<Map<String, dynamic>> _newFutureTrips = [];
  List<Map<String, dynamic>> _futureTrips = [];
  int? _userRank;

  @override
  void initState() {
    super.initState();
    // Kullanıcı verisi yüklendikten sonra stream'i başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningVisitedCities();
      _startListeningPlannedRoutes();
      _loadLocalPhotoPath(); // SharedPreferences'tan kaydedilmiş fotoğrafı yükle
    });
  }

  @override
  void dispose() {
    _visitedCitiesSubscription?.cancel();
    _plannedRoutesSubscription?.cancel();
    super.dispose();
  }

  /// SharedPreferences'tan daha önce seçilmiş profil fotoğrafı yolunu okur.
  /// Dosya hala diskette duruyorsa state'e atar; yoksa kaydı temizler.
  Future<void> _loadLocalPhotoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString('local_profile_image_path');
      if (saved != null && saved.isNotEmpty) {
        final bool stillExists = await File(saved).exists();
        if (stillExists) {
          if (mounted) {
            setState(() {
              _localPhotoPath = saved;
            });
          }
        } else {
          // Dosya silindi veya taşındı — kaydı temizle
          await prefs.remove('local_profile_image_path');
        }
      }
    } catch (e) {
      print('SharedPreferences okuma hatası: $e');
    }
  }

  Future<void> _loadUserRank(String userId, int score) async {
    try {
      final rank = await _dbService.getUserRank(score);
      if (mounted) {
        setState(() {
          _userRank = rank;
        });
      }
    } catch (e) {
      print("Sıralama yüklenirken hata oluştu: $e");
    }
  }

  void _startListeningPlannedRoutes() {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final user = userModel.user;
    if (user == null) return;

    _plannedRoutesSubscription =
        _dbService.getPlannedRoutes(user.id).listen((snapshot) {
      if (!mounted) return;

      final routes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'docId': doc.id,
          'isPlannedRoute': true,
        };
      }).toList();

      setState(() {
        _newFutureTrips = routes;
        _futureTrips = [..._legacyFutureTrips, ..._newFutureTrips];
      });
    });
  }

  void _startListeningVisitedCities() {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final user = userModel.user;
    if (user == null) return;

    _visitedCitiesSubscription =
        _dbService.getVisitedCities(user.id).listen((snapshot) {
      if (!mounted) return;

      final allTrips = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'docId': doc.id,
          'isPlannedRoute': false,
        };
      }).toList();

      // Tarih parse: DD/MM/YYYY formatını DateTime'a çevir
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<Map<String, dynamic>> past = [];
      final List<Map<String, dynamic>> legacyFuture = [];

      for (var trip in allTrips) {
        final dateStr = (trip['date'] ?? '') as String;
        final parsedDate = _parseDate(dateStr);
        if (parsedDate != null && parsedDate.isAfter(today)) {
          legacyFuture.add(trip);
        } else {
          past.add(trip);
        }
      }

      final calculatedPoints = VisitedPlaceList.calculateTotalPoints(past);
      if (user.score != calculatedPoints) {
        userModel.updateUserScore(calculatedPoints).then((_) {
          _loadUserRank(user.id, calculatedPoints);
        });
      } else {
        _loadUserRank(user.id, calculatedPoints);
      }

      setState(() {
        _pastTrips = past;
        _legacyFutureTrips = legacyFuture;
        _futureTrips = [..._legacyFutureTrips, ..._newFutureTrips];
      });
    });
  }

  /// DD/MM/YYYY formatındaki string'i DateTime'a parse eder.
  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (_) {}
    return null;
  }

  // ─── 81 İl Listesi ───
  static const List<String> _turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  // ─── Çıkış ───
  void _signOut(BuildContext context) async {
    try {
      final userModel = Provider.of<MyUserModel>(context, listen: false);
      await userModel.signOut();

      // Firebase Auth oturumunu kapat
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Çıkış hatası yakalandı: $e");
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  // ─── Profil Fotoğrafı ───
  ImageProvider? _profileImageProvider(String? photoUrl) {
    // Öncelik: yerel dosya (Firebase bypass modu)
    if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty) {
      return FileImage(File(_localPhotoPath!));
    }
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return NetworkImage(photoUrl);
    if (photoUrl.startsWith('assets/')) return AssetImage(photoUrl);
    return null;
  }

  Future<void> _pickAndUploadProfilePhoto(BuildContext context) async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);

    if (userModel.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı bilgileri yüklenemedi."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 50,
                    child: Divider(thickness: 4, color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Fotoğrafı Değiştir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: Colors.redAccent, size: 26),
                  title: const Text(
                    "Galeriden Seç",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickAndProcessImage(ImageSource.gallery);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: Colors.redAccent, size: 26),
                  title: const Text(
                    "Kamera ile Çek",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickAndProcessImage(ImageSource.camera);
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.folder_open_rounded,
                      color: Colors.redAccent, size: 26),
                  title: const Text(
                    "Dosyalardan Seç",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _pickAndProcessImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
    } catch (e) {
      print("ImagePicker error: $e");
    }

    if (image == null || image.path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fotoğraf seçilmedi veya geçersiz dosya yolu."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final File imageFile = File(image.path);
    try {
      final bool fileExists = await imageFile.exists();
      if (!fileExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Seçilen fotoğraf dosyası yerel diskte bulunamadı."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    } catch (e) {
      print("Error checking if file exists: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dosya kontrolü sırasında hata oluştu: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    await _updateProfilePicture(image.path);
  }

  /// Firebase Storage BYPASS — tamamen yerel (offline) çalışır.
  /// Seçilen resim sadece cihaz hafızasından gösterilir,
  /// sunucuya hiçbir istek atılmaz.
  Future<void> _updateProfilePicture(String localPath) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Dosyanın gerçekten okunabilir olduğunu doğrula
      final File file = File(localPath);
      final bool exists = await file.exists();
      if (!exists) {
        throw Exception("Dosya bulunamadı: $localPath");
      }

      // Yerel yolu state'e aktar — UI anında güncellenir
      setState(() {
        _localPhotoPath = localPath;
        _isLoading = false;
      });

      // SharedPreferences'a kalıcı olarak mühürle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_profile_image_path', localPath);
      print('LOKAL FOTOĞRAF HAFIZAYA KAYDEDILDI: $localPath');

      // TODO: Firebase Storage planı aktive edildiğinde aşağıdaki blok
      // yorum satırından çıkarılacak:
      //
      // final storageRef = FirebaseStorage.instance
      //     .ref()
      //     .child("profile_images")
      //     .child("${_currentUser?.id ?? 'user'}.jpg");
      // final Uint8List bytes = await file.readAsBytes();
      // await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      // final String newDownloadUrl = await storageRef.getDownloadURL();
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(_currentUser?.id)
      //     .update({'photoUrl': newDownloadUrl});
      // if (mounted) {
      //   final userModel = Provider.of<MyUserModel>(context, listen: false);
      //   await userModel.reloadUser();
      // }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print("LOKAL FOTOĞRAF HATASI: ${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildProfileAvatar(String? photoUrl, bool isModelBusy) {
    const double radius = 100;
    // _localPhotoPath doluysa FileImage, yoksa network/asset URL'i kullan
    final imageProvider = _profileImageProvider(photoUrl);
    final bool showLoading = _isUpdatingPhoto || _isLoading || isModelBusy;

    return GestureDetector(
      onTap: showLoading ? null : () => _pickAndUploadProfilePhoto(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white12,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 80, color: Colors.white54)
                : null,
          ),
          if (showLoading)
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.black87,
                size: showLoading ? 0 : 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profil Düzenleme BottomSheet ───
  Future<void> _openEditProfileBottomSheet(BuildContext context) async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final currentUser = userModel.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı bilgileri yüklenemedi."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final nameParts = currentUser.name.trim().split(RegExp(r"\s+"));
    final nameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts.first : "",
    );
    final surnameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "",
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 50,
                  child: Divider(
                    thickness: 4,
                    color: Colors.white24,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Profili Düzenle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Ad",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: surnameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Soyad",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isUpdatingProfile
                      ? null
                      : () async {
                          final newName = nameController.text.trim();
                          final newSurname = surnameController.text.trim();
                          final fullName = [newName, newSurname]
                              .where((part) => part.isNotEmpty)
                              .join(" ");

                          if (fullName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Ad ve soyad boş bırakılamaz."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setState(() => _isUpdatingProfile = true);
                          final isSaved = await userModel.saveUserDetails(
                            currentUser.id,
                            fullName,
                            currentUser.city,
                          );
                          if (!mounted) return;
                          setState(() => _isUpdatingProfile = false);

                          if (isSaved) {
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profil bilgileri güncellendi."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Güncelleme sırasında hata oluştu."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  icon: _isUpdatingProfile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt_rounded),
                  label:
                      Text(_isUpdatingProfile ? "Kaydediliyor..." : "Kaydet"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Gezilen Yer Ekleme BottomSheet ───
  Future<void> _openAddVisitedCitySheet(BuildContext context) async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final currentUser = userModel.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı bilgileri yüklenemedi."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String? selectedCity;
    final daysController = TextEditingController();
    final dateController = TextEditingController();
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  const Center(
                    child: SizedBox(
                      width: 50,
                      child: Divider(thickness: 4, color: Colors.white24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Başlık
                  Row(
                    children: [
                      Icon(Icons.add_location_alt_rounded,
                          color: Colors.redAccent, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        "Gezilen Yer Ekle",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Şehir Seçimi — Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCity,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Şehir İsmi",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.location_city_rounded,
                          color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 300,
                    items: _turkishCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setSheetState(() => selectedCity = value);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Kaldığı Gün Sayısı
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Kaldığı Gün Sayısı",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.nights_stay_rounded,
                          color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Ziyaret Tarihi — DatePicker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (ctx, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.redAccent,
                                surface: Color(0xFF1E1E1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() {
                          dateController.text =
                              '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Ziyaret Tarihi",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.calendar_month_rounded,
                              color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "GG/AA/YYYY",
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              // Validasyon
                              if (selectedCity == null ||
                                  selectedCity!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lütfen bir şehir seçin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              final days =
                                  int.tryParse(daysController.text.trim());
                              if (days == null || days <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Geçerli bir gün sayısı girin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              if (dateController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lütfen bir tarih seçin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              setSheetState(() => isSaving = true);

                              final success = await _dbService.addVisitedCity(
                                currentUser.id,
                                selectedCity!,
                                days,
                                dateController.text.trim(),
                              );

                              if (!context.mounted) return;

                              setSheetState(() => isSaving = false);

                              if (success) {
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Gezilen yer başarıyla eklendi!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Kayıt sırasında hata oluştu."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(isSaving ? "Kaydediliyor..." : "Kaydet"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Gezilen Yer Silme ───
  Future<void> _deleteVisitedCity(String docId) async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final user = userModel.user;
    if (user == null) return;

    final success = await _dbService.deleteVisitedCity(user.id, docId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? "Kayıt silindi." : "Silme sırasında hata oluştu."),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // ─── Planlanan Rota Silme (Onay Diyaloğu ile) ───
  Future<void> _confirmDeletePlannedTrip(Map<String, dynamic> trip) async {
    final docId = trip['docId'] as String?;
    if (docId == null) return;

    final city = (trip['city'] ?? 'Bilinmeyen') as String;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Planı Sil",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
              children: [
                const TextSpan(text: "\""),
                TextSpan(
                  text: city,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                    text:
                        "\" seyahat planını silmek istediğinize emin misiniz?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                "İptal",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text("Sil"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final user = userModel.user;
    if (user == null) return;

    final bool isPlannedRoute = trip['isPlannedRoute'] ?? false;
    final success = isPlannedRoute
        ? await _dbService.deletePlannedRoute(user.id, docId)
        : await _dbService.deleteVisitedCity(user.id, docId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Seyahat planı silindi."
            : "Silme sırasında hata oluştu."),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // ─── Planlanan Rota Düzenleme BottomSheet ───
  Future<void> _openEditPlannedTripSheet(
      BuildContext context, Map<String, dynamic> trip) async {
    final userModel = Provider.of<MyUserModel>(context, listen: false);
    final currentUser = userModel.user;
    if (currentUser == null) return;

    final docId = trip['docId'] as String?;
    if (docId == null) return;

    final currentCity = (trip['city'] ?? '') as String;
    final currentDays = (trip['spent_day'] ?? trip['days'] ?? 0) as int;
    final currentDate = (trip['date'] ?? '') as String;

    String? selectedCity =
        _turkishCities.contains(currentCity) ? currentCity : null;
    final daysController =
        TextEditingController(text: currentDays > 0 ? '$currentDays' : '');
    final dateController = TextEditingController(text: currentDate);
    bool isUpdating = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  const Center(
                    child: SizedBox(
                      width: 50,
                      child: Divider(thickness: 4, color: Colors.white24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Başlık
                  Row(
                    children: [
                      Icon(Icons.edit_location_alt_rounded,
                          color: Colors.orangeAccent, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        "Planı Düzenle",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Şehir Seçimi
                  DropdownButtonFormField<String>(
                    initialValue: selectedCity,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Şehir İsmi",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.location_city_rounded,
                          color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 300,
                    items: _turkishCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setSheetState(() => selectedCity = value);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Gün Sayısı
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Kaldığı Gün Sayısı",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.nights_stay_rounded,
                          color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tarih
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate:
                            _parseDate(dateController.text) ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (ctx, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.orangeAccent,
                                surface: Color(0xFF1E1E1E),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() {
                          dateController.text =
                              '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Tarih",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.calendar_month_rounded,
                              color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Güncelle Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isUpdating
                          ? null
                          : () async {
                              if (selectedCity == null ||
                                  selectedCity!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lütfen bir şehir seçin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              final days =
                                  int.tryParse(daysController.text.trim());
                              if (days == null || days <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Geçerli bir gün sayısı girin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              if (dateController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lütfen bir tarih seçin."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              setSheetState(() => isUpdating = true);

                              final bool isPlannedRoute = trip['isPlannedRoute'] ?? false;
                              final success = isPlannedRoute
                                  ? await _dbService.updatePlannedRoute(
                                      currentUser.id,
                                      docId,
                                      selectedCity!,
                                      days,
                                      dateController.text.trim(),
                                    )
                                  : await _dbService.updateVisitedCity(
                                      currentUser.id,
                                      docId,
                                      selectedCity!,
                                      days,
                                      dateController.text.trim(),
                                    );

                              if (!context.mounted) return;
                              setSheetState(() => isUpdating = false);

                              if (success) {
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Plan başarıyla güncellendi!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Güncelleme sırasında hata oluştu."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      icon: isUpdating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.update_rounded),
                      label: Text(isUpdating ? "Güncelleniyor..." : "Güncelle"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Bölüm Başlığı Widget'ı ───
  Widget _buildSectionHeader(String title, IconData icon,
      {VoidCallback? onActionTap, IconData? actionIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onActionTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon ?? Icons.add_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        "Ekle",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Planlanan Rota Card'ı ───
  Widget _buildPlannedTripCard(Map<String, dynamic> trip) {
    final city = (trip['city'] ?? 'Bilinmeyen') as String;
    final date = (trip['date'] ?? '') as String;
    final days = (trip['spent_day'] ?? trip['days'] ?? 0) as int;
    final budget = trip['budget'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: İkon + Şehir + Aksiyon butonları
            Row(
              children: [
                // İkon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      color: Colors.redAccent, size: 26),
                ),
                const SizedBox(width: 14),
                // Şehir adı
                Expanded(
                  child: Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Düzenle butonu
                _buildCardActionButton(
                  icon: Icons.edit_rounded,
                  color: Colors.orangeAccent,
                  tooltip: "Düzenle",
                  onTap: () => _openEditPlannedTripSheet(context, trip),
                ),
                const SizedBox(width: 4),
                // Sil butonu
                _buildCardActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: "Sil",
                  onTap: () => _confirmDeletePlannedTrip(trip),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Alt satır: Detaylar + Kalan gün badge
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(Icons.calendar_today_rounded, date),
                      _buildInfoChip(Icons.nights_stay_rounded, "$days gün"),
                      if (budget != null)
                        _buildInfoChip(
                            Icons.account_balance_wallet_rounded, "₺$budget"),
                    ],
                  ),
                ),
                _buildTripDaysBadge(days),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTripDaysBadge(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$days",
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "gün",
            style: TextStyle(
              color: Colors.redAccent.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stat Kartı ───
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<MyUserModel>(context);
    final user = userModel.user;

    // Dinamik hesaplamalar
    final totalPoints = VisitedPlaceList.calculateTotalPoints(_pastTrips);
    final uniqueCities = VisitedPlaceList.getUniqueCityCount(_pastTrips);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded, color: Colors.white),
            tooltip: 'Seyahat Defterim',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyTravelBookPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            _buildProfileAvatar(
                user?.photoUrl, userModel.state == ViewState.Busy),
            const SizedBox(height: 20),
            Text(
              user?.name ?? "İsimsiz Kullanıcı",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.city ?? "Şehir belirtilmemiş",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // 1. ELEMAN: ZİRVE ROZETİ (SOLDA)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _userRank != null
                            ? const LinearGradient(
                                colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
                              )
                            : const LinearGradient(
                                colors: [Colors.white12, Colors.white12],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        border: _userRank != null
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1)
                            : Border.all(color: Colors.white24, width: 1),
                        boxShadow: _userRank != null
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF39C12)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: _userRank != null
                                ? Colors.black
                                : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _userRank != null
                                ? "Zirve #$_userRank"
                                : "Zirve #--",
                            style: TextStyle(
                              color: _userRank != null
                                  ? Colors.black
                                  : Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 2. ELEMAN: PROFİLİ DÜZENLE (SAĞDA)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                        onPressed: () => _openEditProfileBottomSheet(context),
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: const Text(
                          "Profili Düzenle",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── İstatistik Kartları ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard("Puanlar", "$totalPoints", Icons.star_rounded),
                  _buildStatCard("Gezilen Şehir", "$uniqueCities",
                      Icons.location_city_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── GEZDİĞİM YERLER ───
            _buildSectionHeader(
              "Gezdiğim Yerler",
              Icons.explore_rounded,
              onActionTap: () => _openAddVisitedCitySheet(context),
              actionIcon: Icons.add_rounded,
            ),
            const SizedBox(height: 4),
            VisitedPlaceList(
              places: _pastTrips,
              onDelete: _deleteVisitedCity,
            ),
            const SizedBox(height: 24),

            // ─── PLANLANAN ROTALAR ───
            _buildSectionHeader(
              "Planlanan Rotalar",
              Icons.map_rounded,
            ),
            const SizedBox(height: 4),
            if (_futureTrips.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.route_rounded,
                          color: Colors.white24, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        "Henüz planlanmış rota yok",
                        style: TextStyle(color: Colors.white38, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Yeni seyahat oluşturarak rota ekleyebilirsiniz",
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_futureTrips.length, (index) {
                return _buildPlannedTripCard(_futureTrips[index]);
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
