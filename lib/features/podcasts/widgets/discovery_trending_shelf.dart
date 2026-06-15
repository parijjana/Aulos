import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/features/podcasts/widgets/discovery_grid_item.dart';

class DiscoveryTrendingShelf extends StatelessWidget {
  final PodcastViewModel vm;

  const DiscoveryTrendingShelf({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = vm.trendingResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'TRENDING',
            style: TextStyle(
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
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
