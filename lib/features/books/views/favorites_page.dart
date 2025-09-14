import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_state_message.dart';
import '../../home/controllers/home_controller.dart';

/// Page for viewing favorite/saved books
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 90,
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Favorites',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppStateMessage(
        icon: Icons.favorite_outline,
        iconColor: Theme.of(context).primaryColor,
        title: 'No Favorites Yet',
        message:
            'Books you favorite will appear here. Start exploring and save your favorite books!',
        primaryLabel: 'Explore Books',
        onPrimary: () {
          final homeController = Get.find<HomeController>();
          homeController.goToHome();
        },
      ),
    );
  }
}
