# Hướng dẫn Setup Dự án

## Cấu trúc thư mục

```
lib/
├── base/              # Lớp nền (BaseBloc, BaseState, network)
├── common/            # Tiện ích chia sẻ (extensions, mixins, theme, logger, notification, local store)
├── data/              # Data layer (remote, local, repositories, model, error)
├── di/                # Dependency Injection (injectable + get_it)
├── routes/            # Routing (go_router)
└── ui/                # UI layer (mỗi feature có view, bloc, widget)
    └── home/          # Feature mẫu
        ├── bloc/
        └── view/
```

## Cài đặt dependencies

```bash
flutter pub get
```

## Generate code

Sau khi cài đặt dependencies, cần chạy build_runner để generate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ generate:
- `lib/data/model/base_model.g.dart`
- `lib/data/remote/api_service.g.dart`
- `lib/di/di_setup.config.dart`

## Tạo file .env

Copy file `.env.example` và tạo file `.env`:

```bash
cp .env.example .env
```

Sau đó cập nhật `BASE_URL` trong file `.env`.

## Chạy ứng dụng

```bash
flutter run
```

## Flow phát triển feature mới

1. **Tạo Model**: Tạo model trong `lib/data/model/<feature>` với `freezed` + `json_serializable`
2. **Tạo API Service**: Thêm method vào `ApiService` nếu cần
3. **Tạo Repository**: Tạo repository trong `lib/data/repositories/<feature>` trả về `Either`
4. **Tạo Bloc**: Tạo Bloc kế thừa `BaseBloc` trong `lib/ui/<feature>/bloc`
5. **Tạo UI**: Tạo view trong `lib/ui/<feature>/view`
6. **Đăng ký Route**: Thêm route trong `lib/routes/app_pages.dart`
7. **Chạy build_runner**: Sau khi thêm mới các class có annotation, chạy lại build_runner

## Kiến trúc MVVM + BLoC

- **Model**: Data models trong `lib/data/model`
- **View**: UI components trong `lib/ui/<feature>/view`
- **ViewModel**: BLoC trong `lib/ui/<feature>/bloc`

Mỗi feature tuân theo pattern:
- `Event`: Định nghĩa các event trong `bloc/<feature>_event.dart`
- `State`: Định nghĩa state trong `bloc/<feature>_state.dart`
- `Bloc`: Xử lý logic trong `bloc/<feature>_bloc.dart`
- `View`: UI trong `view/<feature>_page.dart`

