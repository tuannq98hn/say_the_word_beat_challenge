import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  final bool isLoading;
  final String? error;

  const BaseBlocState({
    this.isLoading = false,
    this.error,
  });

  BaseBlocState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
  });

  @override
  List<Object?> get props => [isLoading, error];
}

