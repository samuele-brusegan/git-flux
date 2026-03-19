import 'package:isar_community/isar.dart';

part 'repository_meta.g.dart';

@collection
class RepositoryMeta {
  Id id = Isar.autoIncrement;

  late String name;
  
  @Index(unique: true)
  late String localPath;

  late String remoteUrl;
  
  late int accountId; // Reference to Account.id

  late DateTime lastOpenedAt;
  
  late bool isFavorite;
}
