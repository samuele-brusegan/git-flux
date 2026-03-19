import 'package:isar_community/isar.dart';

part 'account.g.dart';

enum AuthProvider { github, gitlab, gitea }

@collection
class Account {
  Id id = Isar.autoIncrement;

  @enumerated
  late AuthProvider provider;

  late String username;
  late String serverUrl;
  late String avatarUrl;
  late bool skipSslVerify;
  late DateTime addedAt;

  @Index(unique: true, replace: true)
  late String identifier; // provider + username + serverUrl
}
