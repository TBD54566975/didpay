import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirmation_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentConfirmationPage extends HookWidget {
  const PaymentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: ConfirmationMessage(
            message: Loc.of(context).orderConfirmed,
          ),
        ),
      );
}
