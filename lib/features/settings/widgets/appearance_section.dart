import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:file_picker/file_picker.dart';

class AppearanceSection extends StatelessWidget {
  final SettingsViewModel vm;
  final bool isDesktop;

  const AppearanceSection({
    super.key,
    required this.vm,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'APPEARANCE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THEME PRESET',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.38),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${vm.availableThemes.length} AVAILABLE',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: vm.availableThemes.isEmpty 
              ? const Center(child: Text('No themes found.', style: TextStyle(fontSize: 10)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: vm.availableThemes.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final t = vm.availableThemes[index];
                    final isSelected = vm.themeModel.name == t.name;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => vm.setTheme(t),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.palette, color: isSelected ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.24)),
                              const SizedBox(height: 4),
                              Text(
                                t.name, 
                                style: TextStyle(fontSize: 9, color: onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), 
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          const Divider(color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'ARTWORK SHAPE',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.38),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<ArtworkShape>(
                        title: const Text('Squares', style: TextStyle(fontSize: 12)),
                        value: ArtworkShape.square,
                        groupValue: vm.artworkShape,
                        onChanged: (val) => val != null ? vm.setArtworkShape(val) : null,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<ArtworkShape>(
                        title: const Text('Circles', style: TextStyle(fontSize: 12)),
                        value: ArtworkShape.circle,
                        groupValue: vm.artworkShape,
                        onChanged: (val) => val != null ? vm.setArtworkShape(val) : null,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black12),
          _buildPodcastSettings(context, vm, theme),
        ],
      ),
    );
  }

  Widget _buildPodcastSettings(
    BuildContext context,
    SettingsViewModel vm,
    ThemeData theme,
  ) {
    final onSurface = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'PODCASTS',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.38),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Storage Location', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            vm.podcastStorageLocation ?? 'Not Set (Streaming Only)',
            style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.5)),
          ),
          trailing: const Icon(Icons.folder_open_outlined, size: 20),
          onTap: () async {
            final path = await FilePicker.getDirectoryPath();
            if (path != null) {
              vm.setPodcastStorageLocation(path);
            }
          },
        ),
        SwitchListTile(
          title: const Text('Auto-Download New', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            'Automatically download the latest episode upon subscription',
            style: TextStyle(fontSize: 10, color: onSurface.withValues(alpha: 0.38)),
          ),
          value: vm.autoDownloadNewEpisodes,
          onChanged: vm.setAutoDownloadNewEpisodes,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
