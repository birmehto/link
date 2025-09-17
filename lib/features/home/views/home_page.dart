import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../books/views/book_list_page.dart';
import '../../books/views/categories_page.dart';
import '../../books/views/favorites_page.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() => _buildCurrentPage(controller.currentIndex.value)),
      bottomNavigationBar: Obx(
        () => _buildBottomNavigationBar(theme, controller),
      ),
    );
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return const BookListPage();
      case 1:
        return const CategoriesPage();
      case 2:
        return const FavoritesPage();

      default:
        return const BookListPage();
    }
  }

  Widget _buildBottomNavigationBar(ThemeData theme, HomeController controller) {
    return NavigationBar(
      backgroundColor:
          theme.bottomNavigationBarTheme.backgroundColor ??
          theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.secondary.withValues(alpha: 0.05),
      selectedIndex: controller.currentIndex.value,
      onDestinationSelected: (index) {
        HapticFeedback.selectionClick();
        controller.changeTab(index);
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      elevation: 8,
      indicatorColor: theme.primaryColor.withValues(alpha: 0.1),
      destinations: _navigationDestinations(theme),
    );
  }

  List<NavigationDestination> _navigationDestinations(ThemeData theme) {
    return [
      NavigationDestination(
        icon: Icon(
          Icons.home_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.category_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(Icons.category, color: theme.colorScheme.primary),
        label: 'Categories',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.favorite_outline,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        selectedIcon: Icon(Icons.favorite, color: theme.colorScheme.primary),
        label: 'Favorites',
      ),
    ];
  }
}
