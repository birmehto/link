import 'package:flutter/material.dart';

import '../../../shared/widgets/skeleton_loader.dart';

class BookListSkeleton extends StatelessWidget {
  const BookListSkeleton({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => BookCardSkeleton(index: index),
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = skeletonColor(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeletonBox(width: 80, height: 120, radius: 12, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                skeletonLine(width: double.infinity, height: 20, color: color),
                const SizedBox(height: 8),
                skeletonLine(width: 200, height: 16, color: color),
                const SizedBox(height: 12),
                skeletonLine(width: 150, height: 14, color: color),
                const SizedBox(height: 12),
                Row(
                  children: [
                    skeletonBadge(width: 60, color: color),
                    const SizedBox(width: 8),
                    skeletonBadge(width: 40, color: color),
                    const Spacer(),
                    skeletonBadge(width: 50, color: color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
