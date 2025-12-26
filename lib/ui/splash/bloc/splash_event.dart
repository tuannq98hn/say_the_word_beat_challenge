import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashInitialized extends SplashEvent {
  const SplashInitialized();
}

class SplashCompleted extends SplashEvent {
  const SplashCompleted();
}

class OnCloseNative extends SplashEvent {
  const OnCloseNative();
}

class OnAppOpenAdEvent extends SplashEvent {
  const OnAppOpenAdEvent();
}
