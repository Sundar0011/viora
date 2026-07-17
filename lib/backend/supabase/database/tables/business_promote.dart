import '../database.dart';

class BusinessPromoteTable extends SupabaseTable<BusinessPromoteRow> {
  @override
  String get tableName => 'business_promote';

  @override
  BusinessPromoteRow createRow(Map<String, dynamic> data) =>
      BusinessPromoteRow(data);
}

class BusinessPromoteRow extends SupabaseDataRow {
  BusinessPromoteRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessPromoteTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get businessPageId => getField<String>('business_page_id')!;
  set businessPageId(String value) =>
      setField<String>('business_page_id', value);

  int get businessPromotePlans => getField<int>('business_promote_plans')!;
  set businessPromotePlans(int value) =>
      setField<int>('business_promote_plans', value);

  int get referenceNumber => getField<int>('reference_number')!;
  set referenceNumber(int value) => setField<int>('reference_number', value);

  String? get receipt => getField<String>('receipt');
  set receipt(String? value) => setField<String>('receipt', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime? get planStartDate => getField<DateTime>('plan_start_date');
  set planStartDate(DateTime? value) =>
      setField<DateTime>('plan_start_date', value);

  DateTime? get planEndDate => getField<DateTime>('plan_end_date');
  set planEndDate(DateTime? value) =>
      setField<DateTime>('plan_end_date', value);

  String get adminUser => getField<String>('admin_user')!;
  set adminUser(String value) => setField<String>('admin_user', value);
}
