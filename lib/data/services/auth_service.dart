import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flux_git/data/models/account.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenPrefix = 'flux_git_token_';

  Future<void> saveToken(Account account, String token) async {
    await _storage.write(
      key: _tokenKey(account),
      value: token,
    );
  }

  Future<String?> getToken(Account account) async {
    return await _storage.read(key: _tokenKey(account));
  }

  Future<void> deleteToken(Account account) async {
    await _storage.delete(key: _tokenKey(account));
  }

  String _tokenKey(Account account) {
    return '$_tokenPrefix${account.identifier}';
  }
}
