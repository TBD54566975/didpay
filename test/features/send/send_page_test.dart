import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;

  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);
  });

  group('SendPage', () {
    Widget sendDetailsPageTestWidget() => WidgetHelpers.testableWidget(
          child: const SendPage(),
          overrides: [
            didProvider.overrideWith((ref) => did),
            featureFlagsProvider
                .overrideWith((ref) => mockFeatureFlagsNotifier),
          ],
        );

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(
        find.widgetWithText(
          ListTile,
          "Don't know their DAP? Scan their QR code instead",
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });
  });
}
