enum BreakMode {
  throne('THRONE', 'EARNED WHILE SHITTING', 'Corporate dump'),
  smoke('SMOKE', 'EARNED WHILE SMOKING', 'Smoke break'),
  lunch('LUNCH', 'EARNED WHILE EATING', 'Lunch heist'),
  doomscroll('DOOMSCROLL', 'EARNED WHILE SCROLLING', 'Doomscroll session',
      pro: true),
  meeting('FAKE MEETING', 'EARNED IN A "MEETING"', 'Fake meeting', pro: true),
  coffee('COFFEE RUN', 'EARNED ON A COFFEE RUN', 'Coffee run', pro: true);

  const BreakMode(this.label, this.earnedHeadline, this.receiptItem,
      {this.pro = false});

  final String label;
  final String earnedHeadline;
  final String receiptItem;
  final bool pro;

  static List<BreakMode> available({required bool isPro}) =>
      values.where((m) => isPro || !m.pro).toList();
}
