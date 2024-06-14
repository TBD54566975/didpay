import 'package:didpay/features/account/account_page.dart';
import 'package:didpay/features/did/did_qr_tabs.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  late MockPfisNotifier mockPfisNotifier;
  late MockVcsNotifier mockVcsNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  group('AccountPage', () {
    setUp(() {
      mockPfisNotifier = MockPfisNotifier([]);
      mockVcsNotifier = MockVcsNotifier([]);
      mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);
    });

    Widget accountPageTestWidget() => WidgetHelpers.testableWidget(
          child: const AccountPage(),
          overrides: [
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
            vcsProvider.overrideWith((ref) => mockVcsNotifier),
            featureFlagsProvider
                .overrideWith((ref) => mockFeatureFlagsNotifier),
          ],
        );

    testWidgets('should show DAP', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      expect(find.text(TestData.dap), findsOneWidget);
    });

    testWidgets('should show linked pfis', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      expect(find.text('Linked PFIs'), findsOneWidget);
    });

    testWidgets('should show add a pfi tile', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      expect(find.widgetWithText(ListTile, 'Add a PFI'), findsOneWidget);
    });

    testWidgets('should show issued credentials', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      expect(find.text('Issued credentials'), findsOneWidget);
    });

    testWidgets('should show no credentials issued yet tile', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      expect(
        find.widgetWithText(ListTile, 'No credentials issued yet'),
        findsOneWidget,
      );
    });

    testWidgets('should show DidQrTabs on tap of qr icon', (tester) async {
      await tester.pumpWidget(accountPageTestWidget());

      await tester.tap(find.widgetWithIcon(IconButton, Icons.qr_code));
      await tester.pumpAndSettle();
      expect(find.byType(DidQrTabs), findsOneWidget);
    });
  });
}
