import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WhereToStayPage extends StatefulWidget {
  const WhereToStayPage({super.key});

  @override
  State<WhereToStayPage> createState() => _WhereToStayPageState();
}

class _WhereToStayPageState extends State<WhereToStayPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  GoogleMapController? _mapController;

  static const String _darkMapStyleJson = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#121212"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _initCampsites();
  }

  Future<void> _initCampsites() async {
    try {
      final campsitesCollection = _firestore.collection('campsites');
      final snapshot = await campsitesCollection.get();

      if (snapshot.docs.isEmpty) {
        // Preseed popular campground spots in Turkey if collection is empty
        final List<Map<String, dynamic>> mockCampsites = [
          {
            'name': 'Bolu Yedigöller Kamp Alanı',
            'description': 'Yedi göllerin büyüleyici doğasında, kayın ve meşe ağaçlarının gölgesinde çadır kampı keyfi.',
            'latitude': 40.9416,
            'longitude': 31.7483,
          },
          {
            'name': 'Fethiye Kabak Koyu',
            'description': 'Kelebekler Vadisi yakınlarında, çam ormanlarıyla çevrili ve turkuaz sulara açılan bakir bir koy.',
            'latitude': 36.4608,
            'longitude': 29.1256,
          },
          {
            'name': 'Antalya Olimpos Antik Kenti',
            'description': 'Tarihi kalıntıların ve narenciye bahçelerinin arasında çadır kurabileceğiniz eşsiz bir kamp noktası.',
            'latitude': 36.3986,
            'longitude': 30.4744,
          },
          {
            'name': 'Rize Ayder Yaylası Kampı',
            'description': 'Kaçkar Dağları\'nın eteklerinde, yemyeşil çayırlar ve kaplıcalar eşliğinde yayla kampı.',
            'latitude': 40.9575,
            'longitude': 41.1042,
          },
          {
            'name': 'Kapadokya Kızılçukur Vadisi',
            'description': 'Balonların gün doğumundaki süzülüşünü ve peri bacalarının eşsiz siluetini izleyebileceğiniz kamp yeri.',
            'latitude': 38.6431,
            'longitude': 34.8289,
          },
        ];

        final batch = _firestore.batch();
        for (var camp in mockCampsites) {
          final docRef = campsitesCollection.doc();
          batch.set(docRef, camp);
        }
        await batch.commit();
      }

      // Listen to real-time campsites changes
      _listenToCampsites();
    } catch (e) {
      debugPrint('Kamp alanları ilklendirilirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToCampsites() {
    _firestore.collection('campsites').snapshots().listen((snapshot) {
      final Set<Marker> newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        final String name = data['name'] as String? ?? 'Kamp Alanı';
        final String description = data['description'] as String? ?? '';
        final double latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        final double longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;

        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            _showCampsiteDetails(name, description);
          },
        );
      }).toSet();

      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _isLoading = false;
        });
      }
    });
  }

  void _showCampsiteDetails(String name, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.white10, width: 1),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.campaign_rounded, color: Colors.redAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Anlaşıldı',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Nerede Kalınır?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                  strokeWidth: 3,
                ),
              )
            : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(39.9334, 32.8597),
                  zoom: 6.0,
                ),
                markers: _markers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _mapController?.setMapStyle(_darkMapStyleJson);
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
