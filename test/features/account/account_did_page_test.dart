import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5_flutter/web5_flutter.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  late MockKeyManager keyManager;

  setUp(() {
    keyManager = MockKeyManager();
  });

  group('AccountDidPage', () {
    testWidgets('should show the DID', (tester) async {
      const uri = 'did:example:123';

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountDidPage(), overrides: [
          didProvider.overrideWithValue(
            DidJwk(uri: uri, keyManager: keyManager),
          ),
        ]),
      );

      expect(find.text(uri), findsOneWidget);
    });
  });
}
