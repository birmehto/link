import 'package:flutter/material.dart';

import '../../../shared/widgets/skeleton_loader.dart';

class BookDetailSkeleton extends StatelessWidget {
  const BookDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = skeletonColor(context);

    return SafeArea(
      child: SkeletonLoader(
        isLoading: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: skeletonBox(
                  width: double.infinity,
                  height: 300,
                  radius: 10,
                  color: color,
                ),
              ),
              const SizedBox(height: 24),
              skeletonLine(width: double.infinity, height: 28, color: color),
              const SizedBox(height: 12),
              skeletonLine(width: 250, height: 20, color: color),
              const SizedBox(height: 20),
              Row(
                children: [
                  skeletonBadge(width: 80, color: color),
                  const SizedBox(width: 12),
                  skeletonBadge(width: 60, color: color),
                  const Spacer(),
                  skeletonBadge(width: 70, color: color),
                ],
              ),
              const SizedBox(height: 24),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: skeletonLine(
                    width: index == 4 ? 200 : double.infinity,
                    height: 16,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: skeletonBox(
                      width: double.infinity,
                      height: 48,
                      radius: 12,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  skeletonBox(width: 48, height: 48, radius: 12, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
