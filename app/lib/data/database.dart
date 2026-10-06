import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/break_mode.dart';

part 'database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => textEnum<BreakMode>()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMs => integer()();
  RealColumn get earned => real()();
}

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'fcorpo'));

  @override
  int get schemaVersion => 1;

  Future<Session> addSession(SessionsCompanion entry) =>
      into(sessions).insertReturning(entry);

  Stream<List<Session>> watchSessions() => (select(sessions)
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
      .watch();

  Future<int> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();
}
