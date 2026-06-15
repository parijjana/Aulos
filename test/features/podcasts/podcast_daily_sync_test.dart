import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/data/library/podcast_download_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

class MockPodcastService extends Mock implements PodcastService {}
class MockPodcastDiscoveryService extends Mock implements PodcastDiscoveryService {}
class MockPodcastDownloadService extends Mock implements PodcastDownloadService {}
class MockDiscoverySyncManager extends Mock implements DiscoverySyncManager {}
class MockPodcastDatabase extends Mock implements PodcastDatabase {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late PodcastViewModel viewModel;
  late MockPodcastService mockPodcastService;
  late MockPodcastDiscoveryService mockDiscoveryService;
  late MockPodcastDownloadService mockDownloadService;
  late MockDiscoverySyncManager mockSyncManager;
  late MockPodcastDatabase mockDiscoveryDb;
  late MockSettingsViewModel mockSettingsVM;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockPodcastService = MockPodcastService();
    mockDiscoveryService = MockPodcastDiscoveryService();
    mockDownloadService = MockPodcastDownloadService();
    mockSyncManager = MockDiscoverySyncManager();
    mockDiscoveryDb = MockPodcastDatabase();
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);

    // Default stubs
    when(() => mockSyncManager.isSyncing).thenReturn(false);
    when(() => mockSyncManager.triggerInitialSync()).thenAnswer((_) async {});
    when(() => mockSyncManager.addListener(any())).thenReturn(null);
    when(() => mockSyncManager.removeListener(any())).thenReturn(null);
    when(() => mockDownloadService.progressStream).thenAnswer((_) => const Stream.empty());
    
    // Stub loadPodcasts calls inside constructor
    when(() => mockPodcastService.getSubscribedPodcasts()).thenAnswer((_) async => []);

    // Create the viewModel under test
    viewModel = PodcastViewModel(
      podcastService: mockPodcastService,
      discoveryService: mockDiscoveryService,
      downloadService: mockDownloadService,
      syncManager: mockSyncManager,
      discoveryDb: mockDiscoveryDb,
      settingsVM: mockSettingsVM,
    );
  });

  group('PodcastViewModel - checkAndRefreshLibraryDaily', () {
    test('should refresh when last refresh time is null', () async {
      when(() => mockSettingsVM.lastPodcastRefreshTime).thenReturn(null);
      when(() => mockSettingsVM.setLastPodcastRefreshTime(any())).thenAnswer((_) async {});
      when(() => mockPodcastService.getSubscribedPodcasts()).thenAnswer((_) async => []);

      // Clear constructor init calls
      clearInteractions(mockPodcastService);
      clearInteractions(mockSettingsVM);

      await viewModel.checkAndRefreshLibraryDaily();

      verify(() => mockPodcastService.getSubscribedPodcasts()).called(2);
      verify(() => mockSettingsVM.setLastPodcastRefreshTime(any())).called(1);
    });

    test('should refresh when last refresh was > 24 hours ago', () async {
      final lastWeek = DateTime.now().subtract(const Duration(hours: 25));
      when(() => mockSettingsVM.lastPodcastRefreshTime).thenReturn(lastWeek);
      when(() => mockSettingsVM.setLastPodcastRefreshTime(any())).thenAnswer((_) async {});
      when(() => mockPodcastService.getSubscribedPodcasts()).thenAnswer((_) async => []);

      // Clear constructor init calls
      clearInteractions(mockPodcastService);
      clearInteractions(mockSettingsVM);

      await viewModel.checkAndRefreshLibraryDaily();

      verify(() => mockPodcastService.getSubscribedPodcasts()).called(2);
      verify(() => mockSettingsVM.setLastPodcastRefreshTime(any())).called(1);
    });

    test('should NOT refresh when last refresh was < 24 hours ago', () async {
      final recent = DateTime.now().subtract(const Duration(hours: 5));
      when(() => mockSettingsVM.lastPodcastRefreshTime).thenReturn(recent);

      // Clear constructor init calls
      clearInteractions(mockPodcastService);
      clearInteractions(mockSettingsVM);

      await viewModel.checkAndRefreshLibraryDaily();

      verifyNever(() => mockPodcastService.getSubscribedPodcasts());
      verifyNever(() => mockSettingsVM.setLastPodcastRefreshTime(any()));
    });
  });
}
