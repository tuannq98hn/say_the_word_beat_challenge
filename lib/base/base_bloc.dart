import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'base_bloc_state.dart';
import '../data/error/failures.dart';

abstract class BaseBloc<E, S extends BaseBlocState> extends Bloc<E, S> {
  BaseBloc(super.initialState);

  Future<void> handleEither<EitherType>(
    Either<Failure, EitherType> either, {
    required Function(EitherType data) onSuccess,
    Function(Failure failure)? onError,
  }) async {
    either.fold(
      (failure) {
        if (onError != null) {
          onError(failure);
        } else {
          handleFailure(failure);
        }
      },
      (data) => onSuccess(data),
    );
  }

  void handleFailure(Failure failure) {
    final newState = state.copyWith(
      isLoading: false,
      error: failure.message,
    );
    emit(newState as S);
  }

  void setLoading(bool isLoading) {
    final newState = state.copyWith(
      isLoading: isLoading,
      removeError: isLoading ? true : false,
    );
    emit(newState as S);
  }

  void setError(String? error) {
    final newState = state.copyWith(
      error: error,
      isLoading: false,
    );
    emit(newState as S);
  }
}

