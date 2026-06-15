import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late SettingsViewModel viewModel;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    
    viewModel = SettingsViewModel(mockPrefs);
  });

  group('SettingsViewModel - isFolderWatcherEnabled', () {
    test('default value should be true', () {
      expect(viewModel.isFolderWatcherEnabled, isTrue);
    });

    test('setIsFolderWatcherEnabled should update value and save to prefs', () async {
      await viewModel.setIsFolderWatcherEnabled(false);
      expect(viewModel.isFolderWatcherEnabled, isFalse);
      verify(() => mockPrefs.setBool('is_folder_watcher_enabled', false)).called(1);

      await viewModel.setIsFolderWatcherEnabled(true);
      expect(viewModel.isFolderWatcherEnabled, isTrue);
      verify(() => mockPrefs.setBool('is_folder_watcher_enabled', true)).called(1);
    });
  });
}
