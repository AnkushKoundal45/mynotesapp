import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/extensions/list/filter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;
  DatabaseUser? _user;
  //   a private function which checks if db is open or not and return db if open.
  List<DatabaseNote> _note = [];

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.add(_note);
    }); // broadcast fix a basic error of listening to stream for multiple times. We will hook it,later with the list created above.
  }
  late final StreamController<List<DatabaseNote>>
      _notesStreamController; // broadcast fix a basic error of listening to stream for multiple times. We will hook it,later with the list created above.

  factory NotesService() => _shared;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });
  Database _getDatabseOpenOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseUser> getOrCreateUser({
    required email,
    bool setAsCurrentUser = true,
  }) async {
    await _ensureDbIsOpen();

    try {
      final user = await fetchUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _note = allNotes.toList();
    _notesStreamController.add(_note);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final note = await db.query(noteTable);
    return note.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabseOpenOrThrow();
    await fetchNote(id: note.id);
    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id =?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await fetchNote(id: note.id);
      _note.removeWhere((note) => note.id == updatedNote.id);
      _note.add(updatedNote);
      _notesStreamController.add(_note);
      return updatedNote;
    }
  }

  Future<DatabaseNote> fetchNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(results.first);
      _note.removeWhere((note) => note.id == id);
      _note.add(note);
      _notesStreamController.add(_note);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final deletedRowsCount = await db.delete(noteTable);
    _note = [];
    _notesStreamController.add(_note);
    return deletedRowsCount;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final dbUser = await fetchUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    } else {
      const text = '';
      final noteId = await db.insert(noteTable, {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      });
      final note = DatabaseNote(
          id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
      // now we will add new created note to the stream controller.
      _note.add(note);

      _notesStreamController.add(_note);
      return note;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id =?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _note.removeWhere((note) => note.id == id);
      _notesStreamController.add(_note);
    }
  }

  Future<DatabaseUser> fetchUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabseOpenOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final id = await db.insert(userTable, {
        emailColumn: email.toLowerCase(),
      });
      return DatabaseUser(id: id, email: email);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();

    final db = _getDatabseOpenOrThrow();
    final int deleteCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await openDB();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> openDB() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

// Now creating our tables here after creating our database using above commands inside the application document directory.
// ''' to add other programming language code in our code.
// create user table
      await db.execute(createUserTable);
// create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> closeDB() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db == null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
  //overiding to print it to the console as a string.
  @override
  String toString() => 'Person id = $id, email = $email';
  //overiding so that to compare inside the databaseuser isntance(covariant) which other has same id
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note id = $id , userid = $userId , isSyncedWithCloud = $isSyncedWithCloud , text = $text';
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const noteTable = 'note';
const userTable = 'user';
const dbName = 'Note.db';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	STRING NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
); ''';
const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
