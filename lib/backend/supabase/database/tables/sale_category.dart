import '../database.dart';

class SaleCategoryTable extends SupabaseTable<SaleCategoryRow> {
  @override
  String get tableName => 'sale_category';

  @override
  SaleCategoryRow createRow(Map<String, dynamic> data) => SaleCategoryRow(data);
}

class SaleCategoryRow extends SupabaseDataRow {
  SaleCategoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SaleCategoryTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get communityId => getField<int>('community_id');
  set communityId(int? value) => setField<int>('community_id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);
}
