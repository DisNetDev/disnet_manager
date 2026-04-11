import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/models/app_user.dart';
import 'package:disnet_manager/models/bug_report.dart';
import 'package:disnet_manager/models/fish_suggestion.dart';
import 'package:disnet_manager/models/tank.dart';
import 'package:disnet_manager/usecases/init_sb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fishroom_state.dart';

class FishroomCubit extends Cubit<FishroomState> {
  FishroomCubit() : super(FishroomState());

  Future<void> getTanks() async {
    try {
      final response =
          await fishroomAdmin.from('tanks').select('*').order('created_at');
      final tankReadings = await fishroomAdmin.from('tank_readings').select(
            'tank_id',
          );

      final readingCounts = <String, int>{};
      for (final reading in tankReadings as List) {
        final tankId = (reading as Map<String, dynamic>)['tank_id'] as String?;
        if (tankId == null || tankId.isEmpty) {
          continue;
        }

        readingCounts.update(tankId, (count) => count + 1, ifAbsent: () => 1);
      }

      if (response.isNotEmpty) {
        final tanks = (response as List).map((e) {
          final tank = e as Map<String, dynamic>;
          return Tank.fromMap({
            ...tank,
            'reading_count': readingCounts[tank['id']] ?? 0,
          });
        }).toList();
        emit(state.copyWith(tanks: tanks));
      } else {
        emit(state.copyWith(tanks: []));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getUsers() async {
    try {
      final response = await fishroomAdmin
          .from('users')
          .select('*')
          .order('email', ascending: true);

      if (response.isNotEmpty) {
        final users = (response as List)
            .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(users: users));
      } else {
        emit(state.copyWith(users: []));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTankReadings(String tankId) async {
    try {
      final response = await fishroomAdmin
          .from('tank_readings')
          .select('*')
          .eq('tank_id', tankId)
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List)
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

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
