import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/models/bug_report.dart';
import 'package:disnet_manager/models/fish_suggestion.dart';
import 'package:disnet_manager/usecases/init_sb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fishroom_state.dart';

class FishroomCubit extends Cubit<FishroomState> {
  FishroomCubit() : super(FishroomState());

  Future<void> getBugReports() async {
    try {
      final response = await fishroomAdmin
          .from('bug_reports')
          .select("""*, user:users(*)""").order('created_at', ascending: false);
      if (response.isNotEmpty) {
        final bugReports = (response as List)
            .map((e) =>
                BugReport.fromMap(e as Map<String, dynamic>, app: App.fishroom))
            .toList();
        emit(state.copyWith(bugReports: bugReports));
      } else {
        emit(state.copyWith(bugReports: []));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBugReport(BugReport report) async {
    try {
      fishroomAdmin
          .from("bug_reports")
          .update(report.copyWith(updatedAt: DateTime.now()).toMap())
          .eq("id", report.id);

      emit(state.copyWith(
          bugReports: state.bugReports
              .map((e) => e.id == report.id ? report : e)
              .toList()));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleResolvedBugReport(BugReport report) async {
    try {
      await fishroomAdmin
          .from("bug_reports")
          .update({"is_resolved": !report.isResolved}).eq("id", report.id);
      emit(state.copyWith(
          bugReports: state.bugReports
              .map((e) => e.id == report.id
                  ? report.copyWith(isResolved: !report.isResolved)
                  : e)
              .toList()));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getFishSuggestions() async {
    try {
      final response = await fishroomAdmin
          .from('fish_suggestions')
          .select("""*, user:users(*), fish:fish(*)""").order('created_at',
              ascending: false);
      if (response.isNotEmpty) {
        final suggestions = (response as List)
            .map((e) => FishSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(fishSuggestions: suggestions));
      } else {
        emit(state.copyWith(fishSuggestions: []));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFishSuggestion(String fishSuggestionId) async {
    try {
      await fishroomAdmin.rpc(
        'upsert_fish_from_suggestion',
        params: {'p_fish_suggestion_id': fishSuggestionId},
      );

      emit(
        state.copyWith(
          fishSuggestions: state.fishSuggestions
              .where((suggestion) => suggestion.id != fishSuggestionId)
              .toList(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFishSuggestion(String fishSuggestionId) async {
    try {
      await fishroomAdmin
          .from('fish_suggestions')
          .delete()
          .eq('id', fishSuggestionId);

      emit(
        state.copyWith(
          fishSuggestions: state.fishSuggestions
              .where((suggestion) => suggestion.id != fishSuggestionId)
              .toList(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
