import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rotam_turkiye/landingPage.dart';
import 'package:rotam_turkiye/locator.dart';
import 'package:rotam_turkiye/viewmodel/my_trip_model.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  await dotenv.load(fileName: "lib/.env");

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        appId: '1:557347852821:android:43c5bee81d82769c4ab41c',
        apiKey: 'AIzaSyBIhv-Bq1pighTEhBnwJ3v3ZWb7EY_nL4U',
        messagingSenderId: '557347852821',
        projectId: 'localtraveler-8c69d',
      ),
    );
  } catch (e) {
    print('Firebase zaten başlatılmış: $e');
  }

  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Düzelttiğimiz satır burası

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyUserModel>(
          create: (context) => MyUserModel(),
        ),
        ChangeNotifierProvider<MyTripModel>(
          create: (context) => MyTripModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LandingPage(),
      ),
    );
  }
}