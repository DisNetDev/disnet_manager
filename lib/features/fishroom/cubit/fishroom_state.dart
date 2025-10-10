// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fishroom_cubit.dart';

class FishroomState {
  final List<BugReport> bugReports;

  FishroomState({this.bugReports = const []});

  FishroomState copyWith({
    List<BugReport>? bugReports,
  }) {
    return FishroomState(
      bugReports: bugReports ?? this.bugReports,
    );
  }
}
