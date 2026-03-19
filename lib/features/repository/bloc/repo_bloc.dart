import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git2dart/git2dart.dart';
import 'package:flux_git/data/services/git_service.dart';
import 'package:flux_git/features/repository/bloc/repo_state_events.dart';
import '../utils/graph_utils.dart';
import '../utils/diff_utils.dart';
import '../models/diff_model.dart';

class RepoBloc extends Bloc<RepoEvent, RepoState> {
  final GitService _gitService;

  RepoBloc({required GitService gitService})
      : _gitService = gitService,
        super(RepoInitial()) {
    on<LoadRepository>(_onLoadRepository);
    on<RefreshRepository>(_onRefreshRepository);
    on<StageFile>(_onStageFile);
    on<UnstageFile>(_onUnstageFile);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<LoadDiff>(_onLoadDiff);
    on<CreateBranch>(_onCreateBranch);
    on<CheckoutBranch>(_onCheckoutBranch);
    on<MergeBranch>(_onMergeBranch);
    on<RebaseBranch>(_onRebaseBranch);
    on<FetchRemote>(_onFetchRemote);
    on<PullRemote>(_onPullRemote);
    on<PushRemote>(_onPushRemote);
    on<CommitChanges>(_onCommitChanges);
    on<ResolveConflict>(_onResolveConflict);
  }

  Future<void> _onFetchRemote(FetchRemote event, Emitter<RepoState> emit) async {
    try {
      await _gitService.fetch(event.remoteName);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Fetch failed: $e"));
    }
  }

  Future<void> _onPullRemote(PullRemote event, Emitter<RepoState> emit) async {
    try {
      await _gitService.pull(event.remoteName, event.branchName);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Pull failed: $e"));
    }
  }

  Future<void> _onPushRemote(PushRemote event, Emitter<RepoState> emit) async {
    try {
      await _gitService.push(event.remoteName, event.branchName);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Push failed: $e"));
    }
  }

  Future<void> _onCreateBranch(CreateBranch event, Emitter<RepoState> emit) async {
    try {
      _gitService.createBranch(event.name);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Failed to create branch: $e"));
    }
  }

  Future<void> _onCheckoutBranch(CheckoutBranch event, Emitter<RepoState> emit) async {
    try {
      _gitService.checkout(event.name);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Failed to checkout: $e"));
    }
  }

  Future<void> _onMergeBranch(MergeBranch event, Emitter<RepoState> emit) async {
    try {
      _gitService.merge(event.name);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Merge failed: $e"));
    }
  }

  Future<void> _onRebaseBranch(RebaseBranch event, Emitter<RepoState> emit) async {
    try {
      _gitService.rebase(event.name);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Rebase failed: $e"));
    }
  }

  Future<void> _onLoadDiff(LoadDiff event, Emitter<RepoState> emit) async {
    final s = state;
    if (s is! RepoLoaded) return;
    
    try {
      final diff = _gitService.getDiff(staged: event.staged);
      final parsedDiff = DiffUtils.parseDiff(diff);
      // diff.free(); // git2dart handles it? Usually yes, but better check.
      
      emit(RepoLoaded(
        commits: s.commits,
        nodes: s.nodes,
        status: s.status,
        branchName: s.branchName,
        branches: s.branches,
        currentDiff: parsedDiff,
        conflicts: s.conflicts,
      ));
    } catch (e) {
      emit(RepoError("Failed to load diff: $e"));
    }
  }

  Future<void> _onLoadRepository(
      LoadRepository event, Emitter<RepoState> emit) async {
    emit(RepoLoading());
    try {
      await _gitService.open(event.path);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError(e.toString()));
    }
  }

  Future<void> _onRefreshRepository(
      RefreshRepository event, Emitter<RepoState> emit) async {
    final repo = _gitService.currentRepo;
    if (repo == null) {
      emit(const RepoError("No repository open"));
      return;
    }

    try {
      final commits = _gitService.getLog();
      final status = _gitService.getStatus();
      final branches = _gitService.getLocalBranches();
      final branch = repo.isBranchUnborn 
          ? "main" 
          : repo.head.name;
      
      final headOid = repo.isBranchUnborn ? null : repo.head.target;
      final nodes = GraphUtils.calculateNodes(commits, headOid);

      final conflicts = _gitService.getConflicts();

      emit(RepoLoaded(
        commits: commits,
        nodes: nodes,
        status: status,
        branchName: branch,
        branches: branches,
        conflicts: conflicts.isNotEmpty ? conflicts : null,
      ));
    } catch (e) {
      emit(RepoError("Failed to refresh: $e"));
    }
  }

  Future<void> _onToggleFileSelection(ToggleFileSelection event, Emitter<RepoState> emit) async {
    try {
      if (event.isStaged) {
        _gitService.unstage(event.path);
      } else {
        _gitService.stage(event.path);
      }
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Toggle failed: $e"));
    }
  }

  Future<void> _onStageFile(StageFile event, Emitter<RepoState> emit) async {
    _gitService.stage(event.path);
    add(RefreshRepository());
  }

  Future<void> _onUnstageFile(UnstageFile event, Emitter<RepoState> emit) async {
    _gitService.unstage(event.path);
    add(RefreshRepository());
  }

  Future<void> _onCommitChanges(
      CommitChanges event, Emitter<RepoState> emit) async {
    try {
      _gitService.commit(
        message: event.message,
        author: Signature.create(
          name: event.authorName,
          email: event.authorEmail,
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
      );
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Commit failed: $e"));
    }
  }

  Future<void> _onResolveConflict(ResolveConflict event, Emitter<RepoState> emit) async {
    try {
      _gitService.resolveConflict(event.path, useOurs: event.useOurs);
      add(RefreshRepository());
    } catch (e) {
      emit(RepoError("Failed to resolve conflict: $e"));
    }
  }
}
