import 'package:git2dart/git2dart.dart';
import '../../core/errors/ffi_error_handler.dart';
import 'package:flux_git/data/services/auth_service.dart';
import 'package:flux_git/data/models/account.dart';

class GitService {
  final AuthService? _authService;
  Repository? _currentRepo;

  GitService([AuthService? authService]) : _authService = authService;

  Repository? get currentRepo => _currentRepo;

  /// Open an existing repository at the given [path].
  Future<Repository> open(String path) async {
    return FfiErrorHandler.wrap(() {
      final repo = Repository.open(path);
      _currentRepo = repo;
      return repo;
    }, context: "opening repository");
  }

  /// Initialize a new repository at the given [path].
  Future<Repository> init(String path) async {
    return FfiErrorHandler.wrap(() {
      final repo = Repository.init(path: path);
      _currentRepo = repo;
      return repo;
    }, context: "initializing repository");
  }

  /// Clone a repository from [url] to [localPath].
  Future<Repository> clone(String url, String localPath, {
    String? username,
    String? password,
    Account? authAccount,
    void Function(double)? onProgress,
  }) async {
    // Determine credentials
    String? effectiveUsername = username;
    String? effectivePassword = password;
    if (authAccount != null && _authService != null) {
      final token = await _authService.getToken(authAccount);
      if (token != null) {
        effectiveUsername = token;
        effectivePassword = '';
      }
    }

    return FfiErrorHandler.wrap(() {
      final repo = Repository.clone(
        url: url,
        localPath: localPath,
        callbacks: Callbacks(
          transferProgress: (stats) {
            if (onProgress != null) {
              final progress = (stats.receivedObjects + stats.indexedObjects) / (stats.totalObjects * 2);
              onProgress(progress);
            }
          },
          credentials: (effectiveUsername != null && effectivePassword != null)
              ? UserPass(username: effectiveUsername, password: effectivePassword)
              : null,
        ),
      );
      _currentRepo = repo;
      return repo;
    }, context: "cloning repository");
  }

  /// Get the commit log for the current repository.
  List<Commit> getLog({int limit = 100}) {
    if (_currentRepo == null) return [];
    
    return FfiErrorHandler.wrap(() {
      final walk = RevWalk(_currentRepo!);
      walk.sorting({GitSort.topological, GitSort.time});
      
      try {
        walk.pushHead();
      } catch (_) {
        return []; // Empty repo
      }
      
      final commits = <Commit>[];
      final walkResult = walk.walk();
      for (final commit in walkResult) {
        commits.add(commit);
        if (commits.length >= limit) break;
      }
      return commits;
    }, context: "getting commit log");
  }

  /// Get the status of the repository.
  Map<String, Set<GitStatus>> getStatus() {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    return FfiErrorHandler.wrap(() => _currentRepo!.status, context: "getting status");
  }

