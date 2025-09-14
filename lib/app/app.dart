import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';


class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Open Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: AppPages.defaultTransition,
    );
  }
}
