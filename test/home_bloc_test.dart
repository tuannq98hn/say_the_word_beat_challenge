import 'package:flutter_test/flutter_test.dart';
import 'package:say_word_challenge/ui/home/bloc/home_bloc.dart';
import 'package:say_word_challenge/ui/home/bloc/home_event.dart';
import 'package:say_word_challenge/ui/home/bloc/home_state.dart';

void main() {
  group('HomeBloc', () {
    late HomeBloc homeBloc;

    setUp(() {
      homeBloc = HomeBloc();
    });

    test('initial state is HomeState', () {
      expect(homeBloc.state, const HomeState());
    });

    test('initial state has isLoading false', () {
      expect(homeBloc.state.isLoading, false);
    });

    test('HomeInitialized sets loading to true then false', () async {
      homeBloc.add(const HomeInitialized());
      await Future.delayed(const Duration(milliseconds: 100));
      expect(homeBloc.state.isLoading, false);
    });
  });
}

