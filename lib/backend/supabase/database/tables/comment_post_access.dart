import '../database.dart';

class CommentPostAccessTable extends SupabaseTable<CommentPostAccessRow> {
  @override
  String get tableName => 'comment_post_access';

  @override
  CommentPostAccessRow createRow(Map<String, dynamic> data) =>
      CommentPostAccessRow(data);
}

class CommentPostAccessRow extends SupabaseDataRow {
  CommentPostAccessRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CommentPostAccessTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);
}
