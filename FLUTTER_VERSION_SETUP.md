# Hướng dẫn Setup Flutter 3.38.5

## Tình trạng hiện tại

Flutter đang dùng version 3.24.3 tại `/Users/tuannguyen/SDKS/stable` nhưng bạn cần 3.38.5 với Dart SDK 3.10.5+.

## Cách 1: Switch sang Flutter 3.38.5 (nếu đã cài)

Nếu bạn đã cài Flutter 3.38.5 ở đâu đó:

```bash
# Kiểm tra các Flutter version đã cài
ls -la ~/SDKS/

# Switch sang version 3.38.5 (ví dụ nếu có ở ~/SDKS/beta hoặc ~/SDKS/master)
export PATH=~/SDKS/[tên_thư_mục]/bin:$PATH

# Hoặc sử dụng fvm (Flutter Version Management) nếu đã cài
fvm use 3.38.5
```

## Cách 2: Upgrade Flutter hiện tại

```bash
# Chuyển sang beta channel để có version mới hơn
cd ~/SDKS/stable
git checkout beta
git pull
flutter upgrade

# Hoặc checkout version cụ thể 3.38.5 nếu có
git checkout 3.38.5
flutter upgrade
```

## Cách 3: Clone Flutter mới

```bash
# Clone Flutter version mới
cd ~/SDKS
git clone https://github.com/flutter/flutter.git -b stable flutter-3.38.5
cd flutter-3.38.5
flutter doctor

# Thêm vào PATH
export PATH=~/SDKS/flutter-3.38.5/bin:$PATH
```

## Sau khi có Flutter 3.38.5

1. Kiểm tra version:
   ```bash
   flutter --version
   dart --version
   ```

2. Đảm bảo Dart SDK >= 3.10.5

3. Chạy trong project:
   ```bash
   cd /Users/tuannguyen/Documents/Project/say_word_challenge
   flutter pub get
   flutter pub upgrade --major-versions
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Kiểm tra PATH

Đảm bảo Flutter 3.38.5 ở đầu PATH:
```bash
echo $PATH
which flutter
```

