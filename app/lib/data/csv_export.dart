import 'database.dart';

String _cell(String v) =>
    v.contains(RegExp(r'[",\n]')) ? '"${v.replaceAll('"', '""')}"' : v;

String sessionsToCsv(List<Session> sessions) {
  final rows = [
    'receipt,mode,started_at,duration_seconds,earned,business,industry,damages',
    for (final s in sessions)
      [
        s.id.toString(),
        _cell(s.mode.label),
        s.startedAt.toIso8601String(),
        (s.durationMs / 1000).toStringAsFixed(0),
        s.earned.toStringAsFixed(4),
        _cell(s.businessName ?? ''),
        s.businessCategory?.label ?? '',
        s.damages?.toStringAsFixed(4) ?? '',
      ].join(','),
  ];
  return '${rows.join('\n')}\n';
}
