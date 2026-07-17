import '../database.dart';

class GroupTable extends SupabaseTable<GroupRow> {
  @override
  String get tableName => 'group';

  @override
  GroupRow createRow(Map<String, dynamic> data) => GroupRow(data);
}

class GroupRow extends SupabaseDataRow {
  GroupRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get createdBy => getField<String>('created_by')!;
  set createdBy(String value) => setField<String>('created_by', value);

  String? get profilePicture => getField<String>('profile_picture');
  set profilePicture(String? value) =>
      setField<String>('profile_picture', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get eGroupType => getField<String>('e_group_type')!;
  set eGroupType(String value) => setField<String>('e_group_type', value);

  String get eDiscoverability => getField<String>('e_discoverability')!;
  set eDiscoverability(String value) =>
      setField<String>('e_discoverability', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  int get totalMembers => getField<int>('total_members')!;
  set totalMembers(int value) => setField<int>('total_members', value);

  String get location => getField<String>('location')!;
  set location(String value) => setField<String>('location', value);

  bool get isdeleted => getField<bool>('isdeleted')!;
  set isdeleted(bool value) => setField<bool>('isdeleted', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);
}
