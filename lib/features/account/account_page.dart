import 'package:flutter/material.dart';
import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_vc_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('My DID'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountDidPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('My verifiable credential'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountVCPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
