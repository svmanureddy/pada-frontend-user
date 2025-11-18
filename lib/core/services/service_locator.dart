import 'package:get_it/get_it.dart';
import 'package:deliverapp/core/services/storage_service.dart';

import 'api_service.dart';
import 'location_services.dart';
import 'navigation_service.dart';
import 'notification_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerLazySingleton<LocationService>(() => LocationService());
  locator.registerSingleton<NotificationService>(NotificationService());
  // locator.registerSingleton<ConnectivityService>(ConnectivityService());
  locator.registerLazySingleton<ApiService>(() => ApiService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
}
