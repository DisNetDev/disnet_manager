import 'dart:developer';

import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/usecases/init_sb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState());

  Future<void> getUsers({App? app}) async {
    int totalCount = 0;
    if (app == App.fishroom || app == null) {
      try {
        final fishroomUsers =
            await fishroomAdmin.from('users').select('*').count();
        totalCount += fishroomUsers.count;
      } catch (e) {
        log(e.toString());
      }
    }

    emit(state.copyWith(userCount: totalCount));
  }

  Future<void> getSubscriptions({App? app}) async {
    int totalCount = 0;
    if (app == App.fishroom || app == null) {
      try {
        final fishroomSubscriptions = await fishroomAdmin
            .from('users')
            .select('*')
            .eq('premium', true)
            .count();
        totalCount += fishroomSubscriptions.count;
      } catch (e) {
        log(e.toString());
      }
    }

    emit(state.copyWith(subscriptionCount: totalCount));
  }
}
