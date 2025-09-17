import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/network_service.dart';
import 'features/books/services/book_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeServices();
  runApp(const BookApp());
}

Future<void> _initializeServices() async {
  await GetStorage.init();

  final apiClient = ApiClient();
  await apiClient.init();
  Get.put(apiClient, permanent: true);
  Get.put(DeepLinkService(), permanent: true);
  Get.put(NetworkService(), permanent: true);
  Get.put(BookService(), permanent: true);
}
