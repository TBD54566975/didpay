import 'package:didpay/features/kcc/kcc_agreement_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class KccTestPage extends HookWidget {
  const KccTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pfi = useState<NuPfi?>(null);
    useEffect(
      () {
        Future.microtask(() async {
          pfi.value =
              await NuPfi.fromDid('did:web:192.168.50.27%3A8892:ingress');
        });

        return;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: pfi.value == null
            ? const Center(child: CircularProgressIndicator())
            : KccAgreementPage(pfi: pfi.value!),
      ),
    );
  }
}
