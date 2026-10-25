import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/break_mode.dart';
import '../core/takeover.dart';

part 'database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => textEnum<BreakMode>()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMs => integer()();
  RealColumn get earned => real()();

  // Hostile takeovers (schema v2). All null for sessions at your own job.
  TextColumn get businessName => text().nullable()();
  TextColumn get businessCategory =>
      textEnum<BusinessCategory>().nullable()();
  RealColumn get damages => real().nullable()();
}

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'fcorpo'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(sessions, sessions.businessName);
            await m.addColumn(sessions, sessions.businessCategory);
            await m.addColumn(sessions, sessions.damages);
          }
        },
      );

  Future<Session> addSession(SessionsCompanion entry) =>
      into(sessions).insertReturning(entry);

  Stream<List<Session>> watchSessions() => (select(sessions)
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
      .watch();

  Future<int> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();
}
