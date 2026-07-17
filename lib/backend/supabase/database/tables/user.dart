import '../database.dart';

class UserTable extends SupabaseTable<UserRow> {
  @override
  String get tableName => 'user';

  @override
  UserRow createRow(Map<String, dynamic> data) => UserRow(data);
}

class UserRow extends SupabaseDataRow {
  UserRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get mobileNumber => getField<String>('mobile_number');
  set mobileNumber(String? value) => setField<String>('mobile_number', value);

  String? get mobileNumberCc => getField<String>('mobile_number_cc');
  set mobileNumberCc(String? value) =>
      setField<String>('mobile_number_cc', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  String? get flat => getField<String>('flat');
  set flat(String? value) => setField<String>('flat', value);

  String? get postalCode => getField<String>('postal_code');
  set postalCode(String? value) => setField<String>('postal_code', value);

  bool? get blocked => getField<bool>('blocked');
  set blocked(bool? value) => setField<bool>('blocked', value);

  bool? get onboardingCompleted => getField<bool>('onboarding_completed');
  set onboardingCompleted(bool? value) =>
      setField<bool>('onboarding_completed', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  String? get reason => getField<String>('reason');
  set reason(String? value) => setField<String>('reason', value);

  bool? get isOwner => getField<bool>('IsOwner');
  set isOwner(bool? value) => setField<bool>('IsOwner', value);

  DateTime? get lastSigninAt => getField<DateTime>('last_signin_at');
  set lastSigninAt(DateTime? value) =>
      setField<DateTime>('last_signin_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
