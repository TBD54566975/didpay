import 'package:dap/dap.dart';
import 'package:didpay/features/dap/dap_form.dart';
import 'package:didpay/features/dap/dap_qr_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  group('DapForm', () {
    Widget dapFormTestWidget({AsyncValue<Dap>? dap, String? dapText}) =>
        WidgetHelpers.testableWidget(
          child: DapForm(
            buttonTitle: 'Next',
            dapText: ValueNotifier<String?>(dapText),
            dap: ValueNotifier<AsyncValue<Dap>?>(dap),
            onSubmit: (_, __) async {},
          ),
        );

    testWidgets('should show button title', (tester) async {
      await tester.pumpWidget(dapFormTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(dapFormTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          DapQrTile,
          "Don't know their DAP? Scan their QR code instead",
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show CircularProgressIndicator when DAP is loading',
        (tester) async {
      await tester.pumpWidget(dapFormTestWidget());
      await tester.pump(Duration.zero);

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(dapFormTestWidget(dap: const AsyncLoading()));
      await tester.pump(Duration.zero);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should show error message when the Next button is tapped and the dap text is invalid',
        (tester) async {
      const invalidDapText = 'invalid_dap_text';
      const expectedErrorMessage = 'Invalid DAP';

      await tester.pumpWidget(dapFormTestWidget(dapText: invalidDapText));
      await tester.pumpAndSettle();

      expect(find.text(expectedErrorMessage), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text(expectedErrorMessage), findsOneWidget);
    });

    testWidgets(
        'should resolve DAP without errors when the Next button is tapped and the dap text is valid',
        (tester) async {
      const validDapText = '@moegrammer/didpay.me';

      await tester.pumpWidget(dapFormTestWidget(dapText: validDapText));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid DAP'), findsNothing);
    });
  });
}
