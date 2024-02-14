import 'package:didpay/features/account/account_providers.dart';
import 'package:flutter/material.dart';
import 'package:didpay/features/send/send_did_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5_flutter/web5_flutter.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  late MockKeyManager keyManager;

  setUp(() {
    keyManager = MockKeyManager();
  });

  group('SendDidPage', () {
    const uri = 'did:example:123';

    testWidgets('should show amount to send', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: SendDidPage(sendAmount: '25'),
            overrides: [
              didProvider.overrideWithValue(
                DidJwk(uri: uri, keyManager: keyManager),
              ),
            ]),
      );

      expect(find.textContaining('\$25'), findsOneWidget);
    });

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: SendDidPage(sendAmount: '25'),
            overrides: [
              didProvider.overrideWithValue(
                DidJwk(uri: uri, keyManager: keyManager),
              ),
            ]),
      );

      expect(find.textContaining('Scan their QR code'), findsOneWidget);
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: SendDidPage(sendAmount: '25'),
            overrides: [
              didProvider.overrideWithValue(
                DidJwk(uri: uri, keyManager: keyManager),
              ),
            ]),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show pay button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: SendDidPage(sendAmount: '25'),
            overrides: [
              didProvider.overrideWithValue(
                DidJwk(uri: uri, keyManager: keyManager),
              ),
            ]),
      );

      expect(find.widgetWithText(FilledButton, 'Pay \$25'), findsOneWidget);
    });
  });
}
