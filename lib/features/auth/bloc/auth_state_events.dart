import 'package:equatable/equatable.dart';
import 'package:flux_git/data/models/account.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

enum AuthMethod { oauth, token }

class LoginRequested extends AuthEvent {
  final AuthProvider provider;
  final String? serverUrl;
  final bool skipSslVerify;
  final AuthMethod authMethod;
  final String? username; // For token auth: username or PAT
  final String? password; // For token auth: password (unused if using PAT) or empty

  const LoginRequested({
    required this.provider,
    this.serverUrl,
    this.skipSslVerify = false,
    required this.authMethod,
    this.username,
    this.password,
  });

  @override
  List<Object?> get props => [provider, serverUrl, skipSslVerify, authMethod, username, password];
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

class AuthOAuthPending extends AuthState {
  final String userCode;
  final String verificationUri;
  final AuthProvider provider;
  final String? serverUrl;

  const AuthOAuthPending({
    required this.userCode,
    required this.verificationUri,
    required this.provider,
    this.serverUrl,
  });

  @override
  List<Object?> get props => [userCode, verificationUri, provider, serverUrl];
}

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
