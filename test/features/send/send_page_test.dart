import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_details_page.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/number/number_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();
  const pfi = Pfi(did: 'did:web:x%3A8892:ingress');

  final accountBalance =
      AccountBalance(total: '101', currencyCode: 'USD', balancesMap: {});

  late MockPfisNotifier mockPfisNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockPfisNotifier = MockPfisNotifier([pfi]);
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);
  });

  group('SendPage', () {
    Widget sendPageTestWidget() => WidgetHelpers.testableWidget(
          child: const SendPage(),
          overrides: [
            didProvider.overrideWithValue(did),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
            featureFlagsProvider
                .overrideWith((ref) => mockFeatureFlagsNotifier),
            accountBalanceProvider
                .overrideWith(() => MockAccountBalanceNotifier(accountBalance)),
          ],
        );

    testWidgets('should show Number Pad', (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      expect(find.byType(NumberPad), findsOneWidget);
    });

    testWidgets('should show send button', (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
    });

    testWidgets('should show disabled next button while payin in 0',
        (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      final nextButton = find.widgetWithText(NextButton, 'Send');

      expect(
        tester.widget<NextButton>(nextButton).onPressed,
        isNull,
      );
    });

    testWidgets('should show enabled next button when payin is not 0',
        (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(FilledButton, 'Send');

      expect(
        tester.widget<FilledButton>(nextButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('should change send amount after number pad press',
        (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      for (var i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AutoSizeText, '$i'), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pumpAndSettle();
      }

      expect(find.widgetWithText(AutoSizeText, '0'), findsOneWidget);
    });

    testWidgets(
        'should pad send amount with a leading zero if send amount < a dollar',
        (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      await tester.tap(find.text('.'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AutoSizeText, '0.00'), findsOneWidget);
    });

    testWidgets('should navigate to SendDetailsPage on tap of send button',
        (tester) async {
      await tester.pumpWidget(sendPageTestWidget());

      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.byType(SendDetailsPage), findsOneWidget);
    });
  });
}
