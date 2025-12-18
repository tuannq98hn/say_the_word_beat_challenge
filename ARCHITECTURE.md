# Kiến trúc MVVM + BLoC

## Tổng quan

Dự án sử dụng kiến trúc MVVM (Model-View-ViewModel) kết hợp với BLoC (Business Logic Component) pattern.

## Cấu trúc thư mục

### lib/base/
Lớp nền cung cấp các class base cho toàn bộ ứng dụng:
- `base_bloc.dart`: BaseBloc với các method helper xử lý Either và Failure
- `base_bloc_state.dart`: BaseState với isLoading và error
- `network/api_client.dart`: ApiClient wrap Dio với error handling

### lib/common/
Tiện ích chia sẻ:
- `constants/`: App constants
- `extensions/`: String extensions, BuildContext extensions
- `local_store/`: LocalStore wrap SharedPreferences
- `logger/`: AppLogger cho logging
- `mixins/`: LoadingMixin và các mixin khác
- `notification/`: NotificationHelper cho local và top snackbar
- `theme/`: AppTheme (light/dark)

### lib/data/
Data layer chia thành:
- `error/`: Failure classes (ServerFailure, NetworkFailure, CacheFailure, UnknownFailure)
- `local/`: LocalDataSource interface và implementation
- `model/`: Data models (sử dụng freezed + json_serializable)
- `remote/`: ApiService (sử dụng Retrofit)
- `repositories/`: Repository pattern với Either return type

### lib/di/
Dependency Injection:
- `injection_container.dart`: GetIt setup với injectable
- `di_setup.config.dart`: Generated file (sau khi chạy build_runner)

### lib/routes/
Routing với go_router:
- `app_routes.dart`: Route constants
- `app_pages.dart`: GoRouter configuration

### lib/ui/
UI layer, mỗi feature có:
- `<feature>/bloc/`: Events, States, Bloc
- `<feature>/view/`: Pages/Widgets
- `<feature>/widgets/`: Reusable widgets (nếu có)

## Flow xử lý data

1. **UI** → gọi event trong Bloc
2. **Bloc** → gọi Repository
3. **Repository** → gọi DataSource (Remote/Local)
4. **DataSource** → trả về data hoặc throw exception
5. **Repository** → wrap kết quả trong Either<Failure, Data>
6. **Bloc** → xử lý Either, emit state mới
7. **UI** → listen state, update UI

## Pattern sử dụng

### BaseBloc Pattern
```dart
class FeatureBloc extends BaseBloc<FeatureEvent, FeatureState> {
  FeatureBloc() : super(const FeatureState()) {
    on<FeatureEvent>(_onFeatureEvent);
  }
  
  Future<void> _onFeatureEvent(
    FeatureEvent event,
    Emitter<FeatureState> emit,
  ) async {
    await handleEither(
      repository.getData(),
      onSuccess: (data) => emit(state.copyWith(data: data)),
      onError: (failure) => handleFailure(failure),
    );
  }
}
```

### Repository Pattern
```dart
@injectable
class FeatureRepository extends BaseRepository {
  final ApiService _apiService;
  
  Future<Either<Failure, Data>> getData() async {
    return handleError(() => _apiService.getData());
  }
}
```

### State Pattern
```dart
class FeatureState extends BaseBlocState {
  final Data? data;
  
  const FeatureState({
    super.isLoading = false,
    super.error,
    this.data,
  });
  
  @override
  FeatureState copyWith({...}) {
    return FeatureState(...);
  }
}
```

## Dependency Injection

Sử dụng `injectable` + `get_it`:
- Đăng ký dependencies trong `injection_container.dart`
- Sử dụng annotation: `@injectable`, `@singleton`, `@lazySingleton`
- Chạy `build_runner` để generate code

## Error Handling

- Sử dụng `dartz` Either để handle errors
- Failure classes trong `lib/data/error/failures.dart`
- BaseBloc có method `handleEither` để xử lý Either

## State Management

- BLoC pattern với flutter_bloc
- Mỗi feature có Bloc riêng kế thừa BaseBloc
- State kế thừa BaseBlocState với isLoading và error

## Testing

- Unit tests cho Bloc, Repository
- Widget tests cho UI
- Sử dụng `bloc_test` package

