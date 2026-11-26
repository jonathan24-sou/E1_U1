import 'package:e1_u1/data/database.dart';
import 'package:e1_u1/data/entities/category.dart';
import 'package:e1_u1/data/entities/note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'filtra por categoría y ordena las notas de más nueva a más antigua',
    () async {
      final workId = await database.categoryDao.insert(
        const Category(name: 'Trabajo', color: '#3344AA'),
      );
      final personalId = await database.categoryDao.insert(
        const Category(name: 'Personal', color: '#22AA66'),
      );

      await database.noteDao.insert(
        Note(
          title: 'Antigua',
          content: '',
          date: DateTime(2026, 1, 1),
          categoryId: workId,
        ),
      );
      await database.noteDao.insert(
        Note(
          title: 'Otra categoría',
          content: '',
          date: DateTime(2026, 12, 1),
          categoryId: personalId,
        ),
      );
      await database.noteDao.insert(
        Note(
          title: 'Reciente',
          content: '',
          date: DateTime(2026, 2, 1),
          categoryId: workId,
        ),
      );

      final notes = await database.noteDao.findByCategory(workId);

      expect(notes.map((note) => note.title), ['Reciente', 'Antigua']);
    },
  );
}
