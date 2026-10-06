import 'package:flutter/material.dart';

import 'ledger/ledger_screen.dart';
import 'pro/perks_screen.dart';
import 'timer/timer_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [TimerScreen(), LedgerScreen(), PerksScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: ink))),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.timer_outlined), label: 'CLOCK'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined), label: 'LEDGER'),
            NavigationDestination(
                icon: Icon(Icons.workspace_premium_outlined), label: 'PERKS'),
          ],
        ),
      ),
    );
  }
}
