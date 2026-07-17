import '../database.dart';

class UserLoginTable extends SupabaseTable<UserLoginRow> {
  @override
  String get tableName => 'user_login';

  @override
  UserLoginRow createRow(Map<String, dynamic> data) => UserLoginRow(data);
}

class UserLoginRow extends SupabaseDataRow {
  UserLoginRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserLoginTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get mobileNoCc => getField<String>('mobile_no_cc');
  set mobileNoCc(String? value) => setField<String>('mobile_no_cc', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String get otp => getField<String>('otp')!;
  set otp(String value) => setField<String>('otp', value);

  DateTime get expiryDate => getField<DateTime>('expiry_date')!;
  set expiryDate(DateTime value) => setField<DateTime>('expiry_date', value);

  double get noOfTimes => getField<double>('no_of_times')!;
  set noOfTimes(double value) => setField<double>('no_of_times', value);

  DateTime get lastRequestedDate => getField<DateTime>('last_requested_date')!;
  set lastRequestedDate(DateTime value) =>
      setField<DateTime>('last_requested_date', value);
}
