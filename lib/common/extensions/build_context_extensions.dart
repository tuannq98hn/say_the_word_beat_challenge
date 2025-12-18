import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  
  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => mediaQuery.size.width;

  double get screenHeight => mediaQuery.size.height;

  double get statusBarHeight => mediaQuery.padding.top;

  double get bottomBarHeight => mediaQuery.padding.bottom;

  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  double responsiveWidth(double width) => width.w;

  double responsiveHeight(double height) => height.h;

  double responsiveFontSize(double fontSize) => fontSize.sp;
}

