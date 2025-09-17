import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:link/core/routes/app_routes.dart';
import 'package:link/core/theme/app_theme.dart';

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Open Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: AppPages.defaultTransition,
    );
  }
}
