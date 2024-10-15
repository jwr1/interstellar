import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

late final Database db;

Future<void> initDatabase() async {
  final dir = await getApplicationSupportDirectory();

  final dbPath = join(dir.path, 'database');

  db = await databaseFactoryIo.openDatabase(dbPath);
}
