import 'package:equatable/equatable.dart';
import 'package:flux_git/data/models/account.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final AuthProvider provider;
  final String? serverUrl;
  final bool skipSslVerify;

  const LoginRequested({
    required this.provider,
    this.serverUrl,
    this.skipSslVerify = false,
  });

  @override
  List<Object?> get props => [provider, serverUrl, skipSslVerify];
}

class LogoutRequested extends AuthEvent {
  final Account account;
  const LogoutRequested(this.account);

  @override
  List<Object?> get props => [account];
}

class SwitchAccount extends AuthEvent {
  final Account account;
  const SwitchAccount(this.account);

  @override
  List<Object?> get props => [account];
}

// --- States ---

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Account currentAccount;
  final List<Account> allAccounts;

  const Authenticated({
    required this.currentAccount,
    required this.allAccounts,
  });

  @override
  List<Object?> get props => [currentAccount, allAccounts];
}

class Unauthenticated extends AuthState {
  final List<Account> availableAccounts;
  const Unauthenticated({this.availableAccounts = const []});

  @override
  List<Object?> get props => [availableAccounts];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
