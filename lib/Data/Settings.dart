import 'package:isar/isar.dart';

part 'Settings.g.dart';

@collection
class Settings {
  Id id = 0; // Only one record
  String? localLibraryPath;
}