  /// Stage a file.
  void stage(String path) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final index = _currentRepo!.index;
      index.add(path);
      index.write();
    }, context: "staging file");
  }

  /// Unstage a file.
  void unstage(String path) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final index = _currentRepo!.index;
      index.remove(path);
      index.write();
    }, context: "unstaging file");
  }

  /// Create a commit.
  void commit({required String message, required Signature author}) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final index = _currentRepo!.index;
      final treeOid = index.writeTree();
      final tree = Tree.lookup(repo: _currentRepo!, oid: treeOid);
      
      final parents = <Commit>[];
      try {
        if (!_currentRepo!.isBranchUnborn) {
          parents.add(Commit.lookup(repo: _currentRepo!, oid: _currentRepo!.head.target));
        }
      } catch (_) {}

      Commit.create(
        repo: _currentRepo!,
        updateRef: 'HEAD',
        author: author,
        committer: author,
        message: message,
        tree: tree,
        parents: parents,
      );
    }, context: "committing changes");
  }

  /// List all local branches.
  List<Branch> getLocalBranches() {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    return FfiErrorHandler.wrap(() {
      return _currentRepo!.branchesLocal;
    }, context: "listing branches");
  }

  /// Checkout a [branchName].
  void checkout(String branchName) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final branch = _currentRepo!.branches.firstWhere((b) => b.name == branchName);
      Checkout.reference(repo: _currentRepo!, name: branch.name);
    }, context: "checkout branch");
  }

  /// Create a new branch.
  void createBranch(String name, {Commit? target}) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final commit = target ?? Commit.lookup(repo: _currentRepo!, oid: _currentRepo!.head.target);
      Branch.create(repo: _currentRepo!, name: name, target: commit);
    }, context: "creating branch");
  }

  /// Get the diff between index and working directory (if [staged] is false) 
  /// or between head and index (if [staged] is true).
  Diff getDiff({bool staged = false}) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    return FfiErrorHandler.wrap(() {
      if (staged) {
        final headOid = _currentRepo!.isBranchUnborn ? null : _currentRepo!.head.target;
        final tree = headOid != null ? Tree.lookup(repo: _currentRepo!, oid: headOid) : null;
        return Diff.treeToIndex(repo: _currentRepo!, tree: tree, index: _currentRepo!.index);
      } else {
        return Diff.indexToWorkdir(repo: _currentRepo!, index: _currentRepo!.index);
      }
    }, context: "getting diff");
  }

  /// Merge a [branchName] into the current HEAD.
  void merge(String branchName) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final branch = _currentRepo!.branches.firstWhere((b) => b.name == branchName);
      final ourCommit = Commit.lookup(repo: _currentRepo!, oid: _currentRepo!.head.target);
      final theirCommit = Commit.lookup(repo: _currentRepo!, oid: branch.target);
      
      Merge.commits(
        repo: _currentRepo!,
        ourCommit: ourCommit,
        theirCommit: theirCommit,
      );
    }, context: "merging branch");
  }

  /// Rebase the current HEAD onto [branchName].
  void rebase(String branchName) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final branch = _currentRepo!.branches.firstWhere((b) => b.name == branchName);
      final upstream = AnnotatedCommit.lookup(repo: _currentRepo!, oid: branch.target);
      
      final rebase = Rebase.init(repo: _currentRepo!, upstream: upstream);
      
      // For a simple non-interactive rebase, we iterate until done
      while (true) {
        try {
          rebase.next();
          rebase.commit(committer: Signature.create(
            name: "User",
            email: "user@example.com",
            time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ));
        } catch (_) {
          break; // No more operations or conflict
        }
      }
      rebase.finish();
      rebase.free();
    }, context: "rebasing branch");
  }

  /// Fetch from [remoteName].
  Future<void> fetch(String remoteName, {String? username, String? password, Account? authAccount}) async {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    String? effectiveUsername = username;
    String? effectivePassword = password;
    if (authAccount != null && _authService != null) {
      final token = await _authService.getToken(authAccount);
      if (token != null) {
        effectiveUsername = token;
        effectivePassword = '';
      }
    }
    return FfiErrorHandler.wrap(() {
      final remote = Remote.lookup(repo: _currentRepo!, name: remoteName);
      remote.fetch(
        callbacks: Callbacks(
          credentials: (effectiveUsername != null && effectivePassword != null)
              ? UserPass(username: effectiveUsername, password: effectivePassword)
              : null,
        ),
      );
    }, context: "fetching from remote");
  }

  /// Push current branch to [remoteName].
  Future<void> push(String remoteName, String branchName, {String? username, String? password, Account? authAccount}) async {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    String? effectiveUsername = username;
    String? effectivePassword = password;
    if (authAccount != null && _authService != null) {
      final token = await _authService.getToken(authAccount);
      if (token != null) {
        effectiveUsername = token;
        effectivePassword = '';
      }
    }
    return FfiErrorHandler.wrap(() {
      final remote = Remote.lookup(repo: _currentRepo!, name: remoteName);
      remote.push(
        refspecs: ['refs/heads/$branchName:refs/heads/$branchName'],
        callbacks: Callbacks(
          credentials: (effectiveUsername != null && effectivePassword != null)
              ? UserPass(username: effectiveUsername, password: effectivePassword)
              : null,
        ),
      );
    }, context: "pushing to remote");
  }

  /// Pull from [remoteName]. (Fetch + Merge)
  Future<void> pull(String remoteName, String branchName, {String? username, String? password, Account? authAccount}) async {
    await fetch(remoteName, username: username, password: password, authAccount: authAccount);
    merge('$remoteName/$branchName');
  }

  /// Get conflicts in the index.
  Map<String, ConflictEntry> getConflicts() {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    return FfiErrorHandler.wrap(() => _currentRepo!.index.conflicts, context: "getting conflicts");
  }

  /// Resolve a conflict by picking a side.
  void resolveConflict(String path, {required bool useOurs}) {
    if (_currentRepo == null) throw NoRepositoryLoadedFailure();
    FfiErrorHandler.wrap(() {
      final index = _currentRepo!.index;
      final conflict = index.conflicts[path];
      if (conflict == null) return;

      final entry = useOurs ? conflict.our : conflict.their;
      if (entry != null) {
        // To resolve, we add the chosen entry to the index at stage 0.
        // git2dart's index.add(entry) with stage 0 should do it.
        index.add(entry);
        index.write();
      }
    }, context: "resolving conflict");
  }

  void close() {
    _currentRepo?.free();
    _currentRepo = null;
  }
}
