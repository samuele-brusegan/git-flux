import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/data/services/auth_service.dart';
import 'package:flux_git/data/services/database_service.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:isar_community/isar.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final DatabaseService _dbService;

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

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Mock login for now - in a real app, this would trigger OAuth2 flow
      final mockAccount = Account()
        ..provider = event.provider
        ..username = "samuele"
        ..serverUrl = event.serverUrl ?? "https://github.com"
        ..avatarUrl = "https://github.com/samuele.png"
        ..skipSslVerify = event.skipSslVerify
        ..addedAt = DateTime.now()
        ..identifier = "${event.provider.name}_samuele_${event.serverUrl ?? ''}";

      await _dbService.isar.writeTxn(() async {
        await _dbService.isar.accounts.put(mockAccount);
      });
      await _authService.saveToken(mockAccount, "mock_token_123");

      final all = await _dbService.isar.accounts.where().findAll();
      emit(Authenticated(currentAccount: mockAccount, allAccounts: all));
    } catch (e) {
      emit(AuthError(e.toString()));
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
}
