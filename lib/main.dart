import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/app.dart';
import 'package:flux_git/core/bloc_observer.dart';
import 'package:flux_git/data/services/auth_service.dart';
import 'package:flux_git/data/services/database_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  final dbService = DatabaseService();
  await dbService.init();

  final authService = AuthService();

  runApp(FluxGitApp(
    dbService: dbService,
    authService: authService,
  ));
}
