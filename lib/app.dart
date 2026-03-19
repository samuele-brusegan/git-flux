import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/core/theme/app_theme.dart';
import 'package:flux_git/core/router/app_router.dart';
import 'package:flux_git/data/services/auth_service.dart';
import 'package:flux_git/data/services/database_service.dart';
import 'package:flux_git/data/services/git_service.dart';
import 'package:flux_git/features/auth/bloc/auth_bloc.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:flux_git/features/repository/bloc/repo_bloc.dart';

class FluxGitApp extends StatefulWidget {
  final DatabaseService dbService;
  final AuthService authService;

  const FluxGitApp({
    super.key,
    required this.dbService,
    required this.authService,
  });

  @override
  State<FluxGitApp> createState() => _FluxGitAppState();
}

class _FluxGitAppState extends State<FluxGitApp> {
  late final AuthBloc _authBloc;
  late final RepoBloc _repoBloc;
  final _gitService = GitService();

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authService: widget.authService,
      dbService: widget.dbService,
    )..add(AppStarted());
    
    _repoBloc = RepoBloc(gitService: _gitService, authBloc: _authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _repoBloc),
      ],
      child: MaterialApp.router(
        title: 'FluxGit',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
