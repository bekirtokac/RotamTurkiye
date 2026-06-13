import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initCampgrounds();
  }

  Future<void> _initCampgrounds() async {
    try {
      final campgroundsCollection = _firestore.collection('campgrounds');
      final snapshot = await campgroundsCollection.get();

      if (snapshot.docs.isEmpty) {
        // Preseed popular 5 campground spots in Turkey
        final List<Map<String, dynamic>> mockCampgrounds = [
          {
            'name': 'Bolu Yedigöller',
            'description': 'Eşsiz doğası ve yedi adet gölüyle muhteşem bir kamp alanı.',
            'latitude': 40.9416,
            'longitude': 31.7483,
          },
          {
            'name': 'Fethiye Kabak Koyu',
            'description': 'Deniz ve doğanın birleştiği, huzurlu ve saklı bir koy.',
            'latitude': 36.4608,
            'longitude': 29.1256,
          },
          {
            'name': 'Antalya Olimpos',
            'description': 'Tarihi kalıntılar ile doğanın iç içe geçtiği popüler kamp alanı.',
            'latitude': 36.3986,
            'longitude': 30.4744,
          },
          {
            'name': 'Rize Ayder Yaylası',
            'description': 'Karadeniz\'in yeşil doğası ve temiz havasıyla meşhur yaylası.',
            'latitude': 40.9575,
            'longitude': 41.1042,
          },
          {
            'name': 'Kapadokya Kamp Alanı',
            'description': 'Peri bacaları ve sıcak hava balonları manzaralı eşsiz kamp deneyimi.',
            'latitude': 38.6431,
            'longitude': 34.8289,
          },
        ];

        final batch = _firestore.batch();
        for (var camp in mockCampgrounds) {
          final docRef = campgroundsCollection.doc();
          batch.set(docRef, camp);
        }
        await batch.commit();
      }

      // Listen to campgrounds changes
      _listenToCampgrounds();
    } catch (e) {
      debugPrint('Kamp verileri ilklendirilirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenToCampgrounds() {
    _firestore.collection('campgrounds').snapshots().listen((snapshot) {
      final Set<Marker> newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        final String name = data['name'] as String? ?? 'Kamp Alanı';
        final String description = data['description'] as String? ?? '';
        final double latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        final double longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;

        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: name,
            snippet: description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Nerede Kalınır? (Kamp Haritası)",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(39.92077, 32.85411),
                zoom: 6.0,
              ),
              markers: _markers,
              myLocationEnabled: false, // Prevents error if permission is not set
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
    );
  }
}
