import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/services/api_services.dart';
import 'core/services/network_service.dart';
import 'features/books/services/book_service.dart';
import 'features/favorate/controller/favorite_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox<String>('favoritesBox');

  await _initializeServices();
  runApp(const BookApp());
}

Future<void> _initializeServices() async {
  final apiClient = ApiClient();
  await apiClient.init();
  Get.put(apiClient, permanent: true);

  Get.put(NetworkService(), permanent: true);
  Get.put(BookService(), permanent: true);
  Get.put(FavoriteController(), permanent: true);
}
