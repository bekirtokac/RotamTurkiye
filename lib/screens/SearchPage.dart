import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/ChatPage.dart';
import 'package:rotam_turkiye/screens/PublicProfilePage.dart';
import 'package:rotam_turkiye/pages/WhereToStayPage.dart';
import 'package:rotam_turkiye/screens/AlertsPage.dart';
import 'package:rotam_turkiye/screens/TravelCompanionsPage.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/widgets/Post.dart';
import 'package:rotam_turkiye/pages/EvliyaCelebiPage.dart';
import 'package:rotam_turkiye/pages/VedatMilorPage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SearchPage — Çift Sekmeli (Gönderiler & Gezginler) Dinamik Keşfet Arayüzü
// ─────────────────────────────────────────────────────────────────────────────

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ── Arama durumu ──────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  // ── Sıralama durumu: "new" = En Yeni, "popular" = En Popüler ─────────────
  String currentFilter = "new";

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Aramayı tetikle ────────────────────────────────────────────────────────
  void _triggerSearch(String value) {
    final trimmed = value.trim();
    if (!mounted) return;
    setState(() {
      _searchQuery = trimmed;
      _isSearching = trimmed.isNotEmpty;
    });
  }

  // ── Aramayı temizle ───────────────────────────────────────────────────────
  void _clearSearch() {
    _searchCtrl.clear();
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  Future<void> _navigateToMap() async {
    _searchFocusNode.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WhereToStayPage(),
      ),
    );
    if (!mounted) return;
    _searchFocusNode.unfocus();
    setState(() {});
  }

  Future<void> _navigateToAlerts() async {
    _searchFocusNode.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AlertsPage(),
      ),
    );
    if (!mounted) return;
    _searchFocusNode.unfocus();
    setState(() {});
  }

  Future<void> _navigateToCompanions() async {
    _searchFocusNode.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TravelCompanionsPage(),
      ),
    );
    if (!mounted) return;
    _searchFocusNode.unfocus();
    setState(() {});
  }

  Future<void> _openEvliyaCelebiMap() async {
    _searchFocusNode.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EvliyaCelebiPage(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openVedatMilorPage() async {
    _searchFocusNode.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VedatMilorPage(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _isSearching
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ── Başlık ──────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Keşfet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.map_outlined,
                                    color: Colors.redAccent, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Türkiye\'yi Keşfet',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Arama Çubuğu ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SearchBar(
                        controller: _searchCtrl,
                        focusNode: _searchFocusNode,
                        onChanged: _triggerSearch,
                        onSubmitted: _triggerSearch,
                        onClear: _clearSearch,
                        isSearching: _isSearching,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: _SearchResultsView(
                          key: ValueKey('results_$_searchQuery'),
                          query: _searchQuery,
                          currentFilter: currentFilter,
                          onSortChanged: (filter) {
                            if (!mounted) return;
                            setState(() => currentFilter = filter);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Başlık ──────────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Row(
                          children: [
                            const Text(
                              'Keşfet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.map_outlined,
                                      color: Colors.redAccent, size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Türkiye\'yi Keşfet',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Arama Çubuğu ─────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SearchBar(
                          controller: _searchCtrl,
                          focusNode: _searchFocusNode,
                          onChanged: _triggerSearch,
                          onSubmitted: _triggerSearch,
                          onClear: _clearSearch,
                          isSearching: _isSearching,
                        ),
                      ),

                      SizedBox(height: _searchFocusNode.hasFocus ? 12 : 20),

                      _DiscoverIdleView(
                        key: const ValueKey('idle'),
                        searchFocusNode: _searchFocusNode,
                        searchController: _searchCtrl,
                        onCitySelected: (city) {
                          _searchCtrl.text = city;
                          _triggerSearch(city);
                        },
                        onMapTap: _navigateToMap,
                        onAlertsTap: _navigateToAlerts,
                        onCompanionsTap: _navigateToCompanions,
                        onEvliyaCelebiTap: _openEvliyaCelebiMap,
                        onVedatMilorTap: _openVedatMilorPage,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arama Çubuğu Widget'ı
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool isSearching;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSearching
              ? Colors.redAccent.withValues(alpha: 0.6)
              : Colors.white12,
          width: 1.2,
        ),
        boxShadow: isSearching
            ? [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  blurRadius: 14,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: TextField(
        autofocus: false,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '🔍  Şehir ara... (İstanbul, Kapadokya...)',
          hintStyle: const TextStyle(
            color: Colors.white30,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.search_rounded,
                color: Colors.white38, size: 22),
          ),
          suffixIcon: isSearching
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white38, size: 20),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arama Yok → Boş Keşfet Ekranı
// ─────────────────────────────────────────────────────────────────────────────
class _DiscoverIdleView extends StatelessWidget {
  final ValueChanged<String> onCitySelected;
  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final VoidCallback onMapTap;
  final VoidCallback onAlertsTap;
  final VoidCallback onCompanionsTap;
  final VoidCallback onEvliyaCelebiTap;
  final VoidCallback onVedatMilorTap;

  const _DiscoverIdleView({
    super.key,
    required this.onCitySelected,
    required this.searchFocusNode,
    required this.searchController,
    required this.onMapTap,
    required this.onAlertsTap,
    required this.onCompanionsTap,
    required this.onEvliyaCelebiTap,
    required this.onVedatMilorTap,
  });

  static const _cities = [
    ('🌉', 'İstanbul'),
    ('🏖️', 'İzmir'),
    ('🌊', 'Antalya'),
    ('🪂', 'Muğla'),
    ('🎈', 'Kapadokya'),
    ('🍃', 'Rize'),
    ('⛷️', 'Uludağ'),
    ('🏔️', 'Trabzon'),
    ('🛶', 'Eskişehir'),
    ('🐴', 'Çanakkale'),
    ('🌀', 'Konya'),
    ('🏡', 'Safranbolu'),
  ];

  @override
  Widget build(BuildContext context) {
    final showPopular = searchFocusNode.hasFocus && searchController.text.isEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (showPopular) ...[
            // ── Popüler Şehirler ──────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'Popüler Destinasyonlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _cities.map((c) {
                return _CityChip(
                  emoji: c.$1,
                  city: c.$2,
                  onTap: () => onCitySelected(c.$2),
                );
              }).toList(),
            ),
            const SizedBox(height: 20), // 36'dan 20'ye düşürülerek boşluk kapatıldı
          ],

          // ── Hint Kartı ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.travel_explore_rounded,
                      color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Şehir bazlı ara!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Yukarıdaki çubukta bir şehir adı yaz ve o şehre ait tüm gönderileri & gezginleri keşfet.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!searchFocusNode.hasFocus) ...[
            const SizedBox(height: 20),
            // ── 3’lü Hızlı Menü Butonları (KESİNLİKLE DOKUNULMADI) ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickMenuCard(
                  context: context,
                  icon: Icons.hotel_rounded,
                  title: "Nerede Kalınır?",
                  onTap: onMapTap,
                ),
                _buildQuickMenuCard(
                  context: context,
                  icon: Icons.wb_sunny_rounded,
                  title: "Anlık Durum",
                  onTap: onAlertsTap,
                ),
                _buildQuickMenuCard(
                  context: context,
                  icon: Icons.group_rounded,
                  title: "Yol Arkadaşı",
                  onTap: onCompanionsTap,
                ),
              ],
            ),

            // ── Önerilen Keşif Rotaları Feed Başlığı ───────────────────────
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '🦭 Önerilen Keşif Rotaları',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Evliya Çelebi Keşif Kartı ──────────────────────────────
            GestureDetector(
              onTap: onEvliyaCelebiTap,
              child: Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Arka plan görseli
                      Image.network(
                        'https://picsum.photos/seed/ottoman/800/400',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1A1412),
                        ),
                      ),
                      // Karartma gradient katmanı
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      // İçerik
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            // Sağ üst ikon
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.history_edu_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            // Sol alt metinler
                            Positioned(
                              left: 0,
                              bottom: 0,
                              right: 48,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Tarihi Rota',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Evliya Çelebi Seyahatnamesi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tarihi rotalar ve canlı seyahat notları',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Vedat Milor Gurme Rotaları Kartı ──────────────────────────────
            GestureDetector(
              onTap: onVedatMilorTap,
              child: Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://picsum.photos/seed/restaurant/800/400',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1E1C1A),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              right: 48,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Gurme Rota',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Vedat Milor Gurme Rotaları',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Şehir şehir en dürüst esnaf lokantaları ve lezzet durakları',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Popüler Şehir Çipi ────────────────────────────────────────────────────────
class _CityChip extends StatelessWidget {
  final String emoji;
  final String city;
  final VoidCallback onTap;

  const _CityChip({
    required this.emoji,
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            '$emoji  $city',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arama Sonuçları Ana View (Sekmeler + İçerik)
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResultsView extends StatelessWidget {
  final String query;
  final String currentFilter;
  final ValueChanged<String> onSortChanged;

  const _SearchResultsView({
    super.key,
    required this.query,
    required this.currentFilter,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: tabController,
      builder: (context, child) {
        final activeTab = tabController.index;
        return Column(
          children: [
            // ── Sekme Seçici ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _TabSelector(),
            ),

            // ── Sıralama Çipleri (sadece Gönderiler sekmesinde) ──────────
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _SortChips(
                  currentFilter: currentFilter,
                  onChanged: onSortChanged,
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: activeTab == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),

            const SizedBox(height: 8),

            // ── Sonuç Listesi ─────────────────────────────────────────────
            Expanded(
              child: activeTab == 0
                  ? _PostsResultList(query: query, currentFilter: currentFilter)
                  : _ExplorersResultList(query: query),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Seçici (Gönderiler / Gezginler)
// ─────────────────────────────────────────────────────────────────────────────
class _TabSelector extends StatelessWidget {
  const _TabSelector();

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);

    // ListenableBuilder ile tab index değişince butonlar yeniden çizilir
    return ListenableBuilder(
      listenable: tabController,
      builder: (context, child) {
        final activeTab = tabController.index;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              _TabButton(
                label: '📬  Gönderiler',
                isActive: activeTab == 0,
                onTap: () => tabController.animateTo(0),
              ),
              _TabButton(
                label: '👥  Gezginler',
                isActive: activeTab == 1,
                onTap: () => tabController.animateTo(1),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sıralama Çipleri
// ─────────────────────────────────────────────────────────────────────────────
class _SortChips extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onChanged;

  const _SortChips({required this.currentFilter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SortChip(
          label: '📅  En Yeni',
          isSelected: currentFilter == "new",
          onTap: () {
            if (currentFilter == "new") return;
            onChanged("new");
          },
        ),
        const SizedBox(width: 10),
        _SortChip(
          label: '🔥  En Popüler',
          isSelected: currentFilter == "popular",
          onTap: () {
            if (currentFilter == "popular") return;
            onChanged("popular");
          },
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gönderiler Sekme İçeriği (Firestore bağlı)
// ─────────────────────────────────────────────────────────────────────────────
class _PostsResultList extends StatelessWidget {
  final String query;
  final String currentFilter; // "new" veya "popular"

  const _PostsResultList({
    required this.query,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    // Her zaman createdAt ile çekiyoruz — Firestore composite index hatasını önlüyoruz
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // ── Yükleniyor ──────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        // ── Hata ────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          );
        }

        // ── Filtrele: location veya description query içeriyor mu? ───────
        final lowerQuery = query.toLowerCase();
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final location =
              (data['location'] as String? ?? '').toLowerCase();
          final description =
              (data['description'] as String? ?? '').toLowerCase();
          return location.contains(lowerQuery) ||
              description.contains(lowerQuery);
        }).toList();

        // ── Lokal sıralama: orijinal listeyi bozmadan kopya üzerinde sırala ─
        final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
        if (currentFilter == "popular") {
          sortedDocs.sort((a, b) {
            final aLikes =
                ((a.data() as Map<String, dynamic>)['likeCount'] as num?)
                    ?.toInt() ??
                    0;
            final bLikes =
                ((b.data() as Map<String, dynamic>)['likeCount'] as num?)
                    ?.toInt() ??
                    0;
            return bLikes.compareTo(aLikes);
          });
        }

        // ── Sonuç Yok ────────────────────────────────────────────────────
        if (sortedDocs.isEmpty) {
          return _EmptyState(
            icon: Icons.photo_album_outlined,
            message:
                '"$query" için gönderi bulunamadı.\nFarklı bir şehir dene! 🗺️',
          );
        }

        // ── Gönderi Listesi ──────────────────────────────────────────────
        return ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data =
                  sortedDocs[index].data() as Map<String, dynamic>;
              final String postImageUrl =
                  data['postImageUrl'] as String? ?? '';

              final String resolvedImageUrl = postImageUrl.isEmpty
                  ? 'https://picsum.photos/seed/rotam/500/300'
                  : postImageUrl;

              final String profileUrl =
                  data['userPhotoUrl'] as String? ?? '';
              final String resolvedProfileUrl =
                  (profileUrl.startsWith('http') ||
                          profileUrl.startsWith('https'))
                      ? profileUrl
                      : '';

              return Post(
                postId: sortedDocs[index].id,
                imageUrl: resolvedImageUrl,
                profileImageUrl: resolvedProfileUrl,
                username: data['userName'] as String? ?? 'Anonim',
                sharedLocation:
                    (data['description'] as String? ?? '').isNotEmpty
                        ? data['description'] as String
                        : 'Paylaşım',
                location: data['location'] as String? ?? '',
                postUserId: data['userId'] as String? ?? '',
                currentUserId: '',
                localProfileImagePath: null,
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gezginler Sekme İçeriği (Firestore bağlı — users koleksiyonu)
// ─────────────────────────────────────────────────────────────────────────────
class _ExplorersResultList extends StatelessWidget {
  final String query;

  const _ExplorersResultList({required this.query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // ── Yükleniyor ──────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        // ── Hata ────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          );
        }

        // ── Filtrele: kullanıcının şehri veya adı eşleşiyor mu? ─────────
        final lowerQuery = query.toLowerCase();
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final city = (data['city'] as String? ?? '').toLowerCase();
          final name = (data['name'] as String? ?? '').toLowerCase();
          return city.contains(lowerQuery) || name.contains(lowerQuery);
        }).toList();

        // ── Sonuç Yok ────────────────────────────────────────────────────
        if (docs.isEmpty) {
          return _EmptyState(
            icon: Icons.person_search_outlined,
            message:
                '"$query" için gezgin bulunamadı.\nBu şehri keşfeden ilk kişi sen ol! 🧭',
          );
        }

        // ── Gezgin Listesi ───────────────────────────────────────────────
        return ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String name =
                  data['name'] as String? ?? 'Anonim Gezgin';
              final String city = data['city'] as String? ?? '';
              final String photoUrl =
                  data['photoUrl'] as String? ?? '';
              final int score =
                  (data['score'] as num?)?.toInt() ?? 0;
              final String initial =
                  name.isNotEmpty ? name[0].toUpperCase() : '?';
              final String userId = docs[index].id;

              return _ExplorerCard(
                userId: userId,
                name: name,
                city: city,
                photoUrl: photoUrl,
                score: score,
                initial: initial,
                rank: index + 1,
              );
            },
          ),
        );
      },
    );
  }
}

// ── Gezgin Kartı ──────────────────────────────────────────────────────────────
class _ExplorerCard extends StatelessWidget {
  final String userId;
  final String name;
  final String city;
  final String photoUrl;
  final int score;
  final String initial;
  final int rank;

  const _ExplorerCard({
    required this.userId,
    required this.name,
    required this.city,
    required this.photoUrl,
    required this.score,
    required this.initial,
    required this.rank,
  });

  // ── Profil sayfasına git ve gerekirse chat aç ─────────────────────────────
  Future<void> _openProfile(BuildContext context) async {
    final targetUser = UserModel(
      id: userId,
      name: name,
      email: '',
      city: city,
      photoUrl: photoUrl,
      score: score,
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PublicProfilePage(user: targetUser),
      ),
    );

    // PublicProfilePage'den "Mesaj Gönder" butonuna basılınca true döner
    if (result == true && context.mounted) {
      final userModel = Provider.of<MyUserModel>(context, listen: false);
      final currentUser = userModel.user;
      if (currentUser == null) return;

      final chatId = currentUser.id.compareTo(userId) < 0
          ? '${currentUser.id}_$userId'
          : '${userId}_${currentUser.id}';

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({
        'users': [currentUser.id, userId],
        'user1': currentUser.id.compareTo(userId) < 0
            ? currentUser.id
            : userId,
        'user2': currentUser.id.compareTo(userId) < 0
            ? userId
            : currentUser.id,
        'lastMessage': '',
        'lastMessageSender': currentUser.id,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isRead_${currentUser.id}': true,
        'isRead_$userId': true,
      }, SetOptions(merge: true));

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(receiverUser: targetUser),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        photoUrl.startsWith('http') || photoUrl.startsWith('https');

    return GestureDetector(
      onTap: () => _openProfile(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            // ── Sıra Numarası ───────────────────────────────────────────
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank <= 3
                      ? Colors.amber
                      : Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ── Avatar ──────────────────────────────────────────────────
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withValues(alpha: 0.85),
              backgroundImage:
                  isNetwork ? NetworkImage(photoUrl) : null,
              onBackgroundImageError: isNetwork ? (_, __) {} : null,
              child: !isNetwork
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // ── Ad & Şehir ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (city.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white30, size: 12),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Zirve Puanı ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.18),
                    Colors.orange.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Colors.amber, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    score > 0 ? '$score Puan' : '— Puan',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Boş Durum Widget'ı
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white12, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
