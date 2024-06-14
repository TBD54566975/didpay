import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/account/account_page.dart';
import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();
  final accountBalance =
      AccountBalance(total: '101', currencyCode: 'USD', balancesMap: {});
  const pfi = Pfi(did: 'did:web:x%3A8892:ingress');

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;
  late MockVcsNotifier mockVcsNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier([pfi]);
    mockVcsNotifier = MockVcsNotifier([]);
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);

    when(
      () => mockTbdexService.getExchanges(did, [pfi]),
    ).thenAnswer((_) async => {});

    when(
      () => mockTbdexService.getAccountBalance([pfi]),
    ).thenAnswer(
      (_) async =>
          AccountBalance(total: '0', currencyCode: 'USD', balancesMap: {}),
    );
  });

  group('AppTabs', () {
    Widget appTabsTestWidget() => WidgetHelpers.testableWidget(
          child: const AppTabs(),
          overrides: [
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
            vcsProvider.overrideWith((ref) => mockVcsNotifier),
            featureFlagsProvider
                .overrideWith((ref) => mockFeatureFlagsNotifier),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            accountBalanceProvider
                .overrideWith(() => MockAccountBalanceNotifier(accountBalance)),
          ],
        );

    testWidgets('should start on HomePage', (tester) async {
      await tester.pumpWidget(appTabsTestWidget());

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should show SendPage when tapped', (tester) async {
      await tester.pumpWidget(appTabsTestWidget());

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.byType(SendPage), findsOneWidget);
    });

    testWidgets('should show AccountPage when tapped', (tester) async {
      await tester.pumpWidget(appTabsTestWidget());

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountPage), findsOneWidget);
    });
  });
}
