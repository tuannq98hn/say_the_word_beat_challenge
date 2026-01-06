import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:say_word_challenge/ui/guide/view/guide_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GuidePage advances steps and completes', (tester) async {
    SharedPreferences.setMockInitialValues({});

    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: GuidePage(
          onCompleted: () {
            completed = true;
          },
        ),
      ),
    );

    expect(find.text('Say On Beat'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);

    await tester.tap(find.text('Next Step').first);
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Watch The Flash'), findsOneWidget);

    await tester.tap(find.text('Next Step').first);
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Increase Speed'), findsOneWidget);

    await tester.tap(find.text('Next Step').first);
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Create Yours'), findsOneWidget);
    expect(find.text("Let's Play!"), findsOneWidget);

    await tester.tap(find.text("Let's Play!"));
    await tester.pump(const Duration(milliseconds: 100));
    expect(completed, isTrue);
  });
}

