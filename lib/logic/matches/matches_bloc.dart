import 'package:bloc/bloc.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/match.dart';
import 'package:equatable/equatable.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchRepository matchRepository;

  MatchesBloc({required this.matchRepository}) : super(MatchesInitial()) {
    on<GetPossibleMatches>(_onGetPossibleMatches);
    on<GetMatches>(_onGetMatches);
    on<GetMatchesByLocation>(_onGetMatchesByLocation);
    on<UpdateMatches>(_onUpdateMatches);

    // matchRepository.streamPossibleMatches().listen((matches) {
    //   add(UpdatePossibleMatches(matches));
    // });
    // matchRepository.streamMatches().listen((matches) {
    // add(UpdateMatches(matches));
    // });
  }

  Future<void> _onGetPossibleMatches(
      GetPossibleMatches event, Emitter<MatchesState> emit) async {
    emit(MatchLoadingState());
    try {
      final List<MyUser> matches = await matchRepository.getPossibleMatches();
      emit(MatchSuccessState(matches));
    } catch (e) {
      emit(MatchFailedState("Get Possible Matches Error: ${e.toString()}"));
    }
  }

  Future<void> _onGetMatches(
      GetMatches event, Emitter<MatchesState> emit) async {
    emit(MatchLoadingState());
    try {
      final List<MyUser> matches = await matchRepository.getMatches();
      emit(MatchSuccessState(matches));
    } catch (e) {
      emit(MatchFailedState("Get Matches Error: ${e.toString()}"));
    }
  }

  Future<void> _onGetMatchesByLocation(
      GetMatchesByLocation event, Emitter<MatchesState> emit) async {
    emit(MatchLoadingState());
    try {
      final List<MyUser> matches = await matchRepository.getMatchesByLocation();
      emit(MatchSuccessState(matches));
    } catch (e) {
      emit(MatchFailedState("Get Matches By Location Error: ${e.toString()}"));
    }
  }

  void _onUpdateMatches(UpdateMatches event, Emitter<MatchesState> emit) {
    emit(MatchSuccessState(event.matches));
  }
}
