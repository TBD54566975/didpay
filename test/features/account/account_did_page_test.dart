import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5/web5.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();

  group('AccountDidPage', () {
    testWidgets('should show the DID', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const AccountDidPage(),
          overrides: [didProvider.overrideWithValue(did)],
        ),
      );

      expect(find.text(did.uri), findsOneWidget);
    });
  });
}
