import '../database.dart';

class GroupAdminTable extends SupabaseTable<GroupAdminRow> {
  @override
  String get tableName => 'group_admin';

  @override
  GroupAdminRow createRow(Map<String, dynamic> data) => GroupAdminRow(data);
}

class GroupAdminRow extends SupabaseDataRow {
  GroupAdminRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GroupAdminTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get communityId => getField<int>('community_id')!;
  set communityId(int value) => setField<int>('community_id', value);

  String get groupId => getField<String>('group_id')!;
  set groupId(String value) => setField<String>('group_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get eGroupRole => getField<String>('e_group_role')!;
  set eGroupRole(String value) => setField<String>('e_group_role', value);
}
