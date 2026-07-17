import '../database.dart';

class SeePostAccessTable extends SupabaseTable<SeePostAccessRow> {
  @override
  String get tableName => 'see_post_access';

  @override
  SeePostAccessRow createRow(Map<String, dynamic> data) =>
      SeePostAccessRow(data);
}

class SeePostAccessRow extends SupabaseDataRow {
  SeePostAccessRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SeePostAccessTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);
}
