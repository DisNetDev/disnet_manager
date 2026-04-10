// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fishroom_cubit.dart';

class FishroomState {
  final List<BugReport> bugReports;
  final List<FishSuggestion> fishSuggestions;
  final List<AppUser> users;
  final List<Tank> tanks;

  FishroomState({
    this.bugReports = const [],
    this.fishSuggestions = const [],
    this.users = const [],
    this.tanks = const [],
  });

  FishroomState copyWith({
    List<BugReport>? bugReports,
    List<FishSuggestion>? fishSuggestions,
    List<AppUser>? users,
    List<Tank>? tanks,
  }) {
    return FishroomState(
      bugReports: bugReports ?? this.bugReports,
      fishSuggestions: fishSuggestions ?? this.fishSuggestions,
      users: users ?? this.users,
      tanks: tanks ?? this.tanks,
    );
  }
}
