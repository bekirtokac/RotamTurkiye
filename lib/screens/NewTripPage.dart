import 'package:flutter/material.dart';
import 'package:rotam_turkiye/screens/LocalPeoplePage.dart';
import 'package:rotam_turkiye/widgets/CustomButton.dart';

// Turkey City/District Data Map
const Map<String, List<String>> _turkeyMap = {
  'Adana': ['Merkez', 'Seyhan', 'Çukurova', 'Karataş', 'Kozan'],
  'Afyonkarahisar': ['Merkez', 'Bolvadin', 'Dinar', 'Sandıklı', 'Sincanlı'],
  'Ankara': [
    'Merkez',
    'Çamlıdere',
    'Çubuk',
    'Gölbaşı',
    'Güdül',
    'Kızılcahamam',
    'Nallıhan',
    'Polatlı'
  ],
  'Antalya': [
    'Merkez',
    'Alanya',
    'Gazipaşa',
    'Kaş',
    'Kemer',
    'Kumluca',
    'Manavgat'
  ],
  'Artvin': ['Merkez', 'Ardanuç', 'Borçka', 'Hopa', 'Şavşat', 'Yusufeli'],
  'Aydın': ['Merkez', 'Didim', 'Kuşadası', 'Nazilli', 'Söke'],
  'Balıkesir': ['Merkez', 'Ayvalık', 'Bandırma', 'Edremit', 'Gönen'],
  'Bolu': ['Merkez', 'Gerede', 'Mengen', 'Mudurnu', 'Yedigöller'],
  'Bursa': ['Merkez', 'İnegöl', 'Mudanya', 'Nilüfer', 'Osmangazi', 'Yıldırım'],
  'Çanakkale': ['Merkez', 'Bayramiç', 'Ezine', 'Gelibolu', 'Lapseki'],
  'Denizli': ['Merkez', 'Honaz', 'Merkezefendi', 'Pamukkale', 'Tavas'],
  'Eskişehir': ['Merkez', 'Odunpazarı', 'Sivrihisar', 'Tepebaşı'],
  'Gaziantep': ['Merkez', 'İslahiye', 'Nizip', 'Şahinbey', 'Şehitkamil'],
  'Hatay': ['Merkez', 'Antakya', 'Dörtyol', 'İskenderun', 'Kırıkhan'],
  'İstanbul': [
    'Merkez',
    'Beşiktaş',
    'Beyoğlu',
    'Çekmeköy',
    'Fatih',
    'Kadıköy',
    'Sarıyer',
    'Şişli',
    'Şile',
    'Üsküdar'
  ],
  'İzmir': [
    'Merkez',
    'Bergama',
    'Çeşme',
    'Foça',
    'Menemen',
    'Selçuk',
    'Seferihisar',
    'Urla'
  ],
  'Kayseri': ['Merkez', 'Develi', 'Kocasinan', 'Melikgazi', 'Talas'],
  'Konya': ['Merkez', 'Beyşehir', 'Ereğli', 'Karatay', 'Meram', 'Selçuklu'],
  'Manisa': ['Merkez', 'Akhisar', 'Salihli', 'Soma', 'Turgutlu'],
  'Mersin': ['Merkez', 'Anamur', 'Erdemli', 'Mezitli', 'Silifke', 'Tarsus'],
  'Muğla': [
    'Merkez',
    'Bodrum',
    'Datça',
    'Fethiye',
    'Köyceğiz',
    'Marmaris',
    'Milas'
  ],
  'Nevşehir': ['Merkez', 'Avanos', 'Göreme', 'Hacıbektaş', 'Ürgüp'],
  'Rize': ['Merkez', 'Ardeşen', 'Çamlıhemşin', 'Fındıklı', 'Pazar'],
  'Sakarya': ['Merkez', 'Adapazarı', 'Akyazı', 'Hendek', 'Sapanca'],
  'Samsun': ['Merkez', 'Bafra', 'Çarşamba', 'İlkadım', 'Terme'],
  'Trabzon': ['Merkez', 'Maçka', 'Of', 'Sürmene', 'Vakfıkebir'],
  'Yalova': ['Merkez', 'Armutlu', 'Çınarcık', 'Çiftlikköy', 'Termal'],
};

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  static const Color _bg = Color(0xFF0A0D14);
  static const Color _accent = Color(0xFFE65F2B);

  // State variables
  String? _selectedCity;
  String? _selectedDistrict;
  DateTime? _selectedDate;
  int? _stayDays;
  String _selectedStayType = "çadır";

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  List<String> get _districtOptions =>
      _selectedCity == null ? [] : (_turkeyMap[_selectedCity] ?? []);

  @override
  void dispose() {
    _dateController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accent,
              onPrimary: Colors.white,
              surface: Color(0xFF141820),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: _bg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void saveNewTrip() {
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir şehir seçin.')),
      );
      return;
    }
    if (_selectedDistrict == null || _selectedDistrict!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ilçe seçin.')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen gidiş tarihi seçin.')),
      );
      return;
    }
    if (_stayDays == null || _stayDays! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kaç gün kalacağınızı girin.')),
      );
      return;
    }

    final dateStr = _dateController.text;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalPeoplePage(
            selectedCity: _selectedCity!,
            selectedDistrict: _selectedDistrict!,
            departureDate: dateStr,
            stayDuration: _stayDays.toString(),
            selectedStayType: _selectedStayType,
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, size: 18),
      prefixIconColor: Colors.white70,
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedCities = _turkeyMap.keys.toList()..sort();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          "Yeni Seyahat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title at the top
              const Text(
                "Akıllı Konaklama ve Rota Planlayıcı 🗺️",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Gideceğiniz rotayı ve konaklama tercihinizi belirleyin, size özel rota planınızı hazırlayalım.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // ── Nereye Gideceksiniz? ──
              const Text(
                "Nereye Gideceksiniz?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // İl Dropdown
              DropdownButtonFormField<String?>(
                initialValue: _selectedCity,
                isExpanded: true,
                dropdownColor: const Color(0xFF121212),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70, size: 18),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                hint: const Text(
                  'İl seçin',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                decoration: _inputDecoration(
                  hint: 'İl seçin',
                  icon: Icons.location_city_rounded,
                ),
                items: sortedCities.map((city) {
                  return DropdownMenuItem<String?>(
                    value: city,
                    child: Text(city,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  );
                }).toList(),
                onChanged: _onCityChanged,
              ),
              const SizedBox(height: 12),

              // İlçe Dropdown
              IgnorePointer(
                ignoring: _selectedCity == null,
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedDistrict,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF121212),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        _selectedCity == null ? Colors.white24 : Colors.white70,
                    size: 18,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  hint: const Text(
                    'İlçe seçin',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  decoration: _inputDecoration(
                    hint: 'İlçe seçin',
                    icon: Icons.near_me_rounded,
                    enabled: _selectedCity != null,
                  ),
                  items: _selectedCity == null
                      ? []
                      : _districtOptions.map((d) {
                          return DropdownMenuItem<String?>(
                            value: d,
                            child: Text(d,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          );
                        }).toList(),
                  onChanged: _selectedCity == null
                      ? null
                      : (v) => setState(() => _selectedDistrict = v),
                ),
              ),
              const SizedBox(height: 16),

              // ── Gidiş Tarihi ──
              const Text(
                "Gidiş Tarihi",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: _inputDecoration(
                      hint: 'Tarih seçin',
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Kaç gün kalacaksınız? ──
              const Text(
                "Kaç Gün Kalacaksınız?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration(
                  hint: 'Gün sayısı girin',
                  icon: Icons.date_range_rounded,
                ),
                onChanged: (val) {
                  setState(() {
                    _stayDays = int.tryParse(val.trim());
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── Konaklama Tercihi ──
              const Text(
                "Konaklama Tercihi",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStayChip("⛺ Çadır", "çadır"),
                  _buildStayChip("🚌 Karavan", "karavan"),
                  _buildStayChip("🏨 Otel", "otel"),
                ],
              ),
              const SizedBox(height: 32),

              // ── Oluştur Butonu ──
              CustomButton(
                text: "Oluştur",
                color: _accent,
                textColor: Colors.white,
                onPressed: saveNewTrip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStayChip(String label, String value) {
    final isSelected = _selectedStayType == value;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFF7A45),
      backgroundColor: const Color(0xFFE65F2B),
      labelStyle: TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? Colors.white60 : Colors.transparent,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedStayType = value;
          });
        }
      },
    );
  }
}
