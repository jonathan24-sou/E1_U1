// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CategoryDao? _categoryDaoInstance;

  NoteDao? _noteDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `color` TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `notes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `content` TEXT NOT NULL, `date` INTEGER NOT NULL, `categoryId` INTEGER NOT NULL, FOREIGN KEY (`categoryId`) REFERENCES `categories` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)',
        );
        await database.execute(
          'CREATE INDEX `index_notes_categoryId_date` ON `notes` (`categoryId`, `date`)',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CategoryDao get categoryDao {
    return _categoryDaoInstance ??= _$CategoryDao(database, changeListener);
  }

  @override
  NoteDao get noteDao {
    return _noteDaoInstance ??= _$NoteDao(database, changeListener);
  }
}

class _$CategoryDao extends CategoryDao {
  _$CategoryDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _categoryInsertionAdapter = InsertionAdapter(
        database,
        'categories',
        (Category item) => <String, Object?>{
          'id': item.id,
          'name': item.name,
          'color': item.color,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Category> _categoryInsertionAdapter;

  @override
  Future<List<Category>> findAll() async {
    return _queryAdapter.queryList(
      'SELECT * FROM categories ORDER BY name COLLATE NOCASE',
      mapper: (Map<String, Object?> row) => Category(
        id: row['id'] as int?,
        name: row['name'] as String,
        color: row['color'] as String,
      ),
    );
  }

  @override
  Future<int> insert(Category category) {
    return _categoryInsertionAdapter.insertAndReturnId(
      category,
      OnConflictStrategy.abort,
    );
  }
}

class _$NoteDao extends NoteDao {
  _$NoteDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _noteInsertionAdapter = InsertionAdapter(
        database,
        'notes',
        (Note item) => <String, Object?>{
          'id': item.id,
          'title': item.title,
          'content': item.content,
          'date': _dateTimeConverter.encode(item.date),
          'categoryId': item.categoryId,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Note> _noteInsertionAdapter;

  @override
  Future<List<Note>> findByCategory(int categoryId) async {
    return _queryAdapter.queryList(
      'SELECT * FROM notes WHERE categoryId = ?1 ORDER BY date DESC',
      mapper: (Map<String, Object?> row) => Note(
        id: row['id'] as int?,
        title: row['title'] as String,
        content: row['content'] as String,
        date: _dateTimeConverter.decode(row['date'] as int),
        categoryId: row['categoryId'] as int,
      ),
      arguments: [categoryId],
    );
  }

  @override
  Future<int> insert(Note note) {
    return _noteInsertionAdapter.insertAndReturnId(
      note,
      OnConflictStrategy.abort,
    );
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
