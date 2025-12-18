# Hướng dẫn Upgrade để dùng SDK 3.10.5

## Vấn đề hiện tại

Bạn đã set SDK constraint là `>=3.10.5 <4.0.0` nhưng Flutter hiện tại (3.24.3) chỉ có Dart SDK 3.5.3.

## Giải pháp

### Cách 1: Upgrade Flutter (Khuyến nghị)

```bash
# Kiểm tra channel hiện tại
flutter channel

# Nếu đang ở stable, có thể cần chuyển sang beta hoặc master để có Dart SDK 3.10.5+
flutter channel beta
# hoặc
flutter channel master

# Upgrade Flutter
flutter upgrade

# Kiểm tra version mới
flutter --version
```

### Cách 2: Tạm thời dùng SDK constraint thấp hơn

Nếu bạn chưa muốn upgrade Flutter ngay, có thể dùng:

```yaml
environment:
  sdk: '>=3.5.0 <4.0.0'
```

Sau đó khi upgrade Flutter, có thể nâng lên `>=3.10.5 <4.0.0`.

## Sau khi upgrade Flutter

1. Cập nhật SDK constraint trong `pubspec.yaml`:
   ```yaml
   environment:
     sdk: '>=3.10.5 <4.0.0'
   ```

2. Cập nhật dependencies:
   ```bash
   flutter pub upgrade --major-versions
   ```

3. Chạy build_runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Kiểm tra:
   ```bash
   flutter analyze
   flutter test
   ```

## Lưu ý

- SDK 3.10.5 được phát hành vào 16/12/2025
- Có thể yêu cầu Flutter version mới hơn (beta/master channel)
- Một số packages có thể cần update để tương thích

