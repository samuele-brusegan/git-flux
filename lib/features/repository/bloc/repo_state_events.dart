import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import '../widgets/commit_graph_painter.dart';
import '../models/diff_model.dart';

abstract class RepoEvent extends Equatable {
  const RepoEvent();
  @override
  List<Object?> get props => [];
}

class LoadRepository extends RepoEvent {
  final String path;
  const LoadRepository(this.path);
  @override
  List<Object?> get props => [path];
}

class RefreshRepository extends RepoEvent {}

class StageFile extends RepoEvent {
  final String path;
  const StageFile(this.path);
  @override
  List<Object?> get props => [path];
}

class UnstageFile extends RepoEvent {
  final String path;
  const UnstageFile(this.path);
  @override
  List<Object?> get props => [path];
}

class ToggleFileSelection extends RepoEvent {
  final String path;
  final bool isStaged;
  const ToggleFileSelection(this.path, this.isStaged);
  @override
  List<Object?> get props => [path, isStaged];
}

class LoadDiff extends RepoEvent {
  final bool staged;
  const LoadDiff({this.staged = false});
  @override
  List<Object?> get props => [staged];
}

class CreateBranch extends RepoEvent {
  final String name;
  const CreateBranch(this.name);
  @override
  List<Object?> get props => [name];
}

class CheckoutBranch extends RepoEvent {
  final String name;
  const CheckoutBranch(this.name);
  @override
  List<Object?> get props => [name];
}

class MergeBranch extends RepoEvent {
  final String name;
  const MergeBranch(this.name);
  @override
  List<Object?> get props => [name];
}

class RebaseBranch extends RepoEvent {
  final String name;
  const RebaseBranch(this.name);
  @override
  List<Object?> get props => [name];
}

class FetchRemote extends RepoEvent {
  final String remoteName;
  const FetchRemote(this.remoteName);
  @override
  List<Object?> get props => [remoteName];
}

class PullRemote extends RepoEvent {
  final String remoteName;
  final String branchName;
  const PullRemote(this.remoteName, this.branchName);
  @override
  List<Object?> get props => [remoteName, branchName];
}

class PushRemote extends RepoEvent {
  final String remoteName;
  final String branchName;
  const PushRemote(this.remoteName, this.branchName);
  @override
  List<Object?> get props => [remoteName, branchName];
}

class CommitChanges extends RepoEvent {
  final String message;
  final String authorName;
  final String authorEmail;

  const CommitChanges({
    required this.message,
    required this.authorName,
    required this.authorEmail,
  });

  @override
  List<Object?> get props => [message, authorName, authorEmail];
}

// --- States ---

abstract class RepoState extends Equatable {
  const RepoState();
  @override
  List<Object?> get props => [];
}

class RepoInitial extends RepoState {}

class RepoLoading extends RepoState {}

class RepoLoaded extends RepoState {
  final List<Commit> commits;
  final List<GraphNode> nodes;
  final Map<String, Set<GitStatus>> status;
  final String branchName;
  final List<Branch> branches;
  final Map<String, List<DiffHunkModel>>? currentDiff;

  final Map<String, ConflictEntry>? conflicts;

  const RepoLoaded({
    required this.commits,
    required this.nodes,
    required this.status,
    required this.branchName,
    required this.branches,
    this.currentDiff,
    this.conflicts,
  });

  @override
  List<Object?> get props => [commits, nodes, status, branchName, branches, currentDiff, conflicts];
}

class ResolveConflict extends RepoEvent {
  final String path;
  final bool useOurs;
  const ResolveConflict(this.path, {required this.useOurs});

  @override
  List<Object?> get props => [path, useOurs];
}

class SaveResolvedConflict extends RepoEvent {
  final String path;
  final String content;
  const SaveResolvedConflict(this.path, this.content);

  @override
  List<Object?> get props => [path, content];
}

class CreateRepository extends RepoEvent {
  final String path;
  const CreateRepository(this.path);

  @override
  List<Object?> get props => [path];
}

class CloneRepository extends RepoEvent {
  final String url;
  final String path;
  const CloneRepository(this.url, this.path);

  @override
  List<Object?> get props => [url, path];
}

class RepoError extends RepoState {
  final String message;
  const RepoError(this.message);
  @override
  List<Object?> get props => [message];
}
