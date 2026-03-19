import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/data/models/repository_meta.dart';

class DatabaseService {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [AccountSchema, RepositoryMetaSchema],
      directory: dir.path,
    );
  }

  Future<void> close() async {
    await _isar.close();
  }
}
