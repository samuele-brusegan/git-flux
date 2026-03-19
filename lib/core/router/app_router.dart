import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flux_git/widgets/app_scaffold.dart';
import 'package:flux_git/features/home/views/home_view.dart';
import 'package:flux_git/features/auth/views/login_page.dart';
import 'package:flux_git/features/auth/bloc/auth_bloc.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:flux_git/features/repository/views/repo_view.dart';

import 'package:flux_git/features/terminal/views/terminal_view.dart';
import 'package:flux_git/features/academy/views/academy_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggingIn = state.matchedLocation == '/auth';

    if (authState is Unauthenticated || authState is AuthInitial) {
      return isLoggingIn ? null : '/auth';
    }

    if (authState is Authenticated && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/terminal',
          builder: (context, state) => const TerminalView(),
        ),
        GoRoute(
          path: '/academy',
          builder: (context, state) => const AcademyView(),
        ),
        GoRoute(
          path: '/repo/:path',
          builder: (context, state) {
            final path = state.pathParameters['path']!;
            return RepoView(path: Uri.decodeComponent(path));
          },
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
