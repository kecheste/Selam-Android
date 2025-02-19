part of 'matches_bloc.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object> get props => [];
}

final class MatchesInitial extends MatchesState {}

final class MatchLoadingState extends MatchesState {}

final class MatchSuccessState extends MatchesState {
  final List<MyUser> matches;

  const MatchSuccessState(this.matches);

  @override
  List<Object> get props => [matches];
}

final class MatchFailedState extends MatchesState {
  final String errorMessage;

  const MatchFailedState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
