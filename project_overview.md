# Flutter Base MVVM BLoC

Tài liệu này tóm tắt stack kỹ thuật, cấu trúc thư mục và quy trình đề xuất khi mở rộng dự án Flutter theo kiến trúc MVVM kết hợp BLoC.

## Thư viện sử dụng

- **Kiến trúc & State**
  - `flutter_bloc`: quản lý state theo mô hình BLoC với `BaseBloc` dùng chung.
  - `equatable`: đơn giản hóa so sánh state/event.
  - `event_bus`: phát sự kiện toàn cục khi cần giao tiếp lỏng lẻo giữa các lớp.
- **DI & Code generation**
  - `injectable` + `get_it`: cấu hình dependency injection trong `di_setup.dart`.
  - `freezed_annotation`, `json_annotation`, `copy_with_extension`: sinh model/builder bất biến, JSON (kèm `build_runner`, `freezed`, `json_serializable`, `copy_with_extension_gen`, `injectable_generator`, `retrofit_generator`, `flutter_gen_runner` ở mục dev).
- **Networking & Data**
  - `dio`, `retrofit`: build API client (xem `ApiService`), hỗ trợ interceptor/error mapping.
  - `dartz`: cung cấp `Either` cho lớp repository xử lý lỗi rõ ràng.
  - `shared_preferences`: lưu local data nhẹ, ví dụ token hoặc cài đặt người dùng.
- **UI/UX**
  - `cupertino_icons`, `flutter_svg`, `cached_network_image`, `shimmer`: phần nền UI hiện đại.
  - `flutter_screenutil`: responsive layout đa thiết bị.
  - `infinite_scroll_pagination`, `top_snackbar_flutter`: trải nghiệm danh sách dài & thông báo.
- **Đa ngôn ngữ & cấu hình**
  - `easy_localization`: quản lý bản dịch trong `assets/translations`.
  - `flutter_gen`: sinh constant cho asset/fonts giúp tránh hard-code.
  - `flutter_dotenv`, `package_info_plus`: nạp biến môi trường & thông tin build.
- **Kết nối & dịch vụ nền**
  - `connectivity_plus`: kiểm tra trạng thái mạng để điều chỉnh luồng dữ liệu.
  - `firebase_core`, `firebase_messaging`, `flutter_local_notifications`: thiết lập push notification, xử lý nhận/gửi thông báo cục bộ.

## Cấu trúc thư mục chính

- `lib/base`: lớp nền gồm `BaseBloc`, trạng thái, xử lý mạng (`base/network`) để các feature kế thừa.
- `lib/common`: nơi đặt tiện ích chia sẻ (extension, mixin, theme, logger, notification helper, local store).
- `lib/data`: chia thành `remote`, `local`, `repositories`, `model`, `error` giúp phân lớp rõ ràng giữa tầng datasource và repository.
- `lib/di`: cấu hình `injectable` và module DI vận hành `get_it`.
- `lib/routes`: định nghĩa tuyến với `go_router` (`app_routes.dart`, `app_pages.dart`).
- `lib/ui`: mỗi màn hình/feature nằm trong một thư mục con với view, bloc, widget chuyên biệt (ví dụ `lib/ui/home`).
- `assets`: chứa hình ảnh, bản dịch, file cấu hình môi trường.
- `test`: là nơi đặt unit test/widget test khi bổ sung.

## Flow phát triển feature mới

1. **Xác định hợp đồng dữ liệu**
   - Tạo/ cập nhật model trong `lib/data/model/<feature>` (sử dụng `freezed` + `json_serializable`).
   - Nếu cần API mới, thêm method vào `ApiService` và sinh code `retrofit`.
2. **Datasource & Repository**
   - Viết lớp datasource (remote/local) trong `lib/data/remote` hoặc `lib/data/local`.
   - Thêm repository trong `lib/data/repositories/<feature>`, trả về `Either` để phản hồi lỗi thống nhất.
   - Đăng ký các lớp mới vào `lib/di/app_module.dart` rồi chạy `flutter pub run build_runner build --delete-conflicting-outputs`.
3. **State management**
   - Tạo `Bloc` hoặc `Cubit` kế thừa `BaseBloc` tại `lib/ui/<feature>/bloc`, định nghĩa `State` mở rộng từ `BaseBlocState`.
   - Kết nối repository qua constructor (được inject).
4. **UI & Route**
   - Thêm màn hình trong `lib/ui/<feature>/view` và widget cần thiết trong thư mục con.
   - Đăng ký tuyến mới trong `lib/routes/app_pages.dart` + `app_routes.dart`, cập nhật `GoRouter`.
5. **Localization & Assets**
   - Bổ sung text vào `assets/translations`, chạy lại `flutter gen` nếu dùng key mới.
   - Thêm asset vào `assets/images` và cấu hình trong `pubspec.yaml` khi cần.
6. **Kiểm thử & tài liệu**
   - Viết test cho bloc/repository trong `test/`.
   - Cập nhật tài liệu hoặc hướng dẫn release nếu feature ảnh hưởng quy trình build.

## Đánh giá dự án

- **Điểm tự đánh giá**: 8/10.
- **Ưu điểm**: kiến trúc rõ ràng, DI + Retrofit + Freezed giúp mã dễ mở rộng; tích hợp sẵn notification, localization, responsive UI.
- **Hạn chế**: README và test còn tối thiểu, chưa mô tả CI/CD, thiếu guideline coding chuẩn hóa cho nhiều module.
- **Đề xuất**: bổ sung ví dụ feature mẫu hoàn chỉnh, quy ước đặt tên, cùng checklist test để nâng tính sẵn sàng sản xuất.
