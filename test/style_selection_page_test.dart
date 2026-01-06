import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:say_word_challenge/ui/style_selection/view/style_selection_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StyleSelectionPage selects a style and completes', (tester) async {
    SharedPreferences.setMockInitialValues({});

    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StyleSelectionPage(
          onSelected: () {
            completed = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Choose Your Style'), findsOneWidget);

    await tester.tap(find.text('Classic Funk'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });
}

