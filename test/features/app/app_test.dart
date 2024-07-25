import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;
  final pfis = TestData.getPfis();

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;
  late MockVcsNotifier mockVcsNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier(pfis);
    mockVcsNotifier = MockVcsNotifier([]);
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);

    when(
      () => mockTbdexService.getExchanges(did, pfis),
    ).thenAnswer((_) async => {});

    when(
      () => mockTbdexService.getAccountBalance(did, pfis),
    ).thenAnswer(
      (_) async => TestData.getAccountBalance(),
    );
  });

  testWidgets('should show AppTabs', (tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(
        child: const AppTabs(),
        overrides: [
          didProvider.overrideWith((ref) => did),
          tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
          pfisProvider.overrideWith((ref) => mockPfisNotifier),
          vcsProvider.overrideWith((ref) => mockVcsNotifier),
          featureFlagsProvider.overrideWith((ref) => mockFeatureFlagsNotifier),
          transactionProvider.overrideWith(MockTransactionNotifier.new),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTabs), findsOneWidget);
  });
}
