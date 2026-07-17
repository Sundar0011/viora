import '../database.dart';

class BusinessPromotePlansTable extends SupabaseTable<BusinessPromotePlansRow> {
  @override
  String get tableName => 'business_promote_plans';

  @override
  BusinessPromotePlansRow createRow(Map<String, dynamic> data) =>
      BusinessPromotePlansRow(data);
}

class BusinessPromotePlansRow extends SupabaseDataRow {
  BusinessPromotePlansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessPromotePlansTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  int get daysCount => getField<int>('days_count')!;
  set daysCount(int value) => setField<int>('days_count', value);

  double get price => getField<double>('price')!;
  set price(double value) => setField<double>('price', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);
}
