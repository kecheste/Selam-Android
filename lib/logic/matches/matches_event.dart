part of 'matches_bloc.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object> get props => [];
}

class GetPossibleMatches extends MatchesEvent {
  const GetPossibleMatches();
}

class UpdateMatches extends MatchesEvent {
  final List<MyUser> matches;

  const UpdateMatches(this.matches);

  @override
  List<Object> get props => [matches];
}

class UpdatePossibleMatches extends MatchesEvent {
  final List<MyUser> matches;

  const UpdatePossibleMatches(this.matches);

  @override
  List<Object> get props => [matches];
}

class GetMatches extends MatchesEvent {
  const GetMatches();
}

class GetMatchesByLocation extends MatchesEvent {
  const GetMatchesByLocation();
}

class CheckMatches extends MatchesEvent {
  const CheckMatches();
}
