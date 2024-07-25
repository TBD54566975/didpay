import 'package:didpay/features/did/did_qr_code_page.dart';
import 'package:didpay/features/did/did_qr_scan_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DidQrTabs extends HookWidget {
  final String dap;

  const DidQrTabs({required this.dap, super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const DidQrScanPage(),
              DidQrCodePage(dap: dap),
            ],
          ),
          Positioned(
            left: Grid.xxl,
            right: Grid.xxl,
            bottom: Grid.xxl,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Grid.radius),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(Grid.radius),
                  color: Theme.of(context).colorScheme.background,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(Grid.quarter),
                dividerColor: Colors.transparent,
                labelColor: Theme.of(context).colorScheme.onBackground,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onBackground,
                tabs: [
                  Tab(text: Loc.of(context).scan),
                  Tab(text: Loc.of(context).myDid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
