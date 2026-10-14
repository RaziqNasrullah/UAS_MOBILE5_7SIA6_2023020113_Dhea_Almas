import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neolearn/app/widgets/jenjang_badge.dart';
import 'package:neolearn/app/widgets/qty_stepper.dart';
import 'package:neolearn/app/widgets/state_views.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('QtyStepper tidak melewati batas stok', (tester) async {
    var value = 2;
    var maxReached = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => _wrap(
          QtyStepper(
            value: value,
            max: 3,
            onChanged: (v) => setState(() => value = v),
            onMaxReached: () => maxReached = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(maxReached, isTrue);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove_rounded)); // sudah di minimum 1
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('ErrorState menampilkan tombol Coba Lagi', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(ErrorState(message: 'Server mati', onRetry: () => retried = true)));
    expect(find.text('Server mati'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    expect(retried, isTrue);
  });

  testWidgets('JenjangBadge menampilkan label', (tester) async {
    await tester.pumpWidget(_wrap(const JenjangBadge(jenjang: 'SMA/SMK')));
    expect(find.text('SMA/SMK'), findsOneWidget);
  });
}
