import 'package:floor/floor.dart';

import '../entities/note.dart';

@dao
abstract class NoteDao {
  @Insert()
  Future<int> insert(Note note);

  @Query(
    'SELECT * FROM notes WHERE categoryId = :categoryId ORDER BY date DESC',
  )
  Future<List<Note>> findByCategory(int categoryId);
}
