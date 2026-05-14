import 'package:get_it/get_it.dart';
import 'package:rotam_turkiye/repository/trip_repository.dart';
import 'package:rotam_turkiye/repository/user_repository.dart';
import 'package:rotam_turkiye/services/firebase_auth_service.dart';
import 'package:rotam_turkiye/services/firestore_db_service.dart';
import 'package:rotam_turkiye/services/firestore_trip_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FirestoreDBService());
  locator.registerLazySingleton(() => FirestoreTripService());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => TripRepository());
}
