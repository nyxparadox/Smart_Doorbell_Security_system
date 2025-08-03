
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsnap/Data/Repository/auth_repository.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final  getIt =GetIt.instance;

Future<void> setupserviceLocator() async{

  getIt.registerLazySingleton(() => AppRouter());    // Registering AppRouter as a singleton
  getIt.registerLazySingleton<FirebaseFirestore>(()=> FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(()=> FirebaseAuth.instance);
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(()=> AuthCubit(authRepository: AuthRepository()));

}