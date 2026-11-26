import 'package:floor/floor.dart';

import 'category.dart';

@Entity(
  tableName: 'notes',
  foreignKeys: [
    ForeignKey(
      childColumns: ['categoryId'],
      parentColumns: ['id'],
      entity: Category,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['categoryId', 'date']),
  ],
)
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String content;
  final DateTime date;
  final int categoryId;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.categoryId,
  });
}
