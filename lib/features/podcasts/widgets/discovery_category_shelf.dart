import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/features/podcasts/widgets/discovery_grid_item.dart';

class DiscoveryCategoryShelf extends StatelessWidget {
  final Map<String, dynamic> cat;
  final PodcastViewModel vm;
  final void Function(Map<String, dynamic>) onSeeAll;

  const DiscoveryCategoryShelf({
    super.key,
    required this.cat,
    required this.vm,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catId = cat['id']?.toString() ?? '';
    final catName = cat['name']?.toString() ?? 'Category';
    final results = vm.categoryResults[catId] ?? [];

    if (results.isEmpty && !vm.isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                catName.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onSeeAll(cat),
              child: const Text('SEE ALL', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
        SizedBox(
          height: 220,
          child: results.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: DiscoveryGridItem(result: item, vm: vm),
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
