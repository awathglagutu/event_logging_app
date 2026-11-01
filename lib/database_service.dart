import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'event_sheet.dart';
import 'nasa_tlx.dart';
import 'participant.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const _databaseName = 'fieldwork.db';
  static const _databaseVersion = 3;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = p.join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE participants (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            matricNumber TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE event_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            participant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            elapsed_milliseconds INTEGER NOT NULL,
            wrongTurns INTEGER NOT NULL,
            mapChecks INTEGER NOT NULL,
            interventions TEXT NOT NULL,
            disruptions TEXT NOT NULL,
            issues TEXT NOT NULL,
            success INTEGER NOT NULL,
            checked_labels TEXT NOT NULL,
            explanation TEXT NOT NULL,
            external_help TEXT NOT NULL DEFAULT '[false,false,false]',
            application TEXT,
            route TEXT,
            FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE survey_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            participant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            survey_values TEXT NOT NULL,
            application TEXT,
            route TEXT,
            FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE event_records ADD COLUMN external_help TEXT NOT NULL DEFAULT '[false,false,false]'");
          await db.execute('ALTER TABLE event_records ADD COLUMN application TEXT');
          await db.execute('ALTER TABLE event_records ADD COLUMN route TEXT');
          await db.execute('UPDATE event_records SET success = CASE WHEN success = 1 THEN 0 ELSE 1 END');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE survey_records ADD COLUMN application TEXT');
          await db.execute('ALTER TABLE survey_records ADD COLUMN route TEXT');
        }
      },
    );
    return _database!;
  }

  Future<int> insertParticipant(Participant participant) async {
    final db = await database;
    return db.insert('participants', _participantValues(participant));
  }

  Future<List<Participant>> fetchParticipants() async {
    final db = await database;
    final rows = await db.query('participants', orderBy: 'rowid DESC');
    final participants = <Participant>[];
    for (final row in rows) {
      participants.add(await _participantFromRow(db, row));
    }
    return participants;
  }

  Future<Participant?> fetchParticipant(String id) async {
    final db = await database;
    final rows = await db.query('participants', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _participantFromRow(db, rows.first);
  }

  Future<int> updateParticipant(Participant participant) async {
    final db = await database;
    return db.update('participants', _participantValues(participant), where: 'id = ?', whereArgs: [participant.id]);
  }

  Future<int> deleteParticipant(String id) async {
    final db = await database;
    return db.delete('participants', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertEventRecord(String participantId, EventRecord record) async {
    final db = await database;
    final id = await db.insert('event_records', _eventValues(participantId, record));
    record.databaseId = id;
    return id;
  }

  Future<List<EventRecord>> fetchEventRecords(String participantId) async {
    final db = await database;
    final rows = await db.query('event_records', where: 'participant_id = ?', whereArgs: [participantId], orderBy: 'id DESC');
    return rows.map(_eventFromRow).toList();
  }

  Future<int> updateEventRecord(String participantId, EventRecord record) async {
    final id = record.databaseId;
    if (id == null) throw ArgumentError('Cannot update an event record without a database ID.');
    final db = await database;
    return db.update('event_records', _eventValues(participantId, record), where: 'id = ? AND participant_id = ?', whereArgs: [id, participantId]);
  }

  Future<int> deleteEventRecord(int id) async {
    final db = await database;
    return db.delete('event_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertSurveyRecord(String participantId, SurveyRecord record) async {
    final db = await database;
    final id = await db.insert('survey_records', _surveyValues(participantId, record));
    record.databaseId = id;
    return id;
  }

  Future<List<SurveyRecord>> fetchSurveyRecords(String participantId) async {
    final db = await database;
    final rows = await db.query('survey_records', where: 'participant_id = ?', whereArgs: [participantId], orderBy: 'id DESC');
    return rows.map(_surveyFromRow).toList();
  }

  Future<int> updateSurveyRecord(String participantId, SurveyRecord record) async {
    final id = record.databaseId;
    if (id == null) throw ArgumentError('Cannot update a survey record without a database ID.');
    final db = await database;
    return db.update('survey_records', _surveyValues(participantId, record), where: 'id = ? AND participant_id = ?', whereArgs: [id, participantId]);
  }

  Future<int> deleteSurveyRecord(int id) async {
    final db = await database;
    return db.delete('survey_records', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _participantValues(Participant participant) => {
    'id': participant.id,
    'name': participant.name,
    'matricNumber': participant.matricNumber,
  };

  Map<String, Object?> _eventValues(String participantId, EventRecord record) => {
    'participant_id': participantId,
    'name': record.name,
    'elapsed_milliseconds': record.elapsed.inMilliseconds,
    'wrongTurns': record.wrongTurns,
    'mapChecks': record.mapChecks,
    'interventions': record.interventions,
    'disruptions': record.disruptions,
    'issues': record.issues,
    'success': record.success.index,
    'checked_labels': jsonEncode(record.checked),
    'explanation': record.explanation,
    'external_help': jsonEncode(record.externalHelp),
    'application': record.application,
    'route': record.route,
  };

  Map<String, Object?> _surveyValues(String participantId, SurveyRecord record) => {
    'participant_id': participantId,
    'name': record.name,
    'survey_values': jsonEncode(record.values),
    'application': record.application,
    'route': record.route,
  };

  Future<Participant> _participantFromRow(Database db, Map<String, Object?> row) async {
    final id = row['id'] as String;
    final eventRows = await db.query('event_records', where: 'participant_id = ?', whereArgs: [id], orderBy: 'id DESC');
    final surveyRows = await db.query('survey_records', where: 'participant_id = ?', whereArgs: [id], orderBy: 'id DESC');
    return Participant(
      id: id,
      name: row['name'] as String,
      matricNumber: row['matricNumber'] as String,
      events: eventRows.map(_eventFromRow).toList(),
      surveys: surveyRows.map(_surveyFromRow).toList(),
    );
  }

  EventRecord _eventFromRow(Map<String, Object?> row) => EventRecord(
    databaseId: row['id'] as int,
    name: row['name'] as String,
    elapsed: Duration(milliseconds: row['elapsed_milliseconds'] as int),
    wrongTurns: row['wrongTurns'] as int,
    mapChecks: row['mapChecks'] as int,
    interventions: row['interventions'] as String,
    disruptions: row['disruptions'] as String,
    issues: row['issues'] as String,
    success: EventOutcome.values[(row['success'] as int).clamp(0, 2).toInt()],
    checked: (jsonDecode(row['checked_labels'] as String) as List).cast<bool>(),
    explanation: row['explanation'] as String,
    externalHelp: (jsonDecode((row['external_help'] as String?) ?? '[false,false,false]') as List).cast<bool>(),
    application: row['application'] as String?,
    route: row['route'] as String?,
  );

  SurveyRecord _surveyFromRow(Map<String, Object?> row) => SurveyRecord(
    row['name'] as String,
    (jsonDecode(row['survey_values'] as String) as List).cast<int>(),
    databaseId: row['id'] as int,
    application: row['application'] as String?,
    route: row['route'] as String?,
  );
}
