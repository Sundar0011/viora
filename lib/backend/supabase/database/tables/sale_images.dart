import '../database.dart';

class SaleImagesTable extends SupabaseTable<SaleImagesRow> {
  @override
  String get tableName => 'sale_images';

  @override
  SaleImagesRow createRow(Map<String, dynamic> data) => SaleImagesRow(data);
}

class SaleImagesRow extends SupabaseDataRow {
  SaleImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SaleImagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get communityId => getField<int>('community_id');
  set communityId(int? value) => setField<int>('community_id', value);

  String get saleId => getField<String>('sale_id')!;
  set saleId(String value) => setField<String>('sale_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get image => getField<String>('image');
  set image(String? value) => setField<String>('image', value);
}
