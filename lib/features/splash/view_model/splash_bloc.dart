import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SharedPreferences _prefs;

  SplashBloc(this._prefs) : super(const SplashState()) {
    on<SplashAppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(SplashAppStarted event, Emitter<SplashState> emit) async {
    emit(state.copyWith(status: SplashStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1800));

    final token = _prefs.getString(AppConstants.keyAuthToken);
    if (token != null && token.trim().isNotEmpty) {
      emit(state.copyWith(status: SplashStatus.authenticated));
    } else {
      emit(state.copyWith(status: SplashStatus.unauthenticated));
    }
  }
}
