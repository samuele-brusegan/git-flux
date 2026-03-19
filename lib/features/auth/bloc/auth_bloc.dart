import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/data/services/auth_service.dart';
import 'package:flux_git/data/services/database_service.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:isar_community/isar.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final DatabaseService _dbService;
  Timer? _oauthTimer;

  AuthBloc({
    required AuthService authService,
    required DatabaseService dbService,
  })  : _authService = authService,
        _dbService = dbService,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SwitchAccount>(_onSwitchAccount);
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    if (transition.nextState is! AuthOAuthPending) {
      _oauthTimer?.cancel();
      _oauthTimer = null;
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final accounts = await _dbService.isar.accounts.where().findAll();
    if (accounts.isNotEmpty) {
      emit(Authenticated(
        currentAccount: accounts.first,
        allAccounts: accounts,
      ));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    // Gitea requires serverUrl
    if (event.provider == AuthProvider.gitea && (event.serverUrl?.isEmpty ?? true)) {
      emit(const AuthError("Server URL is required for Gitea"));
      return;
    }

    if (event.authMethod == AuthMethod.token) {
      // Token authentication (PAT)
      if (event.username == null || event.password == null) {
        emit(const AuthError("Username and token are required"));
        return;
      }
      emit(AuthLoading());
      try {
        final account = await _validateToken(
          event.provider,
          event.serverUrl,
          event.password!, // password is the token
          expectedUsername: event.username,
        );
        if (account == null) {
          emit(const AuthError("Invalid credentials"));
          return;
        }
        account.skipSslVerify = event.skipSslVerify;
        await _saveAccount(account, event.password!);
        final allAccounts = await _dbService.isar.accounts.where().findAll();
        emit(Authenticated(currentAccount: account, allAccounts: allAccounts));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    } else if (event.authMethod == AuthMethod.oauth) {
      emit(AuthLoading());
      try {
        final clientId = await _getClientId(event.provider);
        if (clientId == null) {
          emit(const AuthError("OAuth not configured. Please create oauth_config.json with client_id for the provider."));
          return;
        }
        // Request device code
        final deviceCodeResponse = await _requestDeviceCode(event.provider, event.serverUrl, clientId);
        final userCode = deviceCodeResponse['user_code'] as String;
        final verificationUri = deviceCodeResponse['verification_uri'] as String;
        final deviceCode = deviceCodeResponse['device_code'] as String;
        final interval = deviceCodeResponse['interval'] as int;

        // Emit pending state
        emit(AuthOAuthPending(
          userCode: userCode,
          verificationUri: verificationUri,
          provider: event.provider,
          serverUrl: event.serverUrl,
        ));

        // Start polling
        _oauthTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
          try {
            final tokenResponse = await _pollToken(event.provider, event.serverUrl, clientId, deviceCode);
            if (tokenResponse.containsKey('access_token')) {
              final accessToken = tokenResponse['access_token'] as String;
              timer.cancel();
              // Validate token to get user info
              final account = await _validateToken(event.provider, event.serverUrl, accessToken);
              if (account != null) {
                account.skipSslVerify = event.skipSslVerify;
                await _saveAccount(account, accessToken);
                final allAccounts = await _dbService.isar.accounts.where().findAll();
                emit(Authenticated(currentAccount: account, allAccounts: allAccounts));
              } else {
                emit(const AuthError("Failed to retrieve account info from OAuth token"));
              }
            } else if (tokenResponse.containsKey('error')) {
              final error = tokenResponse['error'] as String;
              if (error == 'authorization_pending') {
                // continue polling
              } else if (error == 'slow_down') {
                // Could increase interval but skip for simplicity
              } else {
                timer.cancel();
                emit(AuthError("OAuth error: $error"));
              }
            }
          } catch (e) {
            timer.cancel();
            emit(AuthError("OAuth polling failed: $e"));
          }
        });
      } catch (e) {
        emit(AuthError("OAuth device flow failed: $e"));
      }
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _dbService.isar.writeTxn(() async {
      await _dbService.isar.accounts.delete(event.account.id);
    });
    await _authService.deleteToken(event.account);
    add(AppStarted());
  }

  Future<void> _onSwitchAccount(
      SwitchAccount event, Emitter<AuthState> emit) async {
    final all = await _dbService.isar.accounts.where().findAll();
    emit(Authenticated(currentAccount: event.account, allAccounts: all));
  }

  // Helper methods for OAuth and token validation

  String _getBaseUrl(AuthProvider provider, String? serverUrl) {
    switch (provider) {
      case AuthProvider.github:
        return 'https://api.github.com';
      case AuthProvider.gitlab:
        return serverUrl ?? 'https://gitlab.com';
      case AuthProvider.gitea:
        return serverUrl ?? '';
    }
  }

  String _getDeviceCodeEndpoint(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.github:
        return '/login/oauth/device';
      case AuthProvider.gitlab:
        return '/oauth/device/code';
      case AuthProvider.gitea:
        return '/login/oauth/device';
    }
  }

  String _getTokenEndpoint(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.github:
        return '/login/oauth/access_token';
      case AuthProvider.gitlab:
        return '/oauth/token';
      case AuthProvider.gitea:
        return '/login/oauth/access_token';
    }
  }

  String _getScope(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.github:
        return 'repo';
      case AuthProvider.gitlab:
        return 'api';
      case AuthProvider.gitea:
        return 'repo';
    }
  }

  String _getUserEndpoint(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.github:
        return '/user';
      case AuthProvider.gitlab:
        return '/api/v4/user';
      case AuthProvider.gitea:
        return '/api/v1/user';
    }
  }

  Map<String, String> _getAuthHeaders(AuthProvider provider, String token) {
    switch (provider) {
      case AuthProvider.github:
        return {'Authorization': 'Bearer $token', 'Accept': 'application/vnd.github.v3+json'};
      case AuthProvider.gitlab:
        return {'PRIVATE-TOKEN': token};
      case AuthProvider.gitea:
        return {'Authorization': 'token $token'};
    }
  }

  String _extractUsername(AuthProvider provider, Map<String, dynamic> json) {
    switch (provider) {
      case AuthProvider.github:
        return json['login'] as String;
      case AuthProvider.gitlab:
        return json['username'] as String;
      case AuthProvider.gitea:
        return json['login'] as String;
    }
  }

  String? _extractAvatarUrl(AuthProvider provider, Map<String, dynamic> json) {
    switch (provider) {
      case AuthProvider.github:
        return json['avatar_url'] as String?;
      case AuthProvider.gitlab:
        return json['avatar_url'] as String?;
      case AuthProvider.gitea:
        return json['avatar_url'] as String?;
    }
  }

  String _getDefaultServerUrl(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.github:
        return 'https://github.com';
      case AuthProvider.gitlab:
        return 'https://gitlab.com';
      case AuthProvider.gitea:
        return '';
    }
  }

  Future<Account?> _validateToken(AuthProvider provider, String? serverUrl, String token, {String? expectedUsername}) async {
    final baseUrl = _getBaseUrl(provider, serverUrl);
    if (baseUrl.isEmpty) return null; // Gitea requires serverUrl
    final userEndpoint = _getUserEndpoint(provider);
    final url = '$baseUrl$userEndpoint';
    final headers = _getAuthHeaders(provider, token);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final login = _extractUsername(provider, json);
        final avatarUrl = _extractAvatarUrl(provider, json);
        if (expectedUsername != null && login != expectedUsername) {
          return null;
        }
        return Account()
          ..provider = provider
          ..username = login
          ..serverUrl = serverUrl ?? _getDefaultServerUrl(provider)
          ..avatarUrl = avatarUrl ?? ''
          ..skipSslVerify = false
          ..addedAt = DateTime.now()
          ..identifier = '${provider.name}_${login}_${serverUrl ?? _getDefaultServerUrl(provider)}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAccount(Account account, String token) async {
    await _dbService.isar.writeTxn(() async {
      await _dbService.isar.accounts.put(account);
    });
    await _authService.saveToken(account, token);
  }

  Future<String?> _getClientId(AuthProvider provider) async {
    try {
      final file = File('oauth_config.json');
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      switch (provider) {
        case AuthProvider.github:
          return json['github_client_id'] as String?;
        case AuthProvider.gitlab:
          return json['gitlab_client_id'] as String?;
        case AuthProvider.gitea:
          return json['gitea_client_id'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> _requestDeviceCode(AuthProvider provider, String? serverUrl, String clientId) async {
    final baseUrl = _getBaseUrl(provider, serverUrl);
    if (baseUrl.isEmpty) throw Exception('Server URL required for Gitea');
    final endpoint = _getDeviceCodeEndpoint(provider);
    final url = '$baseUrl$endpoint';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'client_id': clientId,
        'scope': _getScope(provider),
        if (provider == AuthProvider.gitlab) 'redirect_uri': '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Device code request failed: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _pollToken(AuthProvider provider, String? serverUrl, String clientId, String deviceCode) async {
    final baseUrl = _getBaseUrl(provider, serverUrl);
    if (baseUrl.isEmpty) throw Exception('Server URL required for Gitea');
    final endpoint = _getTokenEndpoint(provider);
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      body: {
        'client_id': clientId,
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        if (provider == AuthProvider.gitlab) 'redirect_uri': '',
      },
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
