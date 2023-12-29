import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/auth/auth_widget_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class AuthDidPage extends HookConsumerWidget {
  const AuthDidPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = useState<String?>(null);

    useEffect(() {
      Future.microtask(() async {
        final keyManager = InMemoryKeyManager();
        final jwt = await DidJwk.create(keyManager: keyManager);
        did.value = jwt.uri;
      });

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).appName)),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Loc.of(context).congratsOnYourDid,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 40),
                    if (did.value == null) const CircularProgressIndicator(),
                    if (did.value != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        did.value!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (did.value != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      child: Text(Loc.of(context).verifyIdentity),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthWidgetPage(),
                          fullscreenDialog: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
