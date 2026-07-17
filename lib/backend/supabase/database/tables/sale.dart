import '../database.dart';

class SaleTable extends SupabaseTable<SaleRow> {
  @override
  String get tableName => 'sale';

  @override
  SaleRow createRow(Map<String, dynamic> data) => SaleRow(data);
}

class SaleRow extends SupabaseDataRow {
  SaleRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SaleTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String get saleCategory => getField<String>('sale_category')!;
  set saleCategory(String value) => setField<String>('sale_category', value);

  String get ePriceType => getField<String>('e_price_type')!;
  set ePriceType(String value) => setField<String>('e_price_type', value);

  int? get price => getField<int>('price');
  set price(int? value) => setField<int>('price', value);

  String get location => getField<String>('location')!;
  set location(String value) => setField<String>('location', value);

  String get eSaleType => getField<String>('e_sale_type')!;
  set eSaleType(String value) => setField<String>('e_sale_type', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String get locationPoint => getField<String>('location_point')!;
  set locationPoint(String value) => setField<String>('location_point', value);

  String get city => getField<String>('city')!;
  set city(String value) => setField<String>('city', value);

  bool get isdeleted => getField<bool>('isdeleted')!;
  set isdeleted(bool value) => setField<bool>('isdeleted', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);
}
