import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/routes/app_routes.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static final List<CategoryItem> _categories = [
    CategoryItem('Fiction', Icons.auto_stories, Colors.blue, 'fiction'),
    CategoryItem('Non-Fiction', Icons.fact_check, Colors.green, 'nonfiction'),
    CategoryItem('Science', Icons.science, Colors.purple, 'science'),
    CategoryItem('Technology', Icons.computer, Colors.indigo, 'technology'),
    CategoryItem('History', Icons.history_edu, Colors.brown, 'history'),
    CategoryItem('Biography', Icons.person_pin, Colors.orange, 'biography'),
    CategoryItem('Philosophy', Icons.psychology, Colors.teal, 'philosophy'),
    CategoryItem('Art', Icons.palette, Colors.pink, 'art'),
    CategoryItem('Religion', Icons.temple_hindu, Colors.amber, 'religion'),
    CategoryItem('Health', Icons.health_and_safety, Colors.red, 'health'),
    CategoryItem('Business', Icons.business, Colors.cyan, 'business'),
    CategoryItem('Romance', Icons.favorite, Colors.pink.shade300, 'romance'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 90,
          collapsedHeight: 64,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Categories',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = _categories[index];
              return _buildCategoryCard(context, category, index);
            }, childCount: _categories.length),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryItem category,
    int index,
  ) {
    return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _searchCategory(category.query);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  category.color.withValues(alpha: 0.15),
                  category.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, size: 30, color: category.color),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
  }

  void _searchCategory(String query) {
    AppNavigation.toSearch(query: query);
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String query;

  const CategoryItem(this.name, this.icon, this.color, this.query);
}
