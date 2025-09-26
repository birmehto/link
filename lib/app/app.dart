import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../shared/theme/app_theme.dart';

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Open Library',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    initialRoute: AppRoutes.home,
    getPages: AppPages.pages,
    defaultTransition: Transition.cupertino,
  );
}
