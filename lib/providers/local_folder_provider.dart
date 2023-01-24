import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalFolderNotifier extends StateNotifier<String?> {
  LocalFolderNotifier() : super(null);

  void set(String to) {
    state = to;
  }
}

final localFolderProvider =
    StateNotifierProvider<LocalFolderNotifier, String?>((ref) {
  return LocalFolderNotifier();
});
