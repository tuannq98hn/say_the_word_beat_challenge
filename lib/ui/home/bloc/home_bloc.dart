import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeInitialized>(_onHomeInitialized);
  }

  Future<void> _onHomeInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    setLoading(false);
  }
}

