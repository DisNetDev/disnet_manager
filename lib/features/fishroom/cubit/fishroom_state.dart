// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fishroom_cubit.dart';

class FishroomState {
  final List<BugReport> bugReports;
  final List<FishSuggestion> fishSuggestions;

  FishroomState({this.bugReports = const [], this.fishSuggestions = const []});

  FishroomState copyWith({
    List<BugReport>? bugReports,
    List<FishSuggestion>? fishSuggestions,
  }) {
    return FishroomState(
      bugReports: bugReports ?? this.bugReports,
      fishSuggestions: fishSuggestions ?? this.fishSuggestions,
    );
  }
}
