import 'package:floor/floor.dart';

import '../entities/category.dart';

@dao
abstract class CategoryDao {
  @Insert()
  Future<int> insert(Category category);

  @Query('SELECT * FROM categories ORDER BY name COLLATE NOCASE')
  Future<List<Category>> findAll();
}
