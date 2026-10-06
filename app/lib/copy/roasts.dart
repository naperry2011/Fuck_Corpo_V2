import 'dart:math';

import '../core/break_mode.dart';

final _rng = Random();

T pick<T>(List<T> options) => options[_rng.nextInt(options.length)];

const ceoQuotes = [
  ['"Is someone... not working?"', '"Productivity is a family value."'],
  ['"Who approved this?"', '"I can hear that from my office."'],
  ['"MY YACHT FUND!!"', '"That\'s coming out of the pizza party."'],
  ['"SECURITY! SECURITY!!"', '"I\'M LIQUIDATING THE DIVISION!"'],
];

const receiptRoasts = {
  BreakMode.throne: [
    'Corpo paid for that. Every last ounce.',
    'Shareholders have been notified. They are crying.',
    'Best meeting you attended all week.',
  ],
  BreakMode.smoke: [
    'Lungs: damaged. Employer: robbed. Balanced.',
    'Fresh air, paid time. HR hates this one trick.',
    'You lit one up and burned their margins.',
  ],
  BreakMode.lunch: [
    'Fed on their dime. As God intended.',
    'They call it time theft. We call it brunch.',
    'Your sandwich just got a performance bonus.',
  ],
  BreakMode.doomscroll: [
    'Scrolled past 400 posts. Got paid for every one.',
    'Your thumb worked harder than you did. Billable.',
    'Brain rot, but make it salaried.',
  ],
  BreakMode.meeting: [
    'Camera off. Mic muted. Soul at peace.',
    'This meeting could have been an email. It was a nap.',
    '"Let\'s circle back." You never will.',
  ],
  BreakMode.coffee: [
    'Long walk, short coffee. Perfect ratio.',
    'Took the scenic route to the break room. Billed it.',
    'Fueling up on their dime to do less on their dime.',
  ],
};

/// Pro "Unhinged" pack, mixed into every mode's pool once unlocked.
const unhingedRoasts = [
  'Somewhere a shareholder just felt a chill.',
  'You are the reason the Q3 forecast says "headwinds".',
  'HR is drafting a memo about you. Frame it.',
  'Every flush is a tiny wealth redistribution.',
  'The CEO\'s yacht is now 0.0001% smaller. Legend.',
  'You did not quiet quit. You loudly sat.',
];

String receiptRoast(BreakMode mode, {required bool isPro}) =>
    pick([...receiptRoasts[mode]!, if (isPro) ...unhingedRoasts]);

const shareCaption =
    'Corpo paid me to do this. #FuckCorpo #PaidToPoop';

const wrappedCaption =
    'My Corpo Wrapped is in. Wages stolen back. #FuckCorpo #CorpoWrapped';

/// Hypothetical CEO on a \$20M/year package, paid around the clock.
const ceoPerSecond = 20000000 / (365 * 24 * 3600);
