import 'package:git2dart/git2dart.dart';

/// Represents a failure in a Git operation.
class GitOperationFailure implements Exception {
  final String message;
  final String? lowLevelError;

  GitOperationFailure(this.message, [this.lowLevelError]);

  @override
  String toString() => 'GitOperationFailure: $message ${lowLevelError != null ? "($lowLevelError)" : ""}';
}

/// Specialized failure for missing repository.
class NoRepositoryLoadedFailure extends GitOperationFailure {
  NoRepositoryLoadedFailure() : super("No repository is currently loaded.");
}

/// Specialized failure for authentication issues.
class GitAuthFailure extends GitOperationFailure {
  GitAuthFailure([String? details]) : super("Authentication failed.", details);
}

/// Centralized error handler for FFI calls to libgit2.
class FfiErrorHandler {
  /// Executes a [task] and catches any libgit2 related exceptions,
  /// rethrowing them as [GitOperationFailure].
  static T wrap<T>(T Function() task, {String context = "Operation"}) {
    try {
      return task();
    } catch (e) {
      // Re-throw as GitOperationFailure with more context
      throw GitOperationFailure("Error during $context", e.toString());
    }
  }

  /// Async version of [wrap].
  static Future<T> wrapAsync<T>(Future<T> Function() task, {String context = "Operation"}) async {
    try {
      return await task();
    } catch (e) {
      throw GitOperationFailure("Error during $context", e.toString());
    }
  }
}
