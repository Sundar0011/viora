import '../database.dart';

class BusinessPageTable extends SupabaseTable<BusinessPageRow> {
  @override
  String get tableName => 'business_page';

  @override
  BusinessPageRow createRow(Map<String, dynamic> data) => BusinessPageRow(data);
}

class BusinessPageRow extends SupabaseDataRow {
  BusinessPageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BusinessPageTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get adminUser => getField<String>('admin_user')!;
  set adminUser(String value) => setField<String>('admin_user', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get bio => getField<String>('bio')!;
  set bio(String value) => setField<String>('bio', value);

  String? get profilePicture => getField<String>('profile_picture');
  set profilePicture(String? value) =>
      setField<String>('profile_picture', value);

  String? get coverImage => getField<String>('cover_image');
  set coverImage(String? value) => setField<String>('cover_image', value);

  List<String> get services => getListField<String>('services')!;
  set services(List<String> value) => setListField<String>('services', value);

  String get websiteLink => getField<String>('website_link')!;
  set websiteLink(String value) => setField<String>('website_link', value);

  String get email => getField<String>('email')!;
  set email(String value) => setField<String>('email', value);

  String get phonenumber => getField<String>('phonenumber')!;
  set phonenumber(String value) => setField<String>('phonenumber', value);

  bool get isDeleted => getField<bool>('is_deleted')!;
  set isDeleted(bool value) => setField<bool>('is_deleted', value);

  String get businessStatus => getField<String>('business_status')!;
  set businessStatus(String value) =>
      setField<String>('business_status', value);
}
