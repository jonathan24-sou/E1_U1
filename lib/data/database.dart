// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/category_dao.dart';
import 'dao/note_dao.dart';
import 'entities/category.dart';
import 'entities/note.dart';

part 'database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [Category, Note])
abstract class AppDatabase extends FloorDatabase {
  CategoryDao get categoryDao;
  NoteDao get noteDao;
}

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int value) => DateTime.fromMillisecondsSinceEpoch(value);

  @override
  int encode(DateTime value) => value.millisecondsSinceEpoch;
}
