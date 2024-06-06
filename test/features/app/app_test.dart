import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();
  const pfi = Pfi(did: 'did:web:x%3A8892:ingress');

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;
  late MockVcsNotifier mockVcsNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier([pfi]);
    mockVcsNotifier = MockVcsNotifier([]);

    when(
      () => mockTbdexService.getExchanges(did, [pfi]),
    ).thenAnswer((_) async => {});
  });

  testWidgets('should show AppTabs', (tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(
        child: const AppTabs(),
        overrides: [
          didProvider.overrideWithValue(did),
          tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
          pfisProvider.overrideWith((ref) => mockPfisNotifier),
          vcsProvider.overrideWith((ref) => mockVcsNotifier),
          transactionProvider.overrideWith(MockTransactionNotifier.new),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTabs), findsOneWidget);
  });
}
