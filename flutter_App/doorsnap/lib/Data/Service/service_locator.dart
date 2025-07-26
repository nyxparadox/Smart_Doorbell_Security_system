
import 'package:doorsnap/Router/app_router.dart';
import 'package:get_it/get_it.dart';

final  getIt =GetIt.instance;

Future<void> setupserviceLocator() async{

  getIt.registerLazySingleton(() => AppRouter());    // Registering AppRouter as a singleton
  
}