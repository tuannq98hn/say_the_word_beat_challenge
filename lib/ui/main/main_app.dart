import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:say_word_challenge/ui/app/bloc/app_bloc.dart';
import 'package:say_word_challenge/ui/app/bloc/app_state.dart';

import '../../common/theme/app_theme.dart';
import '../../routes/app_pages.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Say Word Challenge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: AppPages.router,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<AppBloc>(
                  create: (BuildContext context) => AppBloc(),
                ),
              ],
              child: BlocBuilder<AppBloc, AppState>(
                builder: (ctx, state) =>
                    Container(color: Colors.black, child: child),
              ),
            );
          },
        );
      },
    );
  }
}
